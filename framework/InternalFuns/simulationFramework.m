function [x_traj_real, x_traj_pred, ...
    u_traj_real, u_traj_pred, ...
    d_traj_real, d_traj_pred, ...
    J_mon_traj_real, J_mon_traj_pred, ...
    J_mon_k_traj_real, J_mon_k_traj_pred, ...
    J_opt_traj_real, J_opt_traj_pred, ...
    J_opt_k_traj_real, J_opt_k_traj_pred, ...
    price_traj_real, price_traj_pred, ...
    peak_cost_traj_real, peak_cost_traj_pred , storageDirectory, paretoData] = simulationFramework(sfsp, instance)

%% Basic simulation configuration
simulationName = sfsp.common.config.simulationName;
modelName = sfsp.instances.(instance).config.modelName;
plotConfigName = sfsp.common.config.plotConfigName;

T_sim = sfsp.common.config.T_sim;
T_s = sfsp.instances.(instance).config.T_s;
N_pred = sfsp.common.config.N_pred;
enableLivePlot = sfsp.common.config.enableLivePlot;
enablePlot = sfsp.common.config.enablePlot;
enablePersistence = sfsp.common.config.enablePersistence;
enableDevMode = sfsp.common.config.enableDevMode;
calculateMonetaryCosts = sfsp.common.config.calculateMonetaryCosts;
enablePeakCosts = sfsp.common.config.enablePeakCosts;

%% Simulation data sources
initialStateSource = sfsp.instances.(instance).config.initialStateSource;
predDisturbanceSource = sfsp.instances.(instance).config.predDisturbanceSource;
realDisturbanceSource = sfsp.instances.(instance).config.realDisturbanceSource;
constraintSource = sfsp.instances.(instance).config.constraintSource;
monetaryCostFun = sfsp.instances.(instance).config.monetaryCostFun;
pricingSource = sfsp.instances.(instance).config.pricingSource;
stageCostFuns = sfsp.instances.(instance).config.stageCostFuns;
finalCostFuns = sfsp.instances.(instance).config.finalCostFuns;
costWeights = sfsp.instances.(instance).config.costWeights;
getInputFun = sfsp.instances.(instance).config.getInputFun;
dynamicConstraintsFun = sfsp.instances.(instance).config.dynamicConstraintsFun;
peakCostFactor = sfsp.instances.(instance).config.peakCostFactor;
initialMaxInput = sfsp.instances.(instance).config.initialMaxInput;

%% Information to save in Log File
mkdir([getRootDir() '/Results/log/']);

logString('====================================\n', 'w');
logString('|                                  |\n');
logString('|     MPC Simulation Framework     |\n');
logString('|                                  |\n');
logString('========= Sim Configuration ========\n');
logString( sprintf('Simulation name: %s\nSimulation Time: %d min \t Step-Width: %d min\nTotal Steps: %d\n', simulationName, T_sim, T_s, T_sim/T_s) );
logString( sprintf('Prediction horizon: %d\n', N_pred) );
logString( sprintf('Plotting enabled: %d\nLive plotting enabled: %d\n', enablePlot, enableLivePlot) );
logString( sprintf('Persisting sim data: %d\n', enablePersistence) );
logString( sprintf('Development mode enabled: %d (no timestamp added to results directory)\n', enablePersistence) );
logString( sprintf('Calculating monetary costs: %d\n', calculateMonetaryCosts) );
logString( sprintf('Loaded and simulated model "%s"\n', modelName) );
logString('\n');

%% Start simulation with confirming configuration
disp('====================================');
disp('|                                  |');
disp('|     MPC Simulation Framework     |');
disp('|                                  |');
disp('========= Sim Configuration ========');
fprintf('Simulation name: %s\nSimulation Time: %d min \t Step-Width: %d min\nTotal Steps: %d\n', simulationName, T_sim, T_s, T_sim/T_s);
fprintf('Prediction horizon: %d\n', N_pred);
fprintf('Plotting enabled: %d\nLive plotting enabled: %d\n', enablePlot, enableLivePlot);
fprintf('Persisting sim data: %d\n', enablePersistence);
fprintf('Development mode enabled: %d (no timestamp added to results directory)\n', enablePersistence);
fprintf('Calculating monetary costs: %d\n', calculateMonetaryCosts);
%% Setup Model
disp('=========== Initializing ===========');
fprintf('Loading and preparing model "%s"\n', modelName);

