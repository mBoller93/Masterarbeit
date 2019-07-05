function [Pcharge_real,Pcharge_pred] = get_Pcharge_model1(k, Npred, V)
%GET_PCHARGE_MODEL1 function that calculates the Battery Power Pcharge.
  % Inputs  : step k , N_pred and a structur V containing all calcultated Data.
  % Outputs : Pcharge_pred  and Pcharge_real
  
max_charge_kW = 14; % ANPASSEN

% -> for later: should be adjusted automatically from system matrix!
eta_rad = .99; % electricity efficiency of electric radiators
eps_c = 2.5; % 'energy efficiency ratio' (EER) of electric chillers

%% Calculate Pcharge_real from u_traj_real and d_traj_real accoring to model
% equations

% Later: Check if 'g' is really necessary. I think it could be left out,
% using 'i' instead. 
g=1;
for i=1:1:size(V.u_traj_real, 2)
    Pcharge_real_1(g)= V.u_traj_real(1,i) ...
                       + V.u_traj_real(2,i) ... 
                       - 1/eta_rad * V.u_traj_real(3,i) ...
                       + 1/eps_c * V.u_traj_real(4,i);
    g=g+1;
end
g=1;
for i=1:1:size(V.d_traj_real, 2)
    Pcharge_real_2(g)=sum(V.d_traj_real(1:2,i));
    g=g+1;
end

%% Calculate Pcharge_pred 
g=1;
for i=1:4:max(size(V.u_opt)) % probably ... :4: ... because size(B) = 1x4
    Pcharge_pred_1(g)= V.u_opt(i,1) ... %sum(V.u_opt(i:i+3,1));
                       + V.u_opt(i+1,1) ...
                       - 1/eta_rad* V.u_opt(i+2,1) ...
                       + 1/eps_c* V.u_opt(i+3,1);
    g=g+1;
end

g=1;
for i=1:4:max(size(V.d_pred))
    Pcharge_pred_2(g)=sum(V.d_pred(i:i+1,1));
    g=g+1;
end

Pcharge_pred = zeros(3, size(Pcharge_pred_1, 2));
Pcharge_real = zeros(3, size(Pcharge_real_1, 2));

Pcharge_pred(1, :) = max_charge_kW*ones(1, size(Pcharge_pred, 2));
Pcharge_pred(2, :) = Pcharge_pred_1+Pcharge_pred_2;
Pcharge_pred(3, :) = -max_charge_kW*ones(1, size(Pcharge_pred, 2));

Pcharge_real(1, :) = max_charge_kW*ones(1, size(Pcharge_real, 2));
Pcharge_real(2, :) = Pcharge_real_1+Pcharge_real_2;
Pcharge_real(3, :) = -max_charge_kW*ones(1, size(Pcharge_real, 2));

end
