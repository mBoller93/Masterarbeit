function [cost] = stage_cost_fun_model1_cas_mon( x_pred, u_pred, d_pred, price_pred,  ...
    u_max, enablePeakCosts, peakCostFactor, currentPeakCosts, constraints, N_pred, k, ...
    common, instance, vars ...
)
if nargin < 14
    vars = 0;
end
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
    
    if( isstruct( vars ) )
        l_peakpun = vars.t*cost_peak;
    else
        % temporary workaround for additional decision vars
        l_peakpun = max(0, (max(P_grid)-peak_max_grid)*cost_peak); 
    end
else
    l_peakpun = 0;
end

% 2. monetary stage cost
price_pred_vec(1:length(price_pred), 1) = price_pred(:);
c_grid_sell = 0.07;

% all positive (incoming) powers in P_grid are weighted with the buy-in
% price and summed
if( isstruct(vars) )
    l_buy = ones(1, N_pred) * diag(price_pred_vec) * vars.P_pos;
else
    l_buy = (P_grid > 0)' * diag( price_pred_vec ) * P_grid;
end

% check, if industrial scenario is chosen -> then, c_grid_feed must be used
% instead of the regular buying price from grid
if( instance.config.extra.feed_in_fix )
    % all negative (feed-in) powers in P_grid are weighted with the feed-in
    % tariff and summed
    C_feed_in = diag( c_grid_sell * ones(N_pred, 1) );
else
    C_feed_in = diag( price_pred_vec );
end

if( isstruct(vars) )
    l_sell = -ones(1, N_pred) * C_feed_in * (P_grid - vars.P_pos);
else
    l_sell = (P_grid < 0)' * C_feed_in * P_grid;
end

l_chp = 0.0435*ones(1, length(P_chp))*P_chp;

% sum all costs and scale them to the step width, as costs are per kWh
l_mon = T_s/60 * ( l_buy + l_sell  + l_chp );

cost = l_mon + l_peakpun;

end
