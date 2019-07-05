function C = loadConstraintMatrix(name, N_pred, k, T_s, n_x, n_u, n_d)
% loadConstrainMatrix loads the constraints for the predictive horizont of
% the system.  

% INPUTS
% + name: name of the .mat file for the determination of the respective constraints
% + N_pred: Number of steps of the predictive horizont
% + k: Current step
% + T_s: Sample Time
% + n_x: number of states
% + n_u: number of inputs
% + n_d: number of disturbances

% OUTPUTS
% C: matrix with the constraints (upper and lower bound) for the states x,
% control effort u, disturbances d, setpoints xref and the battery
% constraints Pel,bat

%% Load Constraints
% Load the constraints and save in a persistent variable, so it won't be
% necessary to load it again

persistent constraint first_acess v_last;
if(isempty(constraint))
    try
        aux = load([getRootDir() filesep 'Data' filesep name]);              % Load file .mat
    catch
        error('File for the system does not exist');
    end
    fields = fieldnames(aux);           % Take the number of differents amounts of constraints
    for i = 1:length(fields)        
        x(i) = aux.(fields{i});         % Save the constraints in a vector
    end
    constraint = x;
    for i=1:length(constraint)
        if(size(constraint(i).x,1) > n_x)
            error('Error in the definition of upper and lower bound of the states for the constraints');
        end
        if(size(constraint(i).u,1) > n_u)
            error('Error in the definition of upper and lower bound of the inputs for the constraints');
        end
        if((size(constraint(i).d,1) > n_d))
            error('Error in the definition of upper and lower bound of the disturbances for the constraints');
        end
    end
end

%% Calculate the constraint Matrix for the respective intervall
% Find the intervall in the .mat File, where the predicitive horizont is 
list_Tstart = [];
for l = 1: length(constraint)
    list_Tstart = [list_Tstart constraint(l).Tstart];
end

indexs = find(list_Tstart <= k*T_s);
ind_current = indexs(end);

% Calculate the equivalent continuous time
t_current = k*T_s;
C_int = [];
v_pre = NaN*zeros(2*n_x + 2*n_x + 2*n_u + 2*n_d + 2*n_x,1);
v_pos = NaN*zeros(2*n_x + 2*n_x + 2*n_u + 2*n_d + 2*n_x,1);

if(isempty(first_acess))
    first_acess = false;
    v_last = NaN*zeros(2*n_x + 2*n_x + 2*n_u + 2*n_d + 2*n_x,1); % v_last is the previous constraints-vector of the Constraints-Matrix in time 
end

