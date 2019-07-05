function checkCompatibility(common, instance, varargin)
% CHECK_COMPATIBILITY This function checks for the compatibility of any function handle loaded by the framework
%   This function takes any number of input arguments, but at least 2 are required, the first being the name of the check to be performed
%   This function displays warnings or raises errors, if a compatibility check fails. Otherwise, it prints a success message
%   Futhermore all the information about the check of the compatibility is saved in a log file
% Inputs:
%    common      The common struct of the sfsp class
%    instance    The struct of the currently evaluated instance inside the sfsp class
%    name        Name of the type of handle to be tested
%    handle      The function handle to test

N_pred = common.config.N_pred;
enablePeakCosts = common.config.enablePeakCosts;

n_x = instance.model.n_x;
n_u = instance.model.n_u;
n_d = instance.model.n_d;
modelData = instance.model.modelData;

peakCostFactor = instance.config.peakCostFactor;

numVargin = length(varargin);
if numVargin < 2
    warning('checkCompatibility must be called with at least two arguments');
end

check = varargin{1};
switch(check)
    case 'monetary_cost_fun'
        functionHandle = varargin{2};
        handleInfo = functions( functionHandle );
        
        if( ~doesFunctionHandleExist( functionHandle ) )
            warning( 'Compatibility check: provided monetary cost function %s not found!', handleInfo.function )
            return;
        end
        
        try
            J_monetary = functionHandle( ones(n_x, 1), ones(n_u, 1), zeros(n_d, 1), 0, 0, 10, instance );
            if( isscalar(J_monetary) )
                logString(sprintf('Compatibility check: provided monetary cost function %s is compatible!\n', handleInfo.function));
                fprintf('Compatibility check: provided monetary cost function %s is compatible!\n', handleInfo.function );
            else
                error('monetary cost must be scalar');
            end
        catch ME
            warning( 'Compatibility check: provided monetary cost function %s is incompatible!', handleInfo.function )
        end
        
    case 'disturbance_function'
        functionHandle = varargin{2};
        handleInfo = functions( functionHandle );
        
        if( ~doesFunctionHandleExist( functionHandle ) )
            warning( 'Compatibility check: provided disturbance function %s not found!', handleInfo.function )
            return;
        end
        
        try
            d_test = functionHandle(1, n_d);
            if(n_d~=size(d_test, 1) || 1~=size(d_test, 2))
                warning('Compatibility check: disturbance function returns vector of wrong size');
            else
                logString(sprintf('Compatibility check: disturbance function is compatible!\n'));
                fprintf('Compatibility check: disturbance function is compatible!\n');
            end
        catch ME
            warning('Compatibility check: disturbance function %s is incompatible', handleInfo.function );
        end
        
    case 'real_disturbance_function'
        functionHandle = varargin{2};
        handleInfo = functions( functionHandle );
        
        if( ~doesFunctionHandleExist( functionHandle ) )
            warning( 'Compatibility check: provided real disturbance function %s not found!', handleInfo.function )
            return;
        end
        
        try
            d_test2 = functionHandle(ones(n_d, N_pred), 1);
            if(n_d~=size(d_test2, 1)|| 1~=size(d_test2, 2)) %Check if output has size n_d x 1
                warning('Compatibility check: function for real disturbance returns vector of wrong size');
            else
                logString(sprintf('Compatibility check: function for real disturbance is compatible!\n'));
                fprintf('Compatibility check: function for real disturbance is compatible!\n');
            end
        catch ME
            warning('Compatibility check: real disturbance function %s is incompatible', handleInfo.function );
        end
        
    case 'get_input_fun'
        funHandInpFun = varargin{2};
        
        testInstance = instance;
        testInstance.state.x_k_global = zeros(n_x, 1);
        testInstance.state.d_pred = zeros(n_d*N_pred, 1);
        testInstance.state.price_pred = ones(N_pred, 1);
        testInstance.state.loopConstraints = NaN*ones(4*n_x+2*n_d+2*n_u+2*n_x, N_pred);
        testInstance.state.u_max = zeros(n_u, 1);
        testInstance.state.currentPeakCosts = 0;
        
        handleInfo = functions( funHandInpFun );
        
        if( ~doesFunctionHandleExist( funHandInpFun ) )
            warning( 'Compatibility check: provided get_input function %s not found!', handleInfo.function )
            return;
        end
        
        try
            warning('off');
            [u_test, J_test, ~, ~] = funHandInpFun(testInstance.state.loopConstraints, testInstance.state.d_pred, modelData, zeros(n_x, 1), 1, N_pred, [], common, testInstance);
            warning('on');
            if( size(u_test, 1) ~= N_pred*n_u || size(u_test, 2) ~= 1 || size(J_test, 1) ~= 1 || size(J_test,2) ~= 1 )
                warning('Compatibility check: get_input function returns values of wrong size');
            else
                logString(sprintf('Compatibility check: get_input function is compatible!\n'));
                fprintf('Compatibility check: get_input function is compatible!\n');
            end
        catch ME
            warning('Compatibility check: get_input function is incompatible');
            rethrow(ME)
        end
        
    case 'stage_cost_fun'
        stageCostFun = varargin{2};
        handleInfo = functions( stageCostFun );
        
        if( ~doesFunctionHandleExist( stageCostFun ) )
            warning( 'Compatibility check: provided stage cost function %s not found!', handleInfo.function )
            return;
        end
        
        N_pred_test = 5;
        d_pred_test = zeros(n_d*N_pred_test, 1);
        price_pred_test = zeros(N_pred_test, 1);
        x_pred = zeros(n_x*(N_pred_test+1), 1);
        u_opt = zeros(n_u*N_pred_test, 1);
        constraints = zeros(2*n_x+2*n_u+2*n_d+2*n_x+2*n_x, N_pred_test+1);
        u_max = zeros(n_u, 1);
        try
            stageCost = stageCostFun( x_pred, u_opt, d_pred_test, price_pred_test, u_max, enablePeakCosts, peakCostFactor, 0, constraints, N_pred_test, 0, common, instance );
            if( isscalar(stageCost) )
                logString(sprintf('Compatibility check: provided stage cost function %s is compatible!\n', handleInfo.function));
                fprintf( 'Compatibility check: provided stage cost function %s is compatible!\n', handleInfo.function );
            else
                error('stage cost must be scalar');
            end
        catch ME
            warning( 'Compatibility check: provided stage cost function %s is incompatible!', handleInfo.function )
        end
    case 'final_cost_fun'
        finalCostFun = varargin{2};
        
        handleInfo = functions( finalCostFun );
        x_pred_N = zeros(n_x, 1);
        finalConstraints = zeros(2*n_x+2*n_u+2*n_d+2*n_x+2*n_x, 1);
        
        if( ~doesFunctionHandleExist( finalCostFun ) )
            warning( 'Compatibility check: provided final cost function %s not found!', handleInfo.function )
            return;
        end
        
        try
            V_f = finalCostFun( x_pred_N, finalConstraints, 5, 0, common, instance );
            if( isscalar( V_f ) )
                logString(sprintf('Compatibility check: provided final cost function %s is compatible!\n', handleInfo.function));
                fprintf( 'Compatibility check: provided final cost function %s is compatible!\n', handleInfo.function );
            else
                error('final cost must be scalar');
            end
        catch
            warning( 'Compatibility check: provided final cost function %s is incompatible!', handleInfo.function )
        end
        
    case 'pricing_fun'
        pricingFunction = varargin{2};
        handleInfo = functions( pricingFunction );
        
        if( ~doesFunctionHandleExist( pricingFunction ) )
            warning( 'Compatibility check: provided pricing function %s not found!', handleInfo.function )
            return;
        end
        
        try
            cost_prediction = pricingFunction(0, 2*N_pred, 24*60, N_pred, instance);
            logString(sprintf('Compatibility check: provided pricing function %s is compatible!\n', handleInfo.function ));
            fprintf( 'Compatibility check: provided pricing function %s is compatible!\n', handleInfo.function )
        catch
            warning( 'Compatibility check: provided pricing function %s is incompatible!', handleInfo.function )
        end
        
    case 'dynamic_constraints_fun'
        dynamicConstraintsFun = varargin{2};
        handleInfo = functions( dynamicConstraintsFun );
        
        if( ~doesFunctionHandleExist( dynamicConstraintsFun ) )
            warning( 'Compatibility check: provided dynamic constraints function %s not found!', handleInfo.function )
            return;
        end
        
        try
            constraints = zeros(2*n_x+2*n_u+2*n_d+2*n_x+2*n_x, N_pred);
            d_pred_matrix = ones(n_d, N_pred);
            k = 0;
            T_s = 30;
            modifiedConstraints = dynamicConstraintsFun(constraints, N_pred, d_pred_matrix, k, T_s, n_x, n_u, n_d);
            if( ~isequal( size(modifiedConstraints), size(constraints) ) )
                warning( 'Compatibility check: provided dynamic constraints function %s returns constraint matrix of wrong size!', handleInfo.function )
            else
                fprintf( 'Compatibility check: provided dynamic constraints function %s is compatible!\n', handleInfo.function )
            end
        catch E
            warning( 'Compatibility check: provided dynamic constraints function %s is incompatible!', handleInfo.function )
        end
end
end

function [result] = doesFunctionHandleExist( functionHandle )
handleInfo = functions( functionHandle );
result = ~(isempty(handleInfo.file) && handleInfo.type ~= "anonymous");
end