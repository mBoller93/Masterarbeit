function [cost] = stage_cost_fun_model1_mon( x_pred, u_pred, d_pred, price_pred,  ...
    u_max, enablePeakCosts, peakCostFactor, currentPeakCosts, constraints, N_pred, k, ...
    common, instance, ~ ...
)
%STAGE_COST_FUN_MODEL1_MON Summary of this function goes here
%   Detailed explanation goes here
theta_b_pred = x_pred(2:2:end)';

p1 = 200;    %for deviation from 22°C
p2 = 10000; %for soft constraints of theta_b

l_comf = p1 * sum((theta_b_pred - 22*ones(1,length(theta_b_pred))).^2);

cost = l_comf;

end

