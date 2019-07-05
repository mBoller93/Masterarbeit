function [u_opt, J_opt, solverOutput, x_opt0] = get_input_u_MPC(constraints, d_pred, modelData, x_k, k, N_pred, x_opt0, common, instance)
%Function to find optimal input values u_opt minimizing a cost function
%Inputs: constraints...Matrix containing constraints values
%        d_pred ...    vector of predicted disturbances
%        modelData ... struct with model data
%        x_k ...       state vector at current step k
%        k ...         current step k
%        N_pred...     size of prediction horizon
%        u0 ...        initial vector for optimization
%Outputs:u_opt...      vector with optimal input values, size n_d*N_pred x 1
%        J_opt...      scalar value of minimized costs
%        description   solver output


printDiagnostics = common.config.printDiagnostics;
auxiliaryData = instance.model.auxiliaryData;
n_x = instance.model.n_x;
n_u = instance.model.n_u;
n_d = instance.model.n_d;

costfun = @(u_pred)(costFunction(u_pred, common, instance));                %Set cost function handle

% use previous solution as initial value for current optimization
u0 = x_opt0;

u_lb = zeros(N_pred*n_u, 1);            %Create constraint vectors from big constraints matrix: u_lb< u <u_ub
u_ub = zeros(N_pred*n_u, 1);
for i=0:N_pred-1
    u_lb(i*n_u+1:(i+1)*n_u) = constraints(2*n_x+1:2*n_x+n_u, i+1);
    u_ub(i*n_u+1:(i+1)*n_u) = constraints(2*n_x+n_u+1:2*n_x+2*n_u, i+1);
end
u_lb(isnan(u_lb)) = -Inf;               %NaN values changed to -Inf
u_ub(isnan(u_ub)) = +Inf;               %NaN values changed to +Inf

% Set the correct option for FMINCON
if(printDiagnostics)
%     options = optimoptions(@fmincon,'Display','final','MaxFunctionEvaluations',8000); % was 8000
    options = optimoptions(@fmincon,'Display','final','MaxFunctionEvaluations',16000,'Algorithm','sqp'); % , 'Display','iter' was 8000
else
    options = optimoptions(@fmincon,'Display','off','MaxFunctionEvaluations',5e4,'Algorithm','sqp');
end

if(modelData.type == 1)                 %Linear model -> constraints for x possible
    
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
    
    if(isempty(u0))
        u0 = zeros(N_pred*n_u, 1);
    end
    
    [u_opt, J_opt, exitflag, description] = fmincon(costfun, u0, A_c, b_c,[], [], u_lb, u_ub, [], options);
    solverOutput = struct;

elseif(modelData.type == 0)      % Nonlinear model
    
    [u_opt, J_opt, exitflag, description] = fmincon(costfun, u0,[], [],[], [], u_lb, u_ub, [], options);
    
end

% shift solution to prepare it as initial value for next time step
u0 = [u_opt(n_u+1:(N_pred)*n_u); zeros(n_u, 1)];     
x_opt0 = u0;

solverOutput.exitflag = exitflag;
solverOutput.description.message = description.message;

end