[n_x, n_u, n_d, x_plus, modelData] = loadModel(modelName);
auxiliaryData = prepareModel(x_plus, modelData, N_pred);
model = struct;
model.n_x = n_x;
model.n_u = n_u;
model.n_d = n_d;
model.x_plus = x_plus;
model.modelData = modelData;
model.auxiliaryData = auxiliaryData;
sfsp.instances.(instance).model = model;

%% Test and adjust data sources
tic
disp('Testing compatibility of specified *.csv and *.mat data sources...');
try
    if( enablePlot )
        disp('Testing plot config...');
        loadPlotConfig(plotConfigName, sfsp.instances.(instance));
    end
    
    disp('Testing constraint file...');
    loadConstraintMatrix(constraintSource, N_pred, 0, T_s, n_x, n_u, n_d);
    loadTime = toc;
    tic
    if( ~isa(predDisturbanceSource, 'function_handle' ) )
        disp('Testing predicted disturbance file...');
        getDisturbance(predDisturbanceSource, n_d, 0, N_pred, T_s, T_sim);
    end
    
    if( ~isa(realDisturbanceSource, 'function_handle' ) )
        disp('Testing real disturbance file...');
        getDisturbance(realDisturbanceSource, n_d, 0, 1, T_s, T_sim);
    end
    
    if( ~isa(pricingSource, 'function_handle') && ~isnan(pricingSource) )
        disp('Testing pricing source vector...');
        getPricePrediction(pricingSource, zeros(n_d, N_pred), 0, N_pred+1, T_sim, N_pred, sfsp.instances.(instance));
    end
    
    if( enablePeakCosts )
        disp('Checking peak cost factor dimensions...');
        if( size( peakCostFactor, 1) ~= 1 || size( peakCostFactor, 2) ~= n_u )
            error( 'peak cost factor malformed' );
        end
    end
    
catch Error
    warning('Specified data source is faulty!');
    %rethrow(Error);
end
clear loadConstraintMatrix; % resetting loadConstraintMatrix' persistent variables

%% check compatibility of all function handles and save Information in log file
disp('Checking compatibility of specified function handles...');
logString('Checking compatibility of specified function handles...\n');

if( isa(predDisturbanceSource, 'function_handle') )
    checkCompatibility(sfsp.common, sfsp.instances.(instance), 'disturbance_function', predDisturbanceSource);
end

if( isa(realDisturbanceSource, 'function_handle') )
    checkCompatibility(sfsp.common, sfsp.instances.(instance), 'real_disturbance_function', realDisturbanceSource);
end

if( isa(monetaryCostFun, 'function_handle') )
    checkCompatibility(sfsp.common, sfsp.instances.(instance), 'monetary_cost_fun', monetaryCostFun);
end

for i=1:numel(finalCostFuns)
    if( isa(finalCostFuns{i}, 'function_handle') )
        checkCompatibility(sfsp.common, sfsp.instances.(instance), 'final_cost_fun', finalCostFuns{i});
    end
end

if( isa(pricingSource, 'function_handle') )
    checkCompatibility(sfsp.common, sfsp.instances.(instance), 'pricing_fun', pricingSource);
end

if( isa(dynamicConstraintsFun, 'function_handle') )
    checkCompatibility(sfsp.common, sfsp.instances.(instance), 'dynamic_constraints_fun', dynamicConstraintsFun);
end

for i=1:numel(stageCostFuns)
    if( isa(stageCostFuns{i}, 'function_handle') )
        checkCompatibility(sfsp.common, sfsp.instances.(instance), 'stage_cost_fun', stageCostFuns{i});
    end
end
setupTime = toc;

