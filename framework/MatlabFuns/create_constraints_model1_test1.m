function [constraints_filename] = create_constraints_model1_test1(DT, varargin) 
%create_constraints_model1_test1 creates and saves '../Data/test1_model1_constraints.mat' 
%for model 1 
%   DT: Stepsize in minutes (!)
%   n_bat: number of batteries with 10 kWh each [optional, default=7]
%   charge_max: maximum power charge for each battery in kW [optional; default=2]

switch nargin
    case 1
        n_bat = 7; % Number of batteries with bat_cap each
        charge_max = 2; % maximum charging power for each battery in kW
    case 2
        n_bat = varargin{1};
        charge_max = 2;
    case 3
        n_bat = varargin{1};
        charge_max = varargin{2};
end
      
DTh = DT/60; % so that it's in hours
bat_cap = 10; % maximum capacity of one battery in kWhs

% c1.x= [1, 2;
%        0.15*bat_cap*n_bat, 15; 
%        0.85*bat_cap*n_bat, 30];
c1.x = [1, 0.15*bat_cap*n_bat, 0.85*bat_cap*n_bat;
        2, 15, 30];
% c1.x = c1.x';
c1.u= [2, 3, 4;
       0, 0, -100;
       199, 400, 0];
c1.u = c1.u';
c1.d = [];
c1.xref = [];
% c1.total_input = [1, -n_bat*charge_max, n_bat*charge_max];
c1.dx = [1, -n_bat*charge_max*DTh, n_bat*charge_max*DTh;
                  2, -20, 20]; %just for numerical reasons, should not affect simulation
c1.Tstart = [0];

constraints_filename = 'test1_model1_constraints.mat';
save(['../Data/' constraints_filename], 'c1');


end
       