%% Loop for the Calculation
for i=1:N_pred
    if(i == 1)
        v_pre = v_last;     % Update the last vector of constraints from the last Constraints-Matrix 
    end
    
    % Taking bounds for the states
    if(~isempty(constraint(ind_current).x))                         % Checking if there will be some change in the constraints-amount
        list = constraint(ind_current).x(:,1);                      % Taking the index that are going to change for the referred time
        for q = 1:length(list)
            v_pos(list(q)*2 - 1) = constraint(ind_current).x(q,2);  % Update of the lower-bound 
            v_pos(list(q)*2) = constraint(ind_current).x(q,3);      % Update of the upper-bound
        end
    end
    
    for j=1:(n_x)                                           % Analysis between the referred constraints-vector in the referred time and its previous constraints-vector
        if(isnan(v_pos(2*j)) && isnan(v_pos(2*j-1)))        % Case for the continuation of the same upper and lower bound with the previous constraints-vector
            v_pos(2*j) = v_pre(2*j);
            v_pos(2*j-1) = v_pre(2*j-1);
        end
        if ((ind_current + 1 <= length(constraint)))                                % Verification if the beginning of the constraints-matrix is in the last constraints-amount   
            if((constraint(ind_current + 1).Tstart - t_current)<T_s)          % Verification if the t_current is the last point before an entrace in the next constraints-amount 
                if((constraint(ind_current + 1).Tstart - t_current)<=T_s/2)   % Verification of the distance between t_current and the border of the next constraints-amount 
                    if(~isempty(constraint(ind_current + 1).x))                     % Checking if there will be some change in the next constraints-amount
                        h = find(constraint(ind_current + 1).x(:,1) == j);              % Finding the equivalent position of the constraints of the referred parameter in the next constraints-amount 
                        if(~isempty(h))                                                 % Case there is a constinuation in the constraints for the referred parameter
                            if(constraint(ind_current + 1).x(h,3) < v_pos(2*j-1) || constraint(ind_current + 1).x(h,2) > v_pos(2*j))    % Checking the case for overlapping
                                v_pos(2*j-1) = constraint(ind_current + 1).x(h,2); % Update of the lower-bound
                                v_pos(2*j) = constraint(ind_current + 1).x(h,3);   % Update of the upper-bound
                            else
                                v_pos(2*j-1) = max(constraint(ind_current + 1).x(h,2),v_pos(2*j-1)); % Taking the strictest bound
                                v_pos(2*j) = min(constraint(ind_current + 1).x(h,3),v_pos(2*j));     % Taking the strictest bound
                            end
                        end
                    end
                else
                    h = find(constraint(ind_current + 1).x(:,1) == j);
                    if(~isempty(h))
                        if(~(constraint(ind_current + 1).x(h,3) < v_pos(2*j-1)) && ~(constraint(ind_current + 1).x(h,2) > v_pos(2*j)))
                            v_pos(2*j-1) = max(constraint(ind_current + 1).x(h,2),v_pos(2*j-1)); 
                            v_pos(2*j) = min(constraint(ind_current + 1).x(h,3),v_pos(2*j));
                        end
                    end
                end
            end
        end
    end
    
    % Taking bounds for the inputs
    if(~isempty(constraint(ind_current).u))                                 % Checking if there will be some change in the constraints-amount
        list = constraint(ind_current).u(:,1);                              % Taking the index that are going to change for the referred time
        for q = 1:length(list)
            v_pos(list(q)*2 - 1 + 2*n_x) = constraint(ind_current).u(q,2);  % Update of the lower-bound 
            v_pos(list(q)*2 + 2*n_x) = constraint(ind_current).u(q,3);      % Update of the lower-bound 
        end
    end
    
    for j=(n_x+1):(n_x+n_u)                                             % Analysis between the referred constraints-vector in the referred time and its previous constraints-vector
        if(isnan(v_pos(2*j)) && isnan(v_pos(2*j-1)))                    % Case for the continuation of the same upper and lower bound with the previous constraints-vector
            v_pos(2*j) = v_pre(2*j);
            v_pos(2*j-1) = v_pre(2*j-1);
        end
        if ((ind_current + 1 <= length(constraint)))                                % Verification if the beginning of the constraints-matrix is in the last constraints-amount   
            if((constraint(ind_current + 1).Tstart - t_current)<T_s)          % Verification if the t_current is the last point before an entrace in the next constraints-amount 
                if((constraint(ind_current + 1).Tstart - t_current)<=T_s/2)   % Verification of the distance between t_current and the border of the next constraints-amount 
                    if(~isempty(constraint(ind_current + 1).u))                     % Checking if there will be some change in the next constraints-amount
                        h = find(constraint(ind_current + 1).u(:,1) == (j-n_x));        % Finding the equivalent position of the constraints of the referred parameter in the next constraints-amount 
                        if(~isempty(h))                                                 % Case there is a constinuation in the constraints for the referred parameter
                            if(constraint(ind_current + 1).u(h,3) < v_pos(2*j-1) || constraint(ind_current + 1).u(h,2) > v_pos(2*j))    % Checking the case for overlapping
                                v_pos(2*j-1) = constraint(ind_current + 1).u(h,2);      % Update of the lower-bound
                                v_pos(2*j) = constraint(ind_current + 1).u(h,3);        % Update of the upper-bound
                            else
                                v_pos(2*j-1) = max(constraint(ind_current + 1).u(h,2),v_pos(2*j-1)); % Taking the strictest bound
                                v_pos(2*j) = min(constraint(ind_current + 1).u(h,3),v_pos(2*j));     % Taking the strictest bound
                            end
                        end
                    end
                else
                    h = find(constraint(ind_current + 1).u(:,1) == (j-n_x));
                    if(~isempty(h))
                        if(~(constraint(ind_current + 1).u(h,3) < v_pos(2*j-1)) && ~(constraint(ind_current + 1).u(h,2) > v_pos(2*j)))
                            v_pos(2*j-1) = max(constraint(ind_current + 1).u(h,2),v_pos(2*j-1)); 
                            v_pos(2*j) = min(constraint(ind_current + 1).u(h,3),v_pos(2*j));
                        end
                    end
                end
            end
        end
    end
    
    % Taking bounds for the disturbances
    if(~isempty(constraint(ind_current).d))                                         % Checking if there will be some change in the constraints-amount
        list = constraint(ind_current).d(:,1);                                      % Taking the index that are going to change for the referred time
        for q = 1:length(list)
            v_pos(list(q)*2 - 1 + 2*(n_x + n_u)) = constraint(ind_current).d(q,2);  % Update of the lower-bound 
            v_pos(list(q)*2 + 2*(n_x + n_u)) = constraint(ind_current).d(q,3);      % Update of the lower-bound 
        end
    end
    
    for j=(n_x + n_u + 1):(n_x + n_u + n_d)                                     % Analysis between the referred constraints-vector in the referred time and its previous constraints-vector
        if(isnan(v_pos(2*j)) && isnan(v_pos(2*j-1)))                            % Case for the continuation of the same upper and lower bound with the previous constraints-vector
            v_pos(2*j) = v_pre(2*j);
            v_pos(2*j-1) = v_pre(2*j-1);
        end
        if ((ind_current + 1 <= length(constraint)))                                % Verification if the beginning of the constraints-matrix is in the last constraints-amount   
            if((constraint(ind_current + 1).Tstart - t_current)<T_s)          % Verification if the t_current is the last point before an entrace in the next constraints-amount 
                if((constraint(ind_current + 1).Tstart - t_current)<=T_s/2)   % Verification of the distance between t_current and the border of the next constraints-amount 
                    if(~isempty(constraint(ind_current + 1).d))                     % Checking if there will be some change in the next constraints-amount
                        h = find(constraint(ind_current + 1).d(:,1) == (j - n_x - n_u));% Finding the equivalent position of the constraints of the referred parameter in the next constraints-amount 
                        if(~isempty(h))                                                 % Case there is a constinuation in the constraints for the referred parameter
                            if(constraint(ind_current + 1).d(h,3) < v_pos(2*j-1) || constraint(ind_current + 1).d(h,2) > v_pos(2*j))    % Checking the case for overlapping
                                v_pos(2*j-1) = constraint(ind_current + 1).d(h,2);      % Update of the lower-bound
                                v_pos(2*j) = constraint(ind_current + 1).d(h,3);        % Update of the upper-bound
                            else
                                v_pos(2*j-1) = max(constraint(ind_current + 1).d(h,2),v_pos(2*j-1)); % Taking the strictest bound 
                                v_pos(2*j) = min(constraint(ind_current + 1).d(h,3),v_pos(2*j));     % Taking the strictest bound
                            end
                        end
                    end
                else
                    h = find(constraint(ind_current + 1).d(:,1) == (j - n_x - n_u));
                    if(~isempty(h))
                        if(~(constraint(ind_current + 1).d(h,3) < v_pos(2*j-1)) && ~(constraint(ind_current + 1).d(h,2) > v_pos(2*j)))
                            v_pos(2*j-1) = max(constraint(ind_current + 1).d(h,2),v_pos(2*j-1)); 
                            v_pos(2*j) = min(constraint(ind_current + 1).d(h,3),v_pos(2*j));
                        end
                    end
                end
            end
        end
    end
    
    % Taking bounds for the setpoints
    if(~isempty(constraint(ind_current).xref))                                                 % Checking if there will be some change in the constraints-amount
        list = constraint(ind_current).xref(:,1);                                              % Taking the index that are going to change for the referred time
        for q = 1:length(list)
            v_pos(list(q)*2 - 1 + 2*(n_x + n_u + n_d)) = constraint(ind_current).xref(q,2);    % Update of the lower-bound 
            v_pos(list(q)*2+ 2*(n_x + n_u + n_d)) = constraint(ind_current).xref(q,3);         % Update of the lower-bound 
        end
    end
    
    for j=(n_x + n_u + n_d + 1):(n_x + n_u + n_d + n_x)                                     % Analysis between the referred constraints-vector in the referred time and its previous constraints-vector
        if(isnan(v_pos(2*j)) && isnan(v_pos(2*j-1)))                                        % Case for the continuation of the same upper and lower bound with the previous constraints-vector
            v_pos(2*j) = v_pre(2*j);
            v_pos(2*j-1) = v_pre(2*j-1);
        end
        if ((ind_current + 1 <= length(constraint)))                                            % Verification if the beginning of the constraints-matrix is in the last constraints-amount   
            if((constraint(ind_current + 1).Tstart - t_current)<T_s)                      % Verification if the t_current is the last point before an entrace in the next constraints-amount 
                if((constraint(ind_current + 1).Tstart - t_current)<=T_s/2)               % Verification of the distance between t_current and the border of the next constraints-amount 
                    if(~isempty(constraint(ind_current + 1).xref))                                 % Checking if there will be some change in the next constraints-amount
                        h = find(constraint(ind_current + 1).xref(:,1) == (j - n_x - n_u - n_d));  % Finding the equivalent position of the constraints of the referred parameter in the next constraints-amount 
                        if(~isempty(h))                                                             % Case there is a constinuation in the constraints for the referred parameter
                            if(constraint(ind_current + 1).xref(h,3) < v_pos(2*j-1) || constraint(ind_current + 1).xref(h,2) > v_pos(2*j))    % Checking the case for overlapping
                                v_pos(2*j-1) = constraint(ind_current + 1).xref(h,2);              % Update of the lower-bound
                                v_pos(2*j) = constraint(ind_current + 1).xref(h,3);                % Update of the upper-bound
                            else
                                v_pos(2*j-1) = max(constraint(ind_current + 1).xref(h,2),v_pos(2*j-1));    % Taking the strictest bound 
                                v_pos(2*j) = min(constraint(ind_current + 1).xref(h,3),v_pos(2*j));        % Taking the strictest bound 
                            end
                        end
                    end
                else
                    h = find(constraint(ind_current + 1).xref(:,1) == (j-n_x-n_u-n_d));
                    if(~isempty(h))
                        if(~(constraint(ind_current + 1).xref(h,3) < v_pos(2*j-1)) && ~(constraint(ind_current + 1).xref(h,2) > v_pos(2*j)))
                            v_pos(2*j-1) = max(constraint(ind_current + 1).xref(h,2),v_pos(2*j-1)); 
                            v_pos(2*j) = min(constraint(ind_current + 1).xref(h,3),v_pos(2*j));
                        end
                    end
                end
            end
        end
    end
    
    % Taking bounds for the dx = x(k+1) - x(k)
    if(~isempty(constraint(ind_current).dx))                         % Checking if there will be some change in the constraints-amount
        list = constraint(ind_current).dx(:,1);                      % Taking the index that are going to change for the referred time
        for q = 1:length(list)
            v_pos(list(q)*2 - 1 + 2*(n_x + n_u + n_d + n_x)) = constraint(ind_current).dx(q,2);  % Update of the lower-bound 
            v_pos(list(q)*2 + 2*(n_x + n_u + n_d + n_x)) = constraint(ind_current).dx(q,3);      % Update of the upper-bound
        end
    end
    
    for j=(n_x + n_u + n_d + n_x + 1):(n_x + n_u + n_d + n_x + n_x)     % Analysis between the referred constraints-vector in the referred time and its previous constraints-vector
        if(isnan(v_pos(2*j)) && isnan(v_pos(2*j-1)))        % Case for the continuation of the same upper and lower bound with the previous constraints-vector
            v_pos(2*j) = v_pre(2*j);
            v_pos(2*j-1) = v_pre(2*j-1);
        end
        if ((ind_current + 1 <= length(constraint)))                                % Verification if the beginning of the constraints-matrix is in the last constraints-amount   
            if((constraint(ind_current + 1).Tstart - t_current)<T_s)          % Verification if the t_current is the last point before an entrace in the next constraints-amount 
                if((constraint(ind_current + 1).Tstart - t_current)<=T_s/2)   % Verification of the distance between t_current and the border of the next constraints-amount 
                    if(~isempty(constraint(ind_current + 1).dx))                     % Checking if there will be some change in the next constraints-amount
                        h = find(constraint(ind_current + 1).dx(:,1) == (j - n_x - n_u - n_d - n_x));              % Finding the equivalent position of the constraints of the referred parameter in the next constraints-amount 
                        if(~isempty(h))                                                 % Case there is a constinuation in the constraints for the referred parameter
                            if(constraint(ind_current + 1).dx(h,3) < v_pos(2*j-1) || constraint(ind_current + 1).dx(h,2) > v_pos(2*j))    % Checking the case for overlapping
                                v_pos(2*j-1) = constraint(ind_current + 1).dx(h,2); % Update of the lower-bound
                                v_pos(2*j) = constraint(ind_current + 1).dx(h,3);   % Update of the upper-bound
                            else
                                v_pos(2*j-1) = max(constraint(ind_current + 1).dx(h,2),v_pos(2*j-1)); % Taking the strictest bound
                                v_pos(2*j) = min(constraint(ind_current + 1).dx(h,3),v_pos(2*j));     % Taking the strictest bound
                            end
                        end
                    end
                else
                    h = find(constraint(ind_current + 1).dx(:,1) == (j - n_x - n_u - n_d - n_x));
                    if(~isempty(h))
                        if(~(constraint(ind_current + 1).dx(h,3) < v_pos(2*j-1)) && ~(constraint(ind_current + 1).dx(h,2) > v_pos(2*j)))
                            v_pos(2*j-1) = max(constraint(ind_current + 1).dx(h,2),v_pos(2*j-1)); 
                            v_pos(2*j) = min(constraint(ind_current + 1).dx(h,3),v_pos(2*j));
                        end
                    end
                end
            end
        end
    end
    
    v_pre = v_pos;                                      % Update of v_pre from v_pos
    v_pos = NaN*zeros(2*n_x + 2*n_x + 2*n_u + 2*n_d + 2*n_x,1); % Update of v_pos
    v_aux = [v_pre; t_current];                         % v_aux is v_pre with the time of the constraint
    C_int = [C_int v_aux];                              % Integration in the intermediary constraints-matrix
    
    t_current = t_current + T_s;                  % Update of the time
    if (ind_current ~= length(constraint))              
        if(t_current >= constraint(ind_current+1).Tstart)
            ind_current = ind_current + 1;
        end
    end
        
