function [ price_pred ] = getPricePrediction(priceSource, d_pred, k, N, T_sim, N_pred, instance)
%GETPRICEPREDICTION Returns a matrix with predicted prices over the prediction horizon
%   Inputs:
%       priceSource         Either a function handle for a price function,
%                           taking k and N_pred as arguments, or a vector with the 1-index
%                           from disturbance vector d_pred that contain price
%                           predictions
%       d_pred              Predicted disturbances over prediction horizon as a vector
%       k                   Current simulation step
%       N                   Total simulation steps
%       T_sim               Simulation time in minutes
%       N_pred              Length of prediction horizon
%   Outputs:
%       cost_pred           Matrix with the predicted costs, where each column i is a price prediction at time k+i

n_d = instance.model.n_d;

% if no price source defined, return NaN as price prediction
if( ~isa(priceSource, 'function_handle') && isnan(priceSource) )      % isnan undefinied for function handle
    price_pred = NaN*zeros(1, N_pred);
    return
end

% retrieve price prediction either by calling handle or by retrieving it
% from disturbance prediction
if( isa(priceSource, 'function_handle') )
    price_pred = priceSource(k, N, T_sim, N_pred, instance);
elseif( length(priceSource) <= n_d && max(priceSource) <= n_d )
    d_pred_matrix = reshape(d_pred, n_d, N_pred);
    price_pred = d_pred_matrix( priceSource, :);
else
    error('invalid price prediction source given, is neither function handle, nor do vector dimensions match')
end

