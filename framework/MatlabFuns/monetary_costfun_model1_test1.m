function [J_monetary] = monetary_costfun_model1_test1(x, u, d, price, k, N)
%MONETARY_COSTFUN_MODEL1_TEST1 calculates the monetary costs for model 1,
%test scenario 1. 

T_s = instance.config.T_s;

% c_grid_buy = price;       % cost per kWh from the grid
% c_grid_feed = 0.07;       % feed-in tariff, gain from selling
c_chp = 0.07;    % cost per kWh from the CHP

eta_rad = .99; % electricity efficiency of electric radiators
eps_c = 2.5; % 'energy efficiency ratio' (EER) of electric chillers


% P_grid = u(1), if P_grid < 0 the EMS is feeding into the grid
% if( u(1) < 0 )
%     c_grid = c_grid_feed;
% else
%     c_grid = c_grid_buy;
% end

% 	J_monetary = 2*[c_grid c_chp_buy 0 0]*u;

% l_mon = T_s/60 * (sum(P_grid'*price_pred_vec) + 0.07*sum(P_chp) + (1/0.95)*sum(Q_rad'*price_pred_vec));


J_monetary = T_s/60 *[price c_chp (1/eta_rad)*price -(1/eps_c)*price]*u;

end