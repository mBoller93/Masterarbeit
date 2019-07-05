# EMS MPC Simulation Framework (EMSF)
The _EMS MPC Simulation Framework_ (EMSF) is a modular MATLAB simulation framework for simulating the control of (monolithic) state space systems using _model predictive control_ (MPC).

The framework was built with the use-case of an Energy Management System (EMS) in mind. This EMS is a central entity within an energy grid, which tries to control energy providers and consumer within its reach in an economically optimal way. 
For this reason, the EMSF has certain features, such as the calculation of arising monetary costs (i.e. energy costs) and (electricity) peak pricing.

Yet, the framework is fully modular and the EMS-specific features are optional, such that it can be used to simulate any state space system controlled using any type of MPC method. 

The EMSF is compatible down to MATLAB 2017b and the shipped MPC implementations require the Optimization Toolbox.

# Usage
The current release of the EMSF contains simulation implementations for simulating a simple EMS with 3 different control methods (eMPC, qMPC, RBC). 

These simulation scripts can be found within the `MatlabScripts` directory

There are 3 simulation scripts shipped with this release:
* `main_script_econ_quad_rulebased_mon_comf.m` will run the simulation to reproduce the results of the handed in report
* `main_script_ems_economic_MPC.m` will simulate the same system, but only with the implemented eMPC
* `main_script_ems_economic_MPC_badpred.m` was used to benchmark the robustness of the implemented eMPC

Other scripts within this directory:
* `convert_plotconf_to_matlab.m` will convert any given `PlotConf_` `*.mat` file back to more accessible MATLAB code
* `create_plotconf_report.m` includes the plot configuration used for creating the report plots as MATLAB code
* `nosify_disturbance.m` was used to add artificial white noise to the prediction data
* `report_plots.m` was used to produce additional plots, that combine data from multiple sources. I.e. plots that can not be easily produced using the built-in plotting feature

# Configuration and Documentation
For all questions regarding this issue, please refer to the distributed documentation.
