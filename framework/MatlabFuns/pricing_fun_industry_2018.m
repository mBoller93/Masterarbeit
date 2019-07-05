function [cost_pred] = pricing_fun_industry_2018(k, N, T_sim, N_pred, instance)
%PRICING_FUN_INDUSTRY_2018 Uses uses fixed pricing, i.e. 0.13 Euro/kWh.
%Peak costs need to be respected additionally. 
%   k: current simulation step
%   N: Total simulation steps (for whatever reason)
%   T_sim: Total simulation time
%   N_pred: Number of steps in prediction horizon

cost_pred(1:N_pred) = 0.131; 
end

