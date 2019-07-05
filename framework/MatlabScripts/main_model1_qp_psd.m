%% Clear workspace and include framework functions and user-defined functions
clear all;
close all;
clc;
addpath('../InternalFuns');
addpath('../InternalClasses');
addpath('../MatlabFuns');

T_s = 30;
scen = 1;

commonConfig.plotConfigName = 'plotconf_model1_advisory_report.mat';
commonConfig.T_sim = 3*24*60;
commonConfig.N_pred = 8*60/T_s;
commonConfig.enableLivePlot = 0;
commonConfig.enablePlot = 1;
commonConfig.enablePersistence = 1;
commonConfig.enableDevMode = 1;
commonConfig.printDiagnostics = 0; 
commonConfig.calculateMonetaryCosts = 1;
commonConfig.addPeakCostsToMonetaryCosts = 1;

commonExtra = struct;
commonExtra.solver = 'qpoases';
commonExtra.casadiPath = '~/Documents/casadi';
% commonExtra.solver = 'cplex';
% commonExtra.casadiPath = '~/Tools/casadi/build/matlab';

commonConfig.simulationName = ['benchmark_scen' num2str(scen) '_24h_casadi_qp_' commonExtra.solver ];

instances = struct;

instance0 = struct;
instance0.T_s = T_s;
instance0.modelName = 'model1_soc_thetaa_electric_radiator.mat';
instance0.initialStateSource = NaN;
instance0.predDisturbanceSource = 'dataset2018_model1.csv';
instance0.realDisturbanceSource = instance0.predDisturbanceSource;
instance0.disturbanceIsSensed = 1;
instance0.constraintSource = 'test1_model1_constraints.mat';
instance0.stageCostFuns = { @stage_cost_fun_model1_mon_qp, @stage_cost_fun_model1_comf_qp };
instance0.finalCostFuns = {};
instance0.costWeights = [0.2 0.8];
instance0.getInputFun = @get_input_u_casadi_qp_psd;
instance0.dynamicConstraintsFun = NaN;
instance0.pareto.objectives = [1 2];
instance0.pareto.evalResultState = [0 1];
instance0.pareto.labels = {'Costs', 'Comfort'};
instance0.pareto.objectiveFilters = { NaN, @(cost, N_pred, average)( (average == 1)*sqrt(cost/200/N_pred) + (average ~= 1)*sqrt(cost/200) ) };
instance0.pareto.evalSubject = 2;
instance0.pareto.evalStart = 0.1;
instance0.pareto.evalEnd = 1000;
instance0.pareto.evalSteps = 20;
instance0.pareto.defaultWeights = [1 1];
instance0.pareto.enablePlot = 1;
instance0.pareto.enableLivePlot = 0;
instance0.pareto.plotSummedHorizons = 1;
instance0.pareto.plotIndividualHorizons = 1;
instance0.pareto.plotFinalHorizons = 0;
instance0.pareto.interactive = 1;
% instance0.pareto.evalVector = linspace(0.1, 1000, 100);

switch scen
    case 1
        commonConfig.enablePeakCosts = 1; % boolean, enable/disable peak costs to be added to monetary costs
        instance0.pricingSource = @pricing_fun_industry_2018;
        instance0.monetaryCostFun = @monetary_costfun_model1_industry_2018; % monetary_cost_fun function-handle within /MatlabFuns/ or NaN 
        instance0.peakCostFactor = [76 0 0 0]; % vector of dimension 1 x n_u, peak costs will be calculated by peakCostFactor * u_max
        instance0.initialMaxInput = [180 0 0 0]';
        instance0.extra.feed_in_fix = 1;

    case 2
        commonConfig.enablePeakCosts = 1; % boolean, enable/disable peak costs to be added to monetary costs
        instance0.pricingSource = @pricing_fun_intraday_2018;
        instance0.monetaryCostFun = @monetary_costfun_model1_intraday_2018; % monetary_cost_fun function-handle within /MatlabFuns/ or NaN 
        instance0.peakCostFactor = [76 0 0 0]; % vector of dimension 1 x n_u, peak costs will be calculated by peakCostFactor * u_max
        instance0.initialMaxInput = [180 0 0 0]';
        instance0.extra.feed_in_fix = 0;

    case 3
        commonConfig.enablePeakCosts = 0; % boolean, enable/disable peak costs to be added to monetary costs
        instance0.pricingSource = @pricing_fun_intraday_2018;
        instance0.monetaryCostFun = @monetary_costfun_model1_intraday_2018; % monetary_cost_fun function-handle within /MatlabFuns/ or NaN 
        instance0.peakCostFactor = [0 0 0 0];
        instance0.initialMaxInput = [0 0 0 0]';
        instance0.extra.feed_in_fix = 0;
    case 4
        commonConfig.enablePeakCosts = 1; % boolean, enable/disable peak costs to be added to monetary costs
        instance0.pricingSource = @pricing_fun_sinus;
        instance0.monetaryCostFun = @monetary_costfun_model1_intraday_2018; % monetary_cost_fun function-handle within /MatlabFuns/ or NaN 
        instance0.peakCostFactor = [100 0 0 0]; % vector of dimension 1 x n_u, peak costs will be calculated by peakCostFactor * u_max
        instance0.initialMaxInput = [200 0 0 0]';
        instance0.extra.feed_in_fix = 0;

end

instances.instance0 = instance0;

sfsp = prepareSimulation(commonConfig, instances, commonExtra);
results = simulationFramework(sfsp, 'instance0');