function [d_pred] = getDisturbance(source, n_d, k, N_pred, T_s, T_sim)
%Function to calculate disturbance matrix for the prediction horizon.
%   Output: Matrix d_pred with dimensions n_d x N_pred containing
%           disturbance values.
%   Input:  n_d...dimension of disturbance
%           k... current step
%           N_pred...dimension of prediction horizon
%           T_s...time between steps in seconds
%           T_sim...simulation time
%           source...For reading data from csv.-file: file name (string or
%                    char)
%                    For calculation with function: function handle
%_______________________________________________________________________________________________________________

if(isstring(source)||ischar(source))                            %Data source: csv-file
    
    source = string(source);                                    %Change char to string
    
    
    DistData = csvread([ getRootDir() '/Data/' source{1}]);                 %Read csv-file
    
    if(size(DistData, 1)~=n_d+1)
        error('Dimension of csv.-file does not match with n_d.');
    end
    if(DistData(1, length(DistData)) < (T_sim-T_s))
        warning('Length of disturbance matrix from csv.-file is smaller than simulation length');
    end
   
    
    d_pred = zeros(n_d, N_pred);                                %Preallocation for d_pred
    
    for i=0:(N_pred-1)
        [~, index] = min(abs(DistData(1,:)-(k+i)*T_s));   %Search for the time index corresponding to current step
        d_pred(:,i+1) = DistData(2:(n_d+1), index);             %Read values for disturbance at this time index
    end
    
    
    
    
else
    if(isa(source, 'function_handle'))                  %Data source: function handle of disturbance-function
        
        d_pred = zeros(n_d, N_pred);                    %Preallocation for d_pred
        for i=0:(N_pred-1)
            d_pred(:,i+1) = source(k+i, n_d);           %Calculation of disturbance with function given by source
        end
    else
        error('Error. First input must be a string, character or a function handle');  
        
    end
end


end