% checkCompatibility(sfsp.common, sfsp.instances.(instance), 'get_input_fun', getInputFun, predDisturbanceSource);

%% Determine price dimension
if( ~isa(pricingSource, 'function_handle') )
    n_p = length(pricingSource);
else
    [n_p, ~] = size( ...
        getPricePrediction( pricingSource, zeros(n_d, N_pred), 0, N_pred+1, T_sim, N_pred, sfsp.instances.(instance) ) ...
        );
end
model.n_p = n_p;

%% Set initial state and plots
disp('Setting initial state x0 of simulated system...');
x_k_global = NaN*ones(n_x, 1);
constraints_k0 = loadConstraintMatrix(constraintSource, 2, 0, T_s, n_x, n_u, n_d);  %Constraints for first step
constraints_k0(isnan(constraints_k0(1:n_x,:)))        = -Inf;         %x_lb
constraints_k0(isnan(constraints_k0(n_x+1:2*n_x,:)))  = +Inf;         %x_ub
if( ~isnan(initialStateSource) )
    x_k_global = loadInitialState(initialStateSource, n_x);     %Load initial state from csv
    %Check if given initial state is between constraints:
    if(0==min(constraints_k0(1:n_x) < x_k_global)|| 0==min(x_k_global < constraints_k0(n_x+1:2*n_x)))
        warning('x0 is not between the constraints [x_lb, x_ub] !');
        
        % Information to save in Log File
        logString('x0 is not between the constraints [x_lb, x_ub] !\n');
    end
end
% Initial state not specified of (partially) undefined
if( isempty(x_k_global) || any(isnan(x_k_global)) || any(isnan(initialStateSource)) )
    x_k_global = (constraints_k0(1:n_x, 1)+ constraints_k0(n_x+1:2*n_x, 1))/2;      %Set to value between x_lb and x_ub
    disp('x0 source not set or incompatible, defaulting to fulfill initial state constraint');
    
    % Information to save in Log File
    logString('x0 source not set or incompatible, defaulting to fulfill initial state constraint\n');
    x_k_global(isnan(x_k_global)) =0;                           %Set NaN values to 0 if constraints not specified
end

if( enablePlot )
    disp('Loading plot configuration...');
    plotConfig = loadPlotConfig(plotConfigName, sfsp.instances.(instance));
end

%% Set up trajectory matrices
N = T_sim/T_s;

x_traj_real = zeros(n_x, N+1);
x_traj_real(:, 1) = x_k_global;

u_traj_real = zeros(n_u, N);
d_traj_real = zeros(n_d, N);
price_traj_real = zeros(n_p, N);
peak_cost_traj_real = zeros(1, N);
J_mon_traj_real = zeros(1, N);
J_mon_k_traj_real = zeros(1, N);
J_opt_traj_real = zeros(1, N);
J_opt_k_traj_real = zeros(1, N);

x_traj_pred = zeros(N, n_x*(N_pred+1));
u_traj_pred = zeros(N, n_u*N_pred);
d_traj_pred = zeros(N, n_d*N_pred);
price_traj_pred = zeros(N, n_p*N_pred);
peak_cost_traj_pred = zeros(N, N_pred);
J_mon_traj_pred = zeros(N, 1*N_pred);
J_mon_k_traj_pred = zeros(N, 1*N_pred);
J_opt_traj_pred = zeros(N, 1*N_pred);
J_opt_k_traj_pred = zeros(N, 1*N_pred);
constraints_traj = zeros(2*n_x+2*n_u+2*n_d+2*n_x+2*n_x, N+1);

% Peak cost storage variables
currentPeakCosts = 0;
u_max = zeros(n_u, 1);

%% initialize peak costs
if( ~isnan( initialMaxInput ) )
    u_max = initialMaxInput;
    if( enablePeakCosts )
        currentPeakCosts = peakCostFactor * initialMaxInput;
    end
end

%Set initial vector for fmincon at the beginning to zero
x_opt0 = [];

%% store model information and instance state in sfsp struct
state = struct;
state.x_k_global = x_k_global;
state.u_max = u_max;
state.currentPeakCosts = currentPeakCosts;

