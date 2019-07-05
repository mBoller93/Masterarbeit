function [u_opt, J_opt, solverOutput, x0_init] = get_input_u_yalmip_qp(constraints, d_pred, modelData, x_k, k, N_pred, x_opt0, common, instance)
%Function to find optimal input values u_opt minimizing a cost function
%Inputs: constraints...Matrix containing constraints values
%        d_pred ...    vector of predicted disturbances
%        modelData ... struct with model data
%        x_k ...       state vector at current step k
%        k ...         current step k
%        N_pred...     size of prediction horizon
%        x_opt0 ...    initial vector for optimization
%        common ...    the common struct of the sfsp class
%        instance ...  struct of the currently evaluated instance inside sfsp class
%Outputs:u_opt...      vector with optimal input values, size n_d*N_pred x 1
%        J_opt...      scalar value of minimized costs
%        solverOutput  struct with solver output
%        x0_init       starting point for optimisation at the next time step

% caching sdpsettings should save a lot of time
persistent options

if ~exist('sdpsettings')
    addpath( genpath( common.extra.yalmipPath ) ); 
end

printDiagnostics = common.config.printDiagnostics;
auxiliaryData = instance.model.auxiliaryData;
n_x = instance.model.n_x;
n_u = instance.model.n_u;
n_d = instance.model.n_d;
u_max = instance.state.u_max;

u_pred = sdpvar(N_pred*n_u, 1);

% extract P_grid from symbolic u_pred
P_grid = kron(eye(N_pred), [1 zeros( 1, n_u - 1)])*u_pred;

% reformulation 1:
% max(P_grid) ==> introduce decision variable v
% with N_pred conditions v >= P_grid_i
% replace max(P_grid) ==> v
t = sdpvar(1, 1);

% reformulation 2:
% max(0, v - Pgrid,max) ==> introduce decision variable t
% with 2 conditions: a.) t >= 0 b.) t >= v
% replace max(0, v) ==> t
v = sdpvar(1, 1);

