function [u_opt, J_opt, solverOutput, x0_init] = get_input_u_MPC(constraints, d_pred, modelData, x_k, k, N_pred, x_opt0, common, instance)
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

addpath( common.extra.casadiPath );
import casadi.*;

printDiagnostics = common.config.printDiagnostics;
auxiliaryData = instance.model.auxiliaryData;
n_x = instance.model.n_x;
n_u = instance.model.n_u;
n_d = instance.model.n_d;
u_max = instance.state.u_max;

u_pred = SX.sym('u_pred', N_pred*n_u);

% extract P_grid from symbolic u_pred
P_grid = kron(eye(N_pred), [1 zeros( 1, n_u - 1)])*u_pred;

% reformulation 1:
% max(P_grid) ==> introduce decision variable v
% with N_pred conditions v >= P_grid_i
% replace max(P_grid) ==> v
t = SX.sym('t');

% reformulation 2:
% max(0, v - Pgrid,max) ==> introduce decision variable t
% with 2 conditions: a.) t >= 0 b.) t >= v
% replace max(0, v) ==> t
v = SX.sym('v');

% reformulation 3:
% (P_grid > 0) ==> introduce binary decision variable b (or N_pred binary decision variables b_i)
% b is of size 1xN_pred
% with N_pred big-M conditions: P_grid_i <= M_i*b_i
% so 0 <= M*b - P_grid, M = diag(m_i...), b = [b_i...]
m = 1e4;  % big-M: M_i must be bigger than any possible solution for P_grid_i, but not arbitrarily large
M = diag(m*ones(N_pred, 1));
P_pos = SX.sym('P_pos', N_pred, 1);

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

% linear constraint function lbg <= g(x) <= ubg
% all lbg and ubg may not contain any decision variables, so
% all constraints are rewritten accordingly
g = [
    u_pred;         % upper/lower bound directly on u_pred
    v-P_grid;       % N_pred conditions v >= P_grid_i ==> v - P_grid_i >= 0, compressed into one line in matlab
    t;              % condition t >= 0
    t - v + peak_max_grid;          % condition t >= v
    P_pos;
    P_pos - P_grid;
];

lbg = [
    u_lb;                               % lb on u
    zeros(N_pred, 1);                   % v - P_grid_i >= 0, so N_pred lower bounds of 0
    0;                                  % t >= 0
    0;                                  % t-v >= 0       
    zeros(N_pred, 1);
    zeros(N_pred, 1);
];

ubg = [
    u_ub;                           % ub on u
    Inf*ones(length(P_grid), 1);    % no ub on v - P_grid_i
    Inf;                            % no ub on t
    Inf;                            % no ub on t-v
    1e5*ones(N_pred, 1);
    Inf*ones(N_pred, 1);
];

% if the model is linear, state is linear to input, so state constraints
% realizable as linear constraints
if(modelData.type == 1)
    [A_c, b_c] = prepareStateTrajectoryConstraints(constraints, auxiliaryData, n_x, n_u, n_d, N_pred, x_k, d_pred);
    
    % linear constraint function lbg <= g(x) <= ubg
    % all lbg and ubg may not contain any decision variables, so
    % all constraints are rewritten accordingly

    g = [
        g;
        A_c*u_pred
    ];

    lbg = [
      lbg;
      -Inf*ones(length(A_c*u_pred), 1)   % linear trajectory/state constraints have no lb
    ];

    ubg = [
        ubg;
        b_c;                            % Ax <= b
    ];
end
% vector deciding which of the decision variables are integers
discrete = [ 
    zeros(size(u_pred));
    zeros(size(t));
    zeros(size(v));
    zeros(size(P_pos));
];

% set up MIQP problem
miqp = struct('x', [u_pred; t; v; P_pos], 'f', cost, 'g', g);

options = struct;
%options.discrete = discrete;
if( ~printDiagnostics)
    %options.print_time = false;
    %options.printLevel = "PL_NONE";
end
% set up solver, for now we solve MIQP as MINLP
S = qpsol('S', common.extra.solver, miqp, options);
% set bounds on constraints
sol = S('lbg', lbg, 'ubg', ubg, 'x0', x_opt0);

% retrieve u_opt from optimal solution vector x
x_full = full( sol.x );
u_opt = x_full(1:N_pred*n_u);

% retrieve optimal objective function value
J_opt = full( sol.f );

% starting point for next optimization

x0_init = [
    u_opt(n_u+1:end);
    zeros(n_u, 1);
    0;
    0;
    x_full(N_pred*n_u+1+1+1+1:end);
    0;
];

% todo: retrieve solver result state and return
exitflag = S.stats.success;
description.message = S.stats.return_status;

solverOutput = struct;

solverOutput.exitflag = exitflag;
solverOutput.description = description;

end

function [A_c, b_c]  = prepareStateTrajectoryConstraints(constraints, auxiliaryData, n_x, n_u, n_d, N_pred, x_k, d_pred)
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
    if( ~all( isinf( dx_constraint_lb ) ) )
        A_c = [
            A_c;
            -A_lb_ub_dx;
            ];
        b_c = [
            b_c;
            b_lb_dx;
            ];
    end
    
    if( ~all( isinf( dx_constraint_ub ) ) )
        A_c = [
            A_c;
            A_lb_ub_dx;
            ];
        b_c = [
            b_c;
            b_ub_dx;
            ];
    end
end
