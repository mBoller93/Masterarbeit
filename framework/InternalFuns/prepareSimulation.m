function [sfsp] = prepareSimulation(commonConfig, instanceArray, commonExtra, instanceExtra)
%PREPARESIMULATION Prepares the simulation parameters instance
sfsp = SFSP();
sfsp.common.config = commonConfig;

sfsp.common.state = struct;
sfsp.common.state.k = 0;

if( nargin > 2 )
    sfsp.common.extra = commonExtra;
else
    sfsp.common.extra = struct;
end

instances = fields(instanceArray);
for i=1:numel(instances)
    sfsp.instances.(instances{i}).config = instanceArray.(instances{i});
    sfsp.instances.(instances{i}).state = struct;
    sfsp.instances.(instances{i}).model = struct;
    if( nargin == 4 )
        sfsp.instances.(instances{i}).extra = instanceExtra;
    end
end

