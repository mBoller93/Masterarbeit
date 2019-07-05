function [ J_opt ] = costFunction( u_pred, common, instance, vars )
%COSTFUNCTION Cost function called by optimization functions
%   Calculates the optimization cost according to the specified stage and
%   final cost functions. If final cost function handle is set to numerical
%   value, it is ignored
% Inputs:
%    u_pred     A vector containing an input trajectory with N_pred entries
%    common     The common struct of the sfsp class
%    instance   The struct of the currently evaluated instance inside the sfsp class
% Outputs:
%    J_opt      The total stage and final costs for the given trajectory

    if( nargin < 4 )
       vars = 0; 
    end

    k = common.state.k;
    N_pred = common.config.N_pred;
    loopConstraints = instance.state.loopConstraints;
    d_pred = instance.state.d_pred;
    price_pred = instance.state.price_pred;
    u_max = instance.state.u_max;
    
    enablePeakCosts = common.config.enablePeakCosts;
    peakCostFactor = instance.config.peakCostFactor;
    currentPeakCosts = instance.state.currentPeakCosts;
    
    stageCostFuns = instance.config.stageCostFuns;
    finalCostFuns = instance.config.finalCostFuns;
    costWeights = instance.config.costWeights;
    
    % calculate state trajectory for given predicted input sequence
    x_pred = getStateTrajectory(u_pred, common, instance);
    n_x = instance.model.n_x;
    
    % arguments for stageCostFun as cell array, in order to conditionally
    % append arguments
    arguments = {
        x_pred, ...
       u_pred, ... 
       d_pred, ... 
       price_pred, ... 
       u_max, ... 
       enablePeakCosts, ... 
       peakCostFactor, ... 
       currentPeakCosts, ... 
       loopConstraints, ... 
       N_pred, ...
       k, ...
       common, ...
       instance ...
    };

    if(nargin == 4)
       arguments{end+1} = vars;
    end
    
    % calculate stage cost over prediction horizon using configured function handle
    stageCost = 0;
    for i=1:numel(stageCostFuns)
       stageCostFun = stageCostFuns{i};
       cost_i = stageCostFun(arguments{:});
       stageCost = stageCost + costWeights(i) * cost_i;
    end
    
    % calculate final costs if defined
    finalCost = 0;
    if( iscell(finalCostFuns) && ~isempty(finalCostFuns) )
        x_pred_N = x_pred(N_pred*n_x+1:end);
        finalConstraints = loopConstraints(:, N_pred);
                
        finalArguments = {
            x_pred_N, ...
            finalConstraints, ...
            N_pred, ...
            k, ...
            common, ...
            instance ...
        };
    
        if(nargin == 4)
            finalArguments{end+1} = vars;
        end
    
        for i=1:numel(finalCostFuns)
            finalCostFun = finalCostFuns{i};
            if( isa(finalCostFun, 'function_handle') )
                finalCost = finalCost + finalCostFun(finalArguments{:});
            end
        end
    end
    
    J_opt = stageCost + finalCost;
end

