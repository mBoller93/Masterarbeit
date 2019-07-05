function [cost_pred] = pricing_fun_sinus(k, N, T_sim, N_pred, instance)
%PRICING_FUN_TEST Sinusoid energy cost with average at 0.11�/kWh
%   k: current simulation step
%   N: Total simulation steps (for whatever reason)
%   T_sim: Total simulation time
%   N_pred: Number of steps in prediction horizon

T_s = instance.config.T_s;
if(isempty(T_s))
    T_s = 30;
end
price_base = 0.20; % 0.13€/kWh
sin_amp = price_base/2;
periods = 2; 


% cost_day = [];
% for i=0:N-1+N_pred
%     if( i*T_s < 5*60)
%         cost_day(i+1) = price_base;
%     elseif( 5*60 <= i*T_s && i*T_s < 18*60)
%         j = i - 5*60/T_s;
%         T = 26;
%         cost_day(i+1) = price_base + 0.03*sin(2*pi/T*j).^2;
%     else
%         j2 = i - 18*60/T_s;
%         T2 = 22;
%         cost_day(i+1) = price_base - 0.01*sin(2*pi/T2*j2);
%     end
% end
cost_pred = sin_amp*sin((k*T_s:T_s:(k+N_pred-1)*T_s)*(periods*2*pi/T_sim))+price_base;

end