sfsp.instances.(instance).model = model;
sfsp.instances.(instance).state = state;

%% Information to save in Log File
logString('\n' );
logString('***');
logString('\n');
logString('Description of fmincon\n');

%% Simulation Loop
disp('========= Simulation Loop ==========');

dispstat('', 'init');

sfsp.instances.(instance).extra.startTime = 24*3600*now;
for k=0:N-1
    if(k == 0)
        tic
        dispstat(sprintf('Overall progress: %f%%', k/N*100));
    else
        elapsedTime = 24*3600*now - sfsp.instances.(instance).extra.startTime;
        remainingTime = sfsp.instances.(instance).extra.simTimeEstimate - elapsedTime;
        dispstat(sprintf('Time remaing: ca. %ss \nOverall progress: %f%%', num2str(round(remainingTime, 0)), k/N*100));
    end
    sfsp.common.state.k = k;
    
    % retrieve disturbance predictions
    d_pred_matrix = getDisturbance(predDisturbanceSource, n_d, k, N_pred, T_s, T_sim);
    d_pred = reshape(d_pred_matrix, numel(d_pred_matrix), 1);
    sfsp.instances.(instance).state.d_pred = d_pred;
    
    % retrieve price predictions
    price_pred = getPricePrediction(pricingSource, d_pred, k, N, T_sim, N_pred, sfsp.instances.(instance));
    sfsp.instances.(instance).state.price_pred = price_pred;
    
    % if disturbance source is function handle, call it
    if( isa(realDisturbanceSource, 'function_handle') )
        d_real = realDisturbanceSource(d_pred_matrix, k);
        % else read real disturbance from configured csv file, analogously to
        % predicted disturbance
    else
        d_real = getDisturbance(realDisturbanceSource, n_d, k, 1, T_s, T_sim);
    end
    sfsp.instances.(instance).state.d_real = d_real;
    
    % retrieve constraints for current prediction horizon
    loopConstraints = loadConstraintMatrix(constraintSource, N_pred, k, T_s, n_x, n_u, n_d);
    sfsp.instances.(instance).state.loopConstraints = loopConstraints;
    
    % if disturbance can be sensed, first predicted disturbance is equal to real disturbance
    if( isfield(sfsp.instances.(instance), 'disturbanceIsSensed') && sfsp.instances.(instance).disturbanceIsSensed)
        d_pred(1:n_d, :) = d_real;
        d_pred_matrix(:, 1) = d_real;
        sfsp.instances.(instance).state.d_pred = d_pred;
    end
    
    % dynamically modify constraints for prediction horizon
    if( isa(dynamicConstraintsFun, 'function_handle') )
        loopConstraints = dynamicConstraintsFun(loopConstraints, N_pred, d_pred_matrix, k, T_s, n_x, n_u, n_d);
        sfsp.instances.(instance).state.loopConstraints = loopConstraints;
    end
    
    %%
    % retrieve (optimal) input sequence
    [u_opt, ~, solverOutput, x_opt0] = getInputFun(loopConstraints, d_pred, modelData, x_k_global, k, N_pred, x_opt0, sfsp.common, sfsp.instances.(instance));
    
    % log message retrieved from input function (i.e. solver ouput)
    logString(strjoin({'k = ', num2str(k), ' -> ' solverOutput.description.message, '\n'}));
    
    x_pred = getStateTrajectory(u_opt, sfsp.common, sfsp.instances.(instance));
    
    J_opt_pred = zeros(1, N_pred);
    J_opt_k_pred = zeros(1, N_pred);
    J_mon_pred = zeros(1, N_pred);
    J_mon_k_pred = zeros(1, N_pred);
    peak_cost_pred = zeros(1, N_pred);
    predPeakCosts_i = currentPeakCosts;
    
    % caclulate predicted monetary costs trajectory and predicted peak cost trajectory
    for i=1:N_pred
        if(calculateMonetaryCosts)
            if i ~= 1
                J_mon_prev = J_mon_pred(i-1);
            elseif k > 0
                J_mon_prev = J_mon_traj_real(k);
            else
                J_mon_prev = 0;
            end
            J_mon_k_pred(i) = monetaryCostFun(x_pred((i-1)*n_x+1:i*n_x), ...
                u_opt((i-1)*n_u+1:i*n_u), d_pred_matrix(:, i), price_pred(:, i), k+i-1, N, sfsp.instances.(instance));
            
            J_mon_pred(i) = J_mon_prev + J_mon_k_pred(i);
        end
        
        if(enablePeakCosts)
            if( peakCostFactor*u_opt((i-1)*n_u+1:i*n_u) > predPeakCosts_i)
                predPeakCosts_i = peakCostFactor*u_opt((i-1)*n_u+1:i*n_u);
            end
            peak_cost_pred(i) =  predPeakCosts_i;
        end
    end
    
    % calculate predicted optimization cost trajectory
    for i=1:N_pred
        if i ~= 1
            J_opt_prev = J_opt_pred(i-1);
        elseif k > 0
            J_opt_prev = J_opt_traj_real(k);
        else
            J_opt_prev = 0;
        end
        for j=1:numel(stageCostFuns)
            stageCostFun = stageCostFuns{j};
            if( isa(stageCostFun, 'function_handle') )
                J_opt_k_pred(i) = J_opt_k_pred(i) + costWeights(j) * stageCostFun(x_pred((i-1)*n_x+1:i*n_x),...
                    u_opt((i-1)*n_u+1:i*n_u), d_pred((i-1)*n_d+1:i*n_d), price_pred(:, i), ...
                    u_max, enablePeakCosts, peakCostFactor, currentPeakCosts, ...
                    loopConstraints, 1, k+i-1, sfsp.common, sfsp.instances.(instance) );
            else
                J_opt_k_pred(i) = 0;
            end
        end
        
        J_opt_pred(i) = J_opt_prev + J_opt_k_pred(i);
    end
    clear getDisturbance;
    % get first element u(0|k) from u_opt
    u_opt_0 = u_opt(1:n_u, :);
    
    % apply first optimal input and real disturbance to model
    x_k_global = x_plus(x_k_global, u_opt_0, d_real);
    sfsp.instances.(instance).state.x_k_global = x_k_global;
    
    % append data to trajectories
    x_traj_real(:, k+2) = x_k_global;
    u_traj_real(:, k+1) = u_opt_0;
    d_traj_real(:, k+1) = d_real;
    constraints_traj(:, k+1) = loopConstraints(1:end-1, 1);
    
    price_real_0 = getPricePrediction(pricingSource, d_real, k, N, T_sim, 1, sfsp.instances.(instance)); % retrieve real occuring price, which may depend on the real disturbance d_real
    price_traj_real(:, k+1) = price_real_0;
    
    % calculate generated monetary cost and add to cost trajectory
    if(calculateMonetaryCosts)
        if(k > 0)
            J_mon_prev = J_mon_traj_real(:, k);
        else
            J_mon_prev = 0;
        end
        
        J_mon_k_traj_real(:, k+1) = monetaryCostFun( x_traj_real(:, k+1), u_opt_0, d_real, price_traj_real(:, k+1), k, N, sfsp.instances.(instance) );
        J_mon_traj_real(:, k+1) = J_mon_prev + J_mon_k_traj_real(:, k+1);
    end
    
    % add optimization costs to opt cost trajectory
    if(k > 0)
        J_opt_prev = J_opt_traj_real(:, k);
    else
        J_opt_prev = 0;
    end

    for j=1:numel(stageCostFuns)
        stageCostFun = stageCostFuns{j};
        if( isa(stageCostFun, 'function_handle') )
            J_opt_k_traj_real(:, k+1) = J_opt_k_traj_real(:, k+1) + ...
                costWeights(j) * stageCostFun( ...
                x_traj_real(:, k+1),...
                u_opt_0, d_real, price_traj_real(:, k+1), ...
                u_max, enablePeakCosts, peakCostFactor, currentPeakCosts, ...
                loopConstraints, 1, k, ...
                sfsp.common, sfsp.instances.(instance) ...
                );
        else
            J_opt_k_traj_real(:, k+1) = 0;
        end
    end
    J_opt_traj_real(:, k+1) = J_opt_prev + J_opt_k_traj_real(:, k+1);
    
    % refresh u_max and calculate peak costs, if enabled
    if( enablePeakCosts )
        if( peakCostFactor*u_opt_0 > peakCostFactor*u_max )
            u_max = u_opt_0;
        end
    else
        if( u_opt_0 > u_max )
            u_max = u_opt_0;
        end
    end
    sfsp.instances.(instance).state.u_max = u_max;
    
    %% calculate peak costs, add peak costs to monetary costs if enabled
    if( enablePeakCosts && calculateMonetaryCosts && sfsp.common.config.addPeakCostsToMonetaryCosts)
        % add predicted peak cost trajectory to predicted monetary cost trajectory
        [value, index] = max(peak_cost_pred);
        actualPeakPred = zeros(1, length(peak_cost_pred));
        actualPeakPred(index) = value - currentPeakCosts;
        J_mon_k_pred = J_mon_k_pred + (actualPeakPred);
        
        previousPeakCosts = currentPeakCosts;
        currentPeakCosts = peakCostFactor * u_max;
        J_mon_traj_real(k+1) = J_mon_traj_real(k+1) + (currentPeakCosts - previousPeakCosts);
        J_mon_k_traj_real(k+1) = J_mon_traj_real(k+1) + (currentPeakCosts - previousPeakCosts);
    end
    
    if( enablePeakCosts )
        peak_cost_traj_real(:, k+1) = currentPeakCosts;
        sfsp.instances.(instance).state.currentPeakCosts = currentPeakCosts;
    end
    
    % store predicted trajectories
    x_traj_pred(k+1, :) = x_pred.';
    u_traj_pred(k+1, :) = u_opt.';
    d_traj_pred(k+1, :) = d_pred.';
    price_traj_pred(k+1, :) = reshape(price_pred, 1, N_pred*n_p);
    peak_cost_traj_pred(k+1, :) = peak_cost_pred.';
    
    J_mon_traj_pred(k+1, :) = J_mon_pred;
    J_mon_k_traj_pred(k+1, :) = J_mon_k_pred;
    J_opt_traj_pred(k+1, :) = J_opt_pred;
    J_opt_k_traj_pred(k+1, :) = J_opt_k_pred;
    
    if(enablePlot && enableLivePlot)
        
        plotValues.x_traj_real = x_traj_real;
        plotValues.x_pred = x_pred;
        plotValues.constraints_traj = constraints_traj;
        plotValues.loopConstraints = loopConstraints;
        plotValues.u_opt = u_opt;
        plotValues.u_traj_real = u_traj_real;
        plotValues.d_pred = d_pred;
        plotValues.d_traj_real = d_traj_real;
        plotValues.d_pred_matrix = d_pred_matrix;
        plotValues.J_mon_traj_real = J_mon_traj_real;
        plotValues.J_mon_k_traj_real = J_mon_k_traj_real;
        plotValues.J_mon_pred = J_mon_pred;
        plotValues.J_mon_k_pred = J_mon_k_pred;
        plotValues.J_opt_traj_real = J_opt_traj_real;
        plotValues.J_opt_k_traj_real = J_opt_k_traj_real;
        plotValues.J_opt_pred = J_opt_pred;
        plotValues.J_opt_k_pred = J_opt_k_pred;
        plotValues.T_s = T_s;
        plotValues.price_pred = price_pred;
        plotValues.price_traj_real = price_traj_real;
        plotValues.peak_cost_pred = peak_cost_pred;
        plotValues.peak_cost_traj_real = peak_cost_traj_real;
        
        if( enablePeakCosts )
            plotValues.peakCosts = currentPeakCosts;
        else
            plotValues.peakCosts = NaN;
        end
        
        live = 1;
        
        plotData(plotConfig,live, plotValues,T_sim, k, [], sfsp.common, sfsp.instances.(instance));
    end
    if(k == 0)
        optTime = toc;
        sfsp.instances.(instance).extra.simTimeEstimate = loadTime + setupTime + (optTime)*1.1*N;
    end
