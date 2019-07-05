function [model1_name] = create_model1( DT, method)
%CREATE_MODEL1 Discretizes 'model1' with given DT and method and saves the
%.mat file with system matrices in the given path. 
% DT: discretization time in minutes (!)
% method: either 'c2d' for matlab-c2d, or 'diffEq' for integration by hand

%Create model1_soc_thetaa_electric_radiator.mat file for the simplified model with: 

% States: SoC (stationary battery) and building temperature theta
% Inputs: P_grid, P_chp, Q_rad, Q_cool
% Disturbances: P_ren, P_dem, theta_a (outside air temperature), Q_other

%% Step zero: convert DT from minutes into hours -> test
DT = DT/60;

%% First Step: Set constants of differnetial equations

% Building Temperature ODE : 
% C_th*d theta_b/dt = -H(theta_b-theta_a) + 1/c_chp * P_chp + Q_rad + Q_cool + Q_others 

H_a = 34193.8469*1e-3; % heat transfer coefficient. *1e-3 for kW/K instead of W/K
C_th = 1792064*1e-3;%*60; % thermal capacity. *1e-3 for kW instead of W, NOT*60 because it was given in Wh, not Wmin (?) % 1792064 in Wh/K

c_chp = 0.677; % 'current constant', so that P_chp = c_chp * Q_h_chp
eta_rad = .99; % electricity efficiency of electric radiators
eps_c = 2.5; % 'energy efficiency ratio' (EER) of electric chillers

%% Second step: continuous model
Acont = [0, 0; 
         0 -H_a/C_th];
Bcont = [1 1 -1/eta_rad +1/eps_c; 
         0 1/(c_chp*C_th) 1/C_th 1/C_th];
Scont = [1 1 0 0;
        0 0 H_a/C_th 1/C_th];
%% Second Step: discretize temperature ODE (see above)

method = 'diffEq'; %can be 'c2d' or 'diffEq'

if strcmp(method, 'c2d')
    sys_temp_con_B = ss(Acont, Bcont, [], []);
    sys_temp_con_S = ss(Acont, Scont, [], []);

    sys_temp_dis_B = c2d(sys_temp_con_B, DT);
    sys_temp_dis_S = c2d(sys_temp_con_, DT);

    Adis = sys_temp_dis_B.A;
    Bdis = sys_temp_dis_B.B;
    Sdis = sys_temp_dis_S.B;
    
elseif strcmp(method, 'diffEq')
    Adis = [ 1, 0; 
             0, exp(-(H_a*DT)/C_th)];
    Bdis = [ DT, DT,  -DT/eta_rad, DT/eps_c; 
             0, -(exp(-(H_a*DT)/C_th)-1)/(H_a*c_chp), -(exp(-(H_a*DT)/C_th)-1)/H_a, -(exp(-(H_a*DT)/C_th)-1)/H_a];
    Sdis = [ DT, DT, 0, 0;
             0, 0, 1-exp(-(H_a*DT)/C_th), (1-exp(-(H_a*DT)/C_th))/H_a];
else
   error('ERROR: choose valid Method') 
end



%% Last Step: Save .mat-file
A = Adis; B = Bdis; S = Sdis; C = [1; 1]; D = [0 0 0 0; 0 0 0 0]; type = 'L';
save('../Models/model1_soc_thetaa_electric_radiator.mat', 'A', 'B', 'C', 'D', 'S', 'type')

model1_name = 'model1_soc_thetaa_electric_radiator.mat';

end