% reformulation 3:
% store positive parts of P_grid as a vector [Pgrid(0|k) 0 0 Pgrid(3|k)..
% buy using reformulation max(0, Pgrid(i|k)) = P_pos(i)
P_pos = sdpvar(N_pred, 1);

peak_max_grid = [1 zeros(1, n_u-1 )]*u_max;

vars.t = t;
vars.v = v;
vars.P_pos = P_pos;

costfun = @(u_pred)(costFunction(u_pred, common, instance, vars));  
cost = costfun(u_pred);

u_lb = zeros(N_pred*n_u, 1);            %Create constraint vectors from big constraints matrix: u_lb< u <u_ub
u_ub = zeros(N_pred*n_u, 1);
for i=0:N_pred-1
    u_lb(i*n_u+1:(i+1)*n_u) = constraints(2*n_x+1:2*n_x+n_u, i+1);
    u_ub(i*n_u+1:(i+1)*n_u) = constraints(2*n_x+n_u+1:2*n_x+2*n_u, i+1);
end
u_lb(isnan(u_lb)) = -Inf;               %NaN values changed to -Inf
u_ub(isnan(u_ub)) = +Inf;               %NaN values changed to +Inf

constr = [];

% seperating the constraints, so that no scaling problems may occur
% i.e. leaving out unnecessary upper/lower bounds of infinity
% for i=1:length(u_lb)
%     if( isinf( u_ub(i) ) )              % leave out upper bound
%         if( ~isinf( u_lb(i) ) )         % but add lower bound -> add constraint u_lb(i) <= u_pred(i)
%             constr = [
%                 constr;
%                 (u_lb(i) <= u_pred(i)):['u' num2str( floor(i/4) ) '_' num2str(mod(i-1, 4)+1)]
%             ];
%         end
%     else                                % add upper bound
%         if( ~isinf( u_lb(i) ) )         % and add lower bound -> u_lb(i) <= u_pred(i) <= u_ub(i)
%            constr = [
%                constr;
%                (u_lb(i) <= u_pred(i) <= u_ub(i)):['u' num2str( floor(i/4) ) '_' num2str(mod(i-1, 4)+1)];
%            ];
%         else                            % leave out lower bound -> u_pred(i) <= u_ub(i)
%             constr = [  
%                 constr;
%                 (u_pred(i) <= u_ub(i)):['u' num2str( floor(i/4) ) '_' num2str(mod(i-1, 4)+1)];
%             ];
%         end
%     end
%     
% end
% linear constraint function lbg <= g(x) <= ubg
% all lbg and ubg may not contain any decision variables, so
% all constraints are rewritten accordingly
constr = [
    (u_lb <= u_pred <= u_ub):'u';                             % upper/lower bound directly on u_pred
    (P_grid <= v):'max P_grid';                         % N_pred conditions v >= P_grid_i ==> v - P_grid_i >= 0, compressed into one line in matlab
    (0 <= t):'max(0, P_grid) 0';                        % condition t >= 0
    (v - peak_max_grid <= t):'max(0, v) v';             % condition t >= v - peak_max
    (0 <= P_pos <= 1e5):'max(0, P_grid) 0';             % condition 1e5 >= P_pos >= 0, ub for boundedness
    (P_grid <= P_pos):'max(0, P_grid) P_grid';   % condition 1e5 >= P_pos >= P_grid, ub for boundedness
];

% if the model is linear, state is linear to input, so state constraints
% realizable as linear constraints
if(modelData.type == 1)
    [A_c, b_c, A_c2, b_c2] = prepareStateTrajectoryConstraints(constraints, auxiliaryData, n_x, n_u, n_d, N_pred, x_k, d_pred);

    % add constraints on x/dx line-wise
    % this is necessary, since some solvers may have problems
    % with constraints that are too diverse in numerical range
    % YALMIP does handle A*x <= b differently to splitting it into parts
    % A*x <= b will yield a 2*2*n_x*N_pred x 1 constraint, ranging from
    % e.g. 1e-6 to 1e3, which may cause scaling problems
    % adding 2*2*n_x*N_pred 1x1 constraints reduces these problems
%     for i=1:length(b_c)
%        constr = [
%            constr;
%            (A_c(i, :)*u_pred <= b_c(i)):'x'
%        ];
%     end
    constr = [
        constr;
        (A_c*u_pred <= b_c):'x';
        (A_c2*u_pred <= b_c2):'dx';
    ];
end

usex0 = 0;
% set initial guesses
if( ~isempty(x_opt0) && isequal(common.extra.solver, 'cplex') )
    assign(u_pred, x_opt0(1:N_pred*n_u));
    assign(t, 0);
    assign(v, 0);
    assign(P_pos, x_opt0(N_pred*n_u+1+1+1:end));
    usex0 = 1;
end

% set up MIQP problem
if isempty(options)
    options = sdpsettings('verbose', 0, 'solver', common.extra.solver, 'usex0', usex0, 'debug', 0);
end
sol = optimize( constr, cost, options );

% retrieve u_opt from optimal solution vector x
u_opt = value( u_pred );

% retrieve optimal objective function value
J_opt = value( cost );

P_pos_opt = value( P_pos );

% starting point for next optimization

x0_init = [
    u_opt(n_u+1:end);
    zeros(n_u, 1);
    0;
    0;
    P_pos_opt(N_pred*n_u+1+1+1+1:end);
    0
];

% todo: retrieve solver result state and return
exitflag = sol.problem;
description.message = yalmiperror(sol.problem);

solverOutput = struct;

solverOutput.exitflag = exitflag;
solverOutput.description = description;

end

function [A_c, b_c, A_c2, b_c2]  = prepareStateTrajectoryConstraints(constraints, auxiliaryData, n_x, n_u, n_d, N_pred, x_k, d_pred)
    x_lb = zeros(N_pred*n_x, 1);            %Create constraint vectors for x from constraints matrix
    x_ub = zeros(N_pred*n_x, 1);
    for i=0:N_pred-1
        x_lb(i*n_x+1:(i+1)*n_x) = constraints(1:n_x, i+1);
        x_ub(i*n_x+1:(i+1)*n_x) = constraints(n_x+1:2*n_x, i+1);
    end
    x_lb(isnan(x_lb)) = -Inf;               %Change NaN-values to -Inf
    x_ub(isnan(x_ub)) = +Inf;
    
    dx_constraint_lb = constraints(2*n_x+2*n_u+2*n_d+2*n_x+1:2*n_x+2*n_u+2*n_d+2*n_x+n_x, 1:end);
    dx_constraint_lb = reshape(dx_constraint_lb, n_x*(N_pred), 1);
    dx_constraint_ub = constraints(2*n_x+2*n_u+2*n_d+2*n_x+n_x+1:2*n_x+2*n_u+2*n_d+2*n_x+2*n_x, 1:end);
    dx_constraint_ub = reshape(dx_constraint_ub, n_x*(N_pred), 1);
    
    dx_constraint_lb(isnan(dx_constraint_lb)) = -Inf;               %Change NaN-values to -Inf
    dx_constraint_ub(isnan(dx_constraint_ub)) = Inf;
    
    A_t = auxiliaryData.A_tilda;             %Read Matrices A_tilde and S_tilde
    A_t = A_t(n_x+1:size(A_t,1),:);
    
    S_t = auxiliaryData.S_tilda;
    S_t = S_t(n_x+1:size(S_t,1),:);
    
    b_ub_x = x_ub - A_t*x_k - S_t*d_pred;    %Calculate b vectors constraining u from the constraints for x
    b_lb_x = -x_lb + A_t*x_k + S_t*d_pred;
    
    A_ub_x = auxiliaryData.B_tilda;          %Calculate A matrices constraining x via u: A*u < b
    A_ub_x = A_ub_x(n_x+1:size(A_ub_x,1),:);
    A_lb_x = -auxiliaryData.B_tilda;
    A_lb_x = A_lb_x(n_x+1:size(A_lb_x,1),:);
   
    % constraints on dx = x(k+1) - x(k) 
    T_dx = -[ eye(N_pred*n_x), zeros(N_pred*n_x, n_x) ] + [ zeros(N_pred*n_x, n_x), eye(N_pred*n_x) ];
    A_lb_ub_dx = T_dx * auxiliaryData.B_tilda;
    b_ub_dx = dx_constraint_ub - T_dx * (auxiliaryData.A_tilda * x_k + auxiliaryData.S_tilda * d_pred );
    b_lb_dx = -dx_constraint_lb + T_dx * (auxiliaryData.A_tilda * x_k + auxiliaryData.S_tilda * d_pred );
    
    % build constraint matrix A and b for fmincon lin constraint A*u <= b
    A_c = [
        A_lb_x;
        A_ub_x;
        ];
    
    b_c = [
        b_lb_x;
        b_ub_x;
        ];
    
    % only include total input constraints if total input is actually
    % constrained. otherwise, fmincon runs into numerical trouble
%     if( ~all( isinf( dx_constraint_lb ) ) )
%         A_c = [
%             A_c;
%             -A_lb_ub_dx;
%             ];
%         b_c = [
%             b_c;
%             b_lb_dx;
%             ];
%     end
%     
%     if( ~all( isinf( dx_constraint_ub ) ) )
%         A_c = [
%             A_c;
%             A_lb_ub_dx;
%             ];
%         b_c = [
%             b_c;
%             b_ub_dx;
%             ];
%     end
    A_c2 = [
        -A_lb_ub_dx;
        A_lb_ub_dx
    ];
    
    b_c2 = [
        b_lb_dx;
        b_ub_dx
    ];
end