end   %end simulation for-loop
dispstat('Progress: 100%');
simTime = 24*3600*now - sfsp.instances.(instance).extra.startTime;
disp('=============== Done ===============');
fprintf('Simulation done. Took %s minutes\n', num2str(round(simTime/60, 2)) );

% Save Information in log File
filecontent = fileread([getRootDir() '/Results/log/logging.txt']);
newfilecontent = regexprep(filecontent, '***',['Simulation took ' num2str(round(simTime/60, 2)) ' minutes\n']);
logString(newfilecontent, 'w');

%% Set storage directory for trajectories and plots
storageDirectory = simulationName;
if(~enableDevMode)
    storageDirectory = [storageDirectory '_' datestr(now, 'yymmdd_HHMMSS')];
else
    storageDirectory = [storageDirectory '_' datestr(now, 'yymmdd')];
end

%% Persisting simulation results

if(enablePersistence)
    fprintf('Storing simulation results in directory Results/%s...\n', storageDirectory);
    arguments = { x_traj_real, x_traj_pred, ...
        u_traj_real, u_traj_pred, ...
        d_traj_real, d_traj_pred, ...
        J_mon_traj_real, J_mon_traj_pred, ...
        J_mon_k_traj_real, J_mon_k_traj_pred, ...
        J_opt_traj_real, J_opt_traj_pred, ...
        J_opt_k_traj_real, J_opt_k_traj_pred, ...
        price_traj_real, price_traj_pred, ...
        peak_cost_traj_real, peak_cost_traj_pred, ...
        storageDirectory, ...
        sfsp.common
        };
    
    saveSimulationData( arguments{:} );
    %Saving the log file in the appropriate folder
    [~,~] = copyfile([getRootDir() '/Results/log/logging.txt'], [getRootDir() '/Results/', storageDirectory]);
