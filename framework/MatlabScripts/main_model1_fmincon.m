%% Clear workspace and include framework functions and user-defined functions
clear all;
close all;
clc;
addpath('../InternalFuns');
addpath('../InternalClasses');
addpath('../MatlabFuns');

T_s = 30;
scen = 1;

commonConfig.simulationName = 'model1_scen1_winter_presentation';
commonConfig.plotConfigName = 'plotconf_model1_advisory_report.mat';
commonConfig.T_sim = 1*24*60/16;
commonConfig.N_pred = 2*60/T_s;
commonConfig.enableLivePlot = 0;
commonConfig.enablePlot = 1;
commonConfig.enablePersistence = 1;
commonConfig.enableDevMode = 1;
commonConfig.printDiagnostics = 0; 
commonConfig.calculateMonetaryCosts = 1;
commonConfig.addPeakCostsToMonetaryCosts = 1;

instances = struct;

instance0 = struct;
instance0.T_s = T_s;
instance0.modelName = 'model1_soc_thetaa_electric_radiator.mat';
instance0.initialStateSource = NaN;
instance0.predDisturbanceSource = 'dataset2018_model1.csv';
instance0.realDisturbanceSource = instance0.predDisturbanceSource;
instance0.disturbanceIsSensed = 1;
instance0.constraintSource = 'test1_model1_constraints.mat';
instance0.stageCostFuns = { @stage_cost_fun_model1_mon, @stage_cost_fun_model1_comf };
instance0.finalCostFuns = {};
instance0.costWeights = [0.2 0.8];
instance0.getInputFun = @get_input_u_MPC;
instance0.dynamicConstraintsFun = NaN;

switch scen
    case 1
        commonConfig.enablePeakCosts = 1; % boolean, enable/disable peak costs to be added to monetary costs
        instance0.pricingSource = @pricing_fun_industry_2018;
        instance0.monetaryCostFun = @monetary_costfun_model1_industry_2018; % monetary_cost_fun function-handle within /MatlabFuns/ or NaN 
        instance0.peakCostFactor = [76 0 0 0]; % vector of dimension 1 x n_u, peak costs will be calculated by peakCostFactor * u_max
        instance0.initialMaxInput = [180 0 0 0]';
    case 2
        commonConfig.enablePeakCosts = 1; % boolean, enable/disable peak costs to be added to monetary costs
        instance0.pricingSource = @pricing_fun_intraday_2018;
        instance0.monetaryCostFun = @monetary_costfun_model1_intraday_2018; % monetary_cost_fun function-handle within /MatlabFuns/ or NaN 
        instance0.peakCostFactor = [76 0 0 0]; % vector of dimension 1 x n_u, peak costs will be calculated by peakCostFactor * u_max
        instance0.initialMaxInput = [180 0 0 0]';
    case 3
        commonConfig.enablePeakCosts = 0; % boolean, enable/disable peak costs to be added to monetary costs
        instance0.pricingSource = @pricing_fun_intraday_2018;
        instance0.monetaryCostFun = @monetary_costfun_model1_intraday_2018; % monetary_cost_fun function-handle within /MatlabFuns/ or NaN 
        instance0.peakCostFactor = [0 0 0 0];
        instance0.initialMaxInput = [0 0 0 0]';
    case 4
        commonConfig.enablePeakCosts = 1; % boolean, enable/disable peak costs to be added to monetary costs
        instance0.pricingSource = @pricing_fun_sinus;
        instance0.monetaryCostFun = @monetary_costfun_model1_intraday_2018; % monetary_cost_fun function-handle within /MatlabFuns/ or NaN 
        instance0.peakCostFactor = [100 0 0 0]; % vector of dimension 1 x n_u, peak costs will be calculated by peakCostFactor * u_max
        instance0.initialMaxInput = [200 0 0 0]';
end

instances.instance0 = instance0;



sfsp = prepareSimulation(commonConfig, instances);
results = simulationFramework(sfsp, 'instance0');