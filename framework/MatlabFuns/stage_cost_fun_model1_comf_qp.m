function [cost] = stage_cost_fun_model1_cas_mon( x_pred, u_pred, d_pred, price_pred,  ...
    u_max, enablePeakCosts, peakCostFactor, currentPeakCosts, constraints, N_pred, k, ...
    common, instance, vars ...
)
if nargin < 13
    vars = struct;
    vars.t = 0;
    vars.v = 0;
end

%STAGE_COST_FUN_MODEL1_MON Summary of this function goes here
%   Detailed explanation goes here

% if stage cost function is called for only one timestep, kronecker product
% won't work
if N_pred > 1
    theta_b_pred = kron(eye(N_pred+1), [0 1])*x_pred;
else
    theta_b_pred = x_pred(2);
end

p1 = 200;    %for deviation from 22°C
p2 = 10000; %for soft constraints of theta_b

% quadratic deviation from mean in form (x-c)'*(x-c)
l_comf = p1 * (theta_b_pred - 22).' * eye( length( theta_b_pred ) ) * (theta_b_pred - 22);

cost = l_comf;

end

