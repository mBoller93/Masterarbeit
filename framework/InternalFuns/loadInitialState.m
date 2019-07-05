


function x_0 = loadInitialState(Dateiname,n_x)
    % function that loads the Initial state from a csv-File  if available
    % or set it to NaN if not.
    % Inputs : Dateiname: File-Name and n_x : size of the State vector
try
    x_0 = csvread([getRootDir() '/Data/' Dateiname]);
catch
    warning(' File not found');
    x_0=NaN;
    return;
end
 if max(size(x_0))~=n_x
     disp('Size of the initial state vector is wrong');
     x_0 = NaN;
     return;
 end
%  if 
 for i=1:1:n_x
     if isnan(x_0(i))
         fprintf(' the element %d is NaN',i);
     elseif ~isnumeric(x_0(i))
         fprintf( ' the element %d is not numeric',i);
     end
    
end



