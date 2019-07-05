classdef SFSP < handle
    % Simulation Framework Simulation Parameters class
    % This class stores common configuration parameters and state
    % information, as well as the configuration parameters and state
    % information of all defined simulation instances
    properties
        common      % struct containing all common configuration parameters and state information
        instances   % struct array, each struct containing an instance's config parameters and state information
    end
    
    methods
        function obj = SFSP()
            obj.common = struct;
            obj.instances = struct;
        end
    end
end