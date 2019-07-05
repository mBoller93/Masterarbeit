function [J_monetary] = monetary_costfun_model1_industry_2018(x, u, d, price, k, N, instance)
%MONETARY_COSTFUN_MODEL1_TEST1 calculates the monetary costs for model 1,
%test scenario 1. 

T_s = instance.config.T_s;


c_grid_feed = 0.07;       % feed-in tariff, gain from selling
c_chp = 0.0435;    % cost per kWh from the CHP

if u(1) < 0
    c_grid = c_grid_feed;
else
    c_grid = price;
end

J_monetary = T_s/60 *[c_grid c_chp 0 0]*u;

end