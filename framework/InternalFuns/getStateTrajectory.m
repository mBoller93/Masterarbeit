function [x_pred] = getStateTrajectory(u_pred, common, instance)
% GETSTATETRAJECTORY Returns the predicted trajectory over the prediction
% horizon N_pred for a given input trajectory u.
% Inputs:
%   u_pred      A vector containing an input trajectory with Npred entries
%   common     The common struct of the sfsp class
%   instance   The struct of the currently evaluated instance inside the sfsp class
% Outputs:
%   x_pred      The predicted state trajectory for the given input and globally defined disturbance
    N_pred = common.config.N_pred;
    d_pred = instance.state.d_pred;
    x_k_global = instance.state.x_k_global;
    n_x = instance.model.n_x;
    n_u = instance.model.n_u;
    n_d = instance.model.n_d;
    
    x_plus = instance.model.x_plus;
    modelData = instance.model.modelData;
    auxiliaryData = instance.model.auxiliaryData;
    
    % if model is linear, then use precomputed auxiliary matrices,
    % otherwise calculate by iteratively evaluating x_plus
    if( modelData.type == 1 )
        x_pred = auxiliaryData.A_tilda * x_k_global + auxiliaryData.B_tilda*u_pred + auxiliaryData.S_tilda * d_pred;
    else
        x_pred = zeros( n_x*(N_pred+1), 1 );
        x_pred(1:n_x) = x_k_global;
        for i=1:N_pred
           x_pred(i*n_x+1:n_x*(i+1)) = x_plus( ...
               x_pred( (i-1)*n_x+1:n_x*i ), ...
               u_pred( (i-1)*n_u+1:n_u*i ), ...
               d_pred( (i-1)*n_d+1:n_d*i ) ...
           );
        end
    end

end