end

if(N_pred == 1)
    v_last = C_int(:,1);
else
    v_last = C_int(:,2);
end


% Adjust of the constraints matrix to the defined shape

C = [];
for i=1:2*n_x
    if(mod(i,2)~=0)
        C = [C; C_int(i,:)];
    end
end

for i=1:2*n_x
    if(mod(i,2)==0)
        C = [C; C_int(i,:)];
    end
end

for i=2*n_x+1 : 2*(n_x + n_u)
    if(mod(i,2)~=0)
        C = [C; C_int(i,:)];
    end
end

for i=2*n_x+1 : 2*(n_x + n_u)
    if(mod(i,2)==0)
        C = [C; C_int(i,:)];
    end
end

for i=2*(n_x + n_u) + 1 : 2*(n_x + n_u + n_d)
    if(mod(i,2)~=0)
        C = [C; C_int(i,:)];
    end
end

for i=2*(n_x + n_u) + 1 : 2*(n_x + n_u + n_d)
    if(mod(i,2)==0)
        C = [C; C_int(i,:)];
    end
end

for i=2*(n_x + n_u + n_d) + 1 : 2*(n_x + n_u + n_d + n_x)
    if(mod(i,2)~=0)
        C = [C; C_int(i,:)];
    end
end

for i=2*(n_x + n_u + n_d) + 1 : 2*(n_x + n_u + n_d + n_x)
    if(mod(i,2)==0)
        C = [C; C_int(i,:)];
    end
end      

for i=2*(n_x + n_u + n_d + n_x) + 1 : 2*(n_x + n_u + n_d + n_x + n_x)
    if(mod(i,2)~=0)
        C = [C; C_int(i,:)];
    end
end

for i=2*(n_x + n_u + n_d + n_x) + 1 : 2*(n_x + n_u + n_d + n_x + n_x)
    if(mod(i,2)==0)
        C = [C; C_int(i,:)];
    end
end

C = [C; C_int(end,:)];      

end