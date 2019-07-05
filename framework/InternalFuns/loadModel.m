function [n_x, n_u, n_d, x_plus, modelData] = loadModel(name)
% Description: load the Model of the System of the input "name"

% Input
%   + name: name of the respective Model. It is a struct with the matrices
%   A, B, C, S, for the linear system. And a vector of equations for the
%   nonlinear case. In both cases the respective struct has an argument
%   "type", that describe if the system is linear (name.type = "L") or
%   NonLinear (name.type = "NL")

% Output
%   + n_x: dimension of the state vector
%   + n_u: dimension of the input vector
%   + n_d: dimension of the disturbance vector
%   + x_plus: description of the system's equations
%   + modelData: describe if the system is Linear ("L") or NonLinear ("NL")


try
     aux = load([getRootDir() '/Models/' name]);
    
    % It was adopted that the model has the Parameters in Struct and the user can decide between
    % nonlinear and linear systems. The Parameter is 'type' and is 'NL' respectively 'L'.
    
    if(aux.type == 'L')
        
        % if the model is linear modelData.type = 1
        modelData.type = 1;         
        
        % Save the value of the matrices A, B, C and S of the model in x_plus with struct
        x_plus = @(x, u, d) (aux.A*x + aux.S*d + aux.B*u);
        
        % Save the value of the matrices A, B, C and S of the model in modelData with struct
        modelData.A = aux.A;
        modelData.B = aux.B;
        modelData.S = aux.S;
        
        % Take the dimensions of the system
        n_x = size((aux.A),1);
        n_u = size((aux.B),2);
        n_d = size((aux.S),2);
    
    elseif (aux.type == 'NL')
        
        % if the model is nonlinear modelData.type = 0
        modelData.type = 0;
        
        % Save the nonlinear expression of the system in x_plus and modelData
        x_plus = aux.x_plus;
        modelData.A = NaN;
        modelData.B = NaN;
        modelData.S = NaN;
        
        % Set the dimensions to 0
        n_x = aux.n_x;
        n_u = aux.n_u;
        n_d = aux.n_d;
     end
    
catch
    
    % Error in case the user does not provide a valid name for the system
    n_x = NaN;
    n_u = NaN;
    n_d = NaN;
    x_plus = NaN;
    modelData = NaN;
    disp('File for the system does not exist');
    
end

end