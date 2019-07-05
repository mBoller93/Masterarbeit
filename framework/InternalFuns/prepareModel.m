function [auxiliaryData] = prepareModel(x_plus, modelData, N_pred)
% PREPAREMODEL This function prepares matrices for efficiently calculating
% the state prediction x_pred, if a linear system is given
% Returns empty struct for non-linear systems
% Returns struct containing matrices A_tilda, B_tilda, S_tilda
% Inputs:
%   x_plus          Difference function of the given model
%   modelData       Additional model data of the given model
%   N_pred          Length of the prediction horizon
% Outputs:
%   auxiliaryData	A struct containing auxiliary data for the given model


    auxiliaryData = struct;
    % type = 1 => linear system, 0 => non-linear
    if(modelData.type == 1)
        % x_pred = A_tilda*x0 + B_tilda*u_pred + S_tilda*d_pred
        A = modelData.A;
        B = modelData.B;
        S = modelData.S;
        n_x = length(A);
        
        % build A_tilda = [I; A; ... A^N]
        A_tilda = zeros( (N_pred+1) * n_x, n_x);
        for i=0:N_pred
           A_tilda(i*n_x+1:n_x*(i+1), :) = A^i;
        end
        
        % build B tilda = [B 0 ... 0; A*B B 0 ... 0; ... ; ..... A^(N-2)*B A^(N-1)*B B]
        [height_b, width_b] = size(B);
        B_tilda = zeros((N_pred+1)*height_b, N_pred*width_b);
        for i=0:N_pred-1
            index_rows = 1+(i+1)*height_b:(i+2)*height_b;
            for k=i:-1:0
                B_tilda(index_rows, (i-k)*width_b+1:(i-k+1)*width_b) = A^k*B;
            end
        end
        
        % build S tilda analogously with S instead of B
        [height_f, width_f] = size(S);
        S_tilda = zeros((N_pred+1)*height_f, N_pred*width_f);
        for i=0:N_pred-1
            index_rows = 1+(i+1)*height_f:(i+2)*height_f;
            for k=i:-1:0
                S_tilda(index_rows, (i-k)*width_f+1:(i-k+1)*width_f) = A^k*S;
            end
        end
        
        auxiliaryData.A_tilda = A_tilda;
        auxiliaryData.B_tilda = B_tilda;
        auxiliaryData.S_tilda = S_tilda;
    end

end