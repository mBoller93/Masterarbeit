function [J_monetary] = monetary_costfun_model1_intraday_2018(x, u, d, price, k, N, instance)
%MONETARY_COSTFUN_MODEL1_TEST1 calculates the monetary costs for model 1,
%test scenario 1. 

T_s = instance.config.T_s;

c_chp = 0.0435;    % cost per kWh from the CHP

J_monetary = T_s/60 *[price c_chp 0 0]*u;

end