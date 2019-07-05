function [cost] = stage_cost_fun_model1_mon( x_pred, u_pred, d_pred, price_pred,  ...
    u_max, enablePeakCosts, peakCostFactor, currentPeakCosts, constraints, N_pred, k, ...
    common, instance, ~ ...
)
%STAGE_COST_FUN_MODEL1_MON Summary of this function goes here
%   Detailed explanation goes here

n_u = instance.model.n_u;
T_s = instance.config.T_s;

%Determine input values
P_grid = kron(eye(N_pred), [1 zeros( 1, n_u - 1)])*u_pred;
P_chp =  kron(eye(N_pred), [0 1 zeros( 1, n_u - 2)])*u_pred;
% Q_rad =  kron(eye(N_pred), [0 0 1 zeros( 1, n_u - 3)])*u_pred;
% Q_cool =  kron(eye(N_pred), [0 0 0 1 zeros( 1, n_u - 4)])*u_pred;


% Various scenario settings

% 1.: Peak costs
if enablePeakCosts
    peak_max_grid = [1 zeros(1, n_u-1 )]*u_max;
    cost_peak = peakCostFactor(1);
    l_peakpun = max(0, (max(P_grid)-peak_max_grid)*cost_peak);
else
    l_peakpun = 0;
end

% 2. monetary stage cost
price_pred_vec(1:length(price_pred), 1) = price_pred(:);

% check, if industrial scenario is chosen -> then, c_grid_feed must be used
% instead of the regular buying price from grid
if all(price_pred_vec == 0.131) % industrial scenario
    price_pred_vec(P_grid < 0) = 0.07; % change the kWh-price to feed-in-tarif for all times when P_grid is negative
end                         

l_mon = T_s/60 * (sum(P_grid'*price_pred_vec) + 0.0435*sum(P_chp));

cost = l_mon + l_peakpun;

end
