function [cost_pred] = pricing_fun_intraday_2018(k, N, T_sim, N_pred, instance)
%PRICING_FUN_INTRADAY_2018 Uses data for the German 2018 intraday market as
%prices. It reads them from '../Data/pricing_intraday_2018.mat'
%   k: current simulation step
%   N: Total simulation steps (for whatever reason)
%   T_sim: Total simulation time
%   N_pred: Number of steps in prediction horizon

T_s = instance.config.T_s;

prices_struct = load('../Data/pricing_intraday_2018.mat');
pricematrix = prices_struct.price_matrix_intraday_2018;

tvec_sim = k*T_s:T_s:(k+N_pred-1)*T_s;

% price sours is in €/MWh, so multiply by 1e-3
cost_pred = 1e-3 * interp1(pricematrix(1,:), pricematrix(2,:), tvec_sim);

end

