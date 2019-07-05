function saveSimulationData(x_traj_real, x_traj_pred, ...
    u_traj_real, u_traj_pred, ...
    d_traj_real, d_traj_pred, ...
    J_mon_traj_real, J_mon_traj_pred, ...
    J_mon_k_traj_real, J_mon_k_traj_pred, ...
    J_opt_traj_real, J_opt_traj_pred, ...
    J_opt_k_traj_real, J_opt_k_traj_pred, ...
    price_traj_real, price_traj_pred, ...
    peak_cost_traj_real, peak_cost_traj_pred, ...
    SimName, ...
    common, ...
    paretoData ...
)
if ~exist('paretoData','var')
  paretoData = false;
end
    % this function save the results in csv-files in the Folder
    % Results->'SimName'->csv.
    %this function require that the current path is on the folder 
    %'results'
    
enablePeakCosts = common.config.enablePeakCosts;
calculateMonetaryCosts = common.config.calculateMonetaryCosts;

mkdir([getRootDir() '/Results/', SimName, '/csv/']);

csvwrite([getRootDir() '/Results/', SimName, '/csv/', 'x_traj_real.csv'], x_traj_real);
csvwrite([getRootDir() '/Results/', SimName, '/csv/', 'x_traj_pred.csv'], x_traj_pred);
csvwrite([getRootDir() '/Results/', SimName, '/csv/', 'u_traj_real.csv'], u_traj_real);
csvwrite([getRootDir() '/Results/', SimName, '/csv/', 'u_traj_pred.csv'], u_traj_pred);
csvwrite([getRootDir() '/Results/', SimName, '/csv/', 'd_traj_real.csv'], d_traj_real);
csvwrite([getRootDir() '/Results/', SimName, '/csv/', 'd_traj_pred.csv'], d_traj_pred);

% store calculated monteray trajectories only if they were calculated
if(calculateMonetaryCosts)
    csvwrite([getRootDir() '/Results/', SimName, '/csv/', 'J_mon_traj_real.csv'], J_mon_traj_real);
    csvwrite([getRootDir() '/Results/', SimName, '/csv/', 'J_mon_traj_pred.csv'], J_mon_traj_pred);
    csvwrite([getRootDir() '/Results/', SimName, '/csv/', 'J_mon_k_traj_real.csv'], J_mon_k_traj_real);
    csvwrite([getRootDir() '/Results/', SimName, '/csv/', 'J_mon_k_traj_pred.csv'], J_mon_k_traj_pred);
end

csvwrite([getRootDir() '/Results/', SimName, '/csv/', 'J_opt_traj_real.csv'], J_opt_traj_real);
csvwrite([getRootDir() '/Results/', SimName, '/csv/', 'J_opt_traj_pred.csv'], J_opt_traj_pred);
csvwrite([getRootDir() '/Results/', SimName, '/csv/', 'J_opt_k_traj_real.csv'], J_opt_k_traj_real);
csvwrite([getRootDir() '/Results/', SimName, '/csv/', 'J_opt_k_traj_pred.csv'], J_opt_k_traj_pred);
csvwrite([getRootDir() '/Results/', SimName, '/csv/', 'price_traj_real.csv'], price_traj_real);
csvwrite([getRootDir() '/Results/', SimName, '/csv/', 'price_traj_pred.csv'], price_traj_pred);

% store calculated peak cost trajectories only if they were calculated
if(enablePeakCosts)
    csvwrite([getRootDir() '/Results/', SimName, '/csv/', 'peak_cost_traj_real.csv'], peak_cost_traj_real);
    csvwrite([getRootDir() '/Results/', SimName, '/csv/', 'peak_cost_traj_pred.csv'], peak_cost_traj_pred);
end

if( isstruct( paretoData ) )
    mkdir([getRootDir() '/Results/', SimName, '/pareto/']);
    save([getRootDir() '/Results/', SimName, '/pareto/', 'paretoData.mat'], '-struct', 'paretoData');
end

end