end

%% Creating final plots
if(enablePlot)
    disp('Producing final plots...');
    
    plotValues.x_traj_real = x_traj_real;
    plotValues.x_pred = x_pred;
    plotValues.constraints_traj = constraints_traj;
    plotValues.loopConstraints = loopConstraints;
    plotValues.u_opt = u_opt;
    plotValues.u_traj_real = u_traj_real;
    plotValues.d_pred = d_pred;
    plotValues.d_pred_matrix = d_pred_matrix;
    plotValues.d_traj_real = d_traj_real;
    plotValues.J_mon_traj_real = J_mon_traj_real;
    plotValues.J_mon_k_traj_real = J_mon_k_traj_real;
    plotValues.J_mon_pred = J_mon_pred;
    plotValues.J_mon_k_pred = J_mon_k_pred;
    plotValues.J_opt_traj_real = J_opt_traj_real;
    plotValues.J_opt_k_traj_real = J_opt_k_traj_real;
    plotValues.J_opt_pred = J_opt_pred;
    plotValues.J_opt_k_pred = J_opt_k_pred;
    plotValues.price_pred = price_pred;
    plotValues.price_traj_real = price_traj_real;
    plotValues.peak_cost_pred = peak_cost_pred;
    plotValues.peak_cost_traj_real = peak_cost_traj_real;
    plotValues.T_s = T_s;
    
    live = 0;
    
    plotData(plotConfig, live, plotValues,T_sim, k, storageDirectory, sfsp.common, sfsp.instances.(instance));
    
    % Extension: Save 'plotValues.mat' and overall simulation strucure 'c', so new plots can be created more
    % easily afterwards
    sfsp.common.extra.storageDirectory = storageDirectory;
    save([getRootDir() '/Results/', storageDirectory, '/plots/plotting_data.mat'], 'plotValues', 'sfsp');
end

% Deleting the auxiliary log file
fclose('all');
delete([getRootDir() '/Results/log/logging.txt']);
rmdir([getRootDir() '/Results/log']);

disp('Done.');

end