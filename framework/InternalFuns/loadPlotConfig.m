
function  plotConfig=loadPlotConfig(PlotConfigName, instance)
% this function load the the plot configuration
% call example : y=loadPlotConfig('plot1.mat') where y is the returned
% structure containing the loaded configuration. the Configuration must
% have the same structure as the structure in "PlotConfig.m"
% Config files are in a Folder Config.

n_x = instance.model.n_x;
n_u = instance.model.n_u;
n_d = instance.model.n_d;

%% catch errors
try
    plotConfig=importdata([getRootDir() '/Configuration/' PlotConfigName]); % check if file founded
catch
    warning( 'file not found');
end

%% converting struct to cell in order to facilitate the adressing of figs and plots
plotConfig=struct2cell(plotConfig);
for i=1:max(size(plotConfig))
    plotConfig{i,1}.plots=struct2cell(plotConfig{i,1}.plots);                       %% to acces to the plotp in the figf use this adress plotConfig{f,1}.plots{p,1}
end
nFig=max(size(plotConfig)); % get number of figures


%% checking the Field plotConfig.fign.title
for i=1:nFig
    if ~ischar(plotConfig{i,1}.title)
        warning( ' the title of the fig number %d is not a char',i);
    end
    %%  checking the Field plotConfig.fileName
    if ~ischar(plotConfig{i,1}.name)
        warning( ' the fileName fig number %d is not a char',i);
    end
    %% checking the Field plotConfig.live
    if isempty(plotConfig{i,1}.live)
        plotConfig{i,1}.live=0;
    end
    if (plotConfig{i,1}.live~=1 && plotConfig{i,1}.live~=0)
        warning( ' please enter 1 or 0 in the field live in the figure number %d',i);
    end
    nPlots=max(size(plotConfig{i,1}.plots)); % get the number of plots in the figure i
    %% checking the Field  xLimits
    for j=1:nPlots
        %         if isempty(plotConfig{i,1}.plots{j,1}.xLimits)
        %             warning('please enter the lower and/or upper time limit in the plot %d in the figure %d',j,i);
        %         end
        %         if max(size(plotConfig{i,1}.plots{j,1}.xLimits))>2
        %             warning('please enter at most 2 limits in the plot in the plot %d in the figure %d',j,i)
        %         end
        %         if ~isnumeric(plotConfig{i,1}.plots{j,1}.xLimits)
        %             warning(' please enter numeric values in the field x_limits in the plot %d in the figure %d',j,i);
        %
        %         end
        %% checking the Field xLabel
        if plotConfig{i,1}.plots{j,1}.xLabel==""
            warning( ' the Field x_Label is empty in the plot %d in the figure %d',j,i);
        end
        if ~ischar(plotConfig{i,1}.plots{j,1}.xLabel)
            warning(' the Field x_label must be a char in the plot %d in the figure %d',j,i);
            
        end
        %% checking the Field xScale
        if max(size(plotConfig{i,1}.plots{j,1}.xScale))>1
            warning( 'please enter only one value in the Field xScale in the plot %d in the figure %d',j,i);
        end
        if ~isnumeric(plotConfig{i,1}.plots{j,1}.xScale)
            warning('please enter a numeric value in the Field xScale in the plot %d in the figure %d',j,i);
        end
        
        
        
        
        
        
        
        %% Graph 1
        
        %% checking the Field source
        sources={'state','input','disturbance', 'mon_costs', 'mon_costs_per_k', 'opt_costs', 'opt_costs_per_k', 'price', 'peak_costs_per_k','comfort_costs', 'custom'};
        k=1;
        while 1
            if strcmp(plotConfig{i,1}.plots{j,1}.Graph1.source,sources(k))
                break
            else
                k=k+1;
            end
            if k >max(size(sources))
                warning('please enter a valid name in the Field Graph1.source in the plot %d in the figure %d',j,i);
                break
            end
            
        end
        %% checking the Field Graph1.data
        if ( plotConfig{i,1}.plots{j,1}.Graph1.source ~= "custom" && ~isnumeric(plotConfig{i,1}.plots{j,1}.Graph1.data) )
            warning('please enter numeric values in the Field Graph1.data in the plot %d in the figure %d',j,i);
        elseif( plotConfig{i,1}.plots{j,1}.Graph1.source == "custom" && ~isa(plotConfig{i,1}.plots{j,1}.Graph1.data, 'function_handle'))
            warning('Source for Graph1 is set to custom, so data must be a function handle');
        end
        switch plotConfig{i,1}.plots{j,1}.Graph1.source
            case "state"
                dataSymb='x';
                if isempty(plotConfig{i,1}.plots{j,1}.Graph1.data)
                    plotConfig{i,1}.plots{j,1}.Graph1.data=(1:n_x); % all components of x.
                end
            case "input"
                dataSymb='u';
                if isempty(plotConfig{i,1}.plots{j,1}.Graph1.data)
                    plotConfig{i,1}.plots{j,1}.Graph1.data=(1:n_u); % all components of u.
                end
            case "disturbance"
                dataSymb='d';
                if isempty(plotConfig{i,1}.plots{j,1}.Graph1.data)
                    plotConfig{i,1}.plots{j,1}.Graph1.data=(1:n_d); % all components of d.
                end
            case "mon_costs"
                dataSymb='mon_costs';
                if isempty(plotConfig{i,1}.plots{j,1}.Graph1.data)
                    plotConfig{i,1}.plots{j,1}.Graph1.data=1;
                end
            case "mon_costs_per_k"
                dataSymb='mon_costs';
                if isempty(plotConfig{i,1}.plots{j,1}.Graph1.data)
                    plotConfig{i,1}.plots{j,1}.Graph1.data=1;
                end
            case "opt_costs"
                dataSymb='opt_costs_per_k';
                if isempty(plotConfig{i,1}.plots{j,1}.Graph1.data)
                    plotConfig{i,1}.plots{j,1}.Graph1.data=1;
                end
            case "opt_costs_per_k"
                dataSymb='opt_costs_per_k';
                if isempty(plotConfig{i,1}.plots{j,1}.Graph1.data)
                    plotConfig{i,1}.plots{j,1}.Graph1.data=1;
                end
            case "price"
                dataSymb='price';
                if isempty(plotConfig{i,1}.plots{j,1}.Graph1.data)
                    plotConfig{i,1}.plots{j,1}.Graph1.data=1;
                end
            case "peak_costs_per_k"
                dataSymb='peak_costs_per_k';
                if isempty(plotConfig{i,1}.plots{j,1}.Graph1.data)
                    plotConfig{i,1}.plots{j,1}.Graph1.data=1;
                end
            case "comfort_costs"
                dataSymb='comfort_costs';
                if isempty(plotConfig{i,1}.plots{j,1}.Graph1.data)
                    plotConfig{i,1}.plots{j,1}.Graph1.data=1;
                end
                
        end
        
        
        %% checking the Field Graph1.constraints
        if isempty(plotConfig{i,1}.plots{j,1}.Graph1.constraints)
            plotConfig{i,1}.plots{j,1}.Graph1.constraints=0;
        end
        if (plotConfig{i,1}.plots{j,1}.Graph1.constraints~=0 && plotConfig{i,1}.plots{j,1}.Graph1.constraints~=1)
            warning( ' please enter 1 or 0 in the field Graph1.constraints in the plot %d in the figure %d',j,i);
        end
        %% checking the Field Graph1.legend
        if iscell(plotConfig{i,1}.plots{j,1}.Graph1.legend)
            if (plotConfig{i,1}.plots{j,1}.Graph1.source ~= "custom" && (max(size(plotConfig{i,1}.plots{j,1}.Graph1.data))~= max(size((plotConfig{i,1}.plots{j,1}.Graph1.legend)))) )
                warning("number of Data and Legends don't match");
            end
        else
            warning('the field legend must be a cell array');
        end
        
        %% checking the Field Graph1.position
        if isempty(plotConfig{i,1}.plots{j,1}.Graph1.position)
            plotConfig{i,1}.plots{j,1}.Graph1.position='left';
        end
        if ~ischar(plotConfig{i,1}.plots{j,1}.Graph1.position)
            warning( ' please enter right or left in the field Graph1.position in the plot %d in the figure %d',j,i);
        end
        %% checking the Field Graph1.Label
        if plotConfig{i,1}.plots{j,1}.Graph1.label==""
            warning( ' the Field Graph1.label is empty in the plot %d in the figure %d',j,i);
        end
        if ~ischar(plotConfig{i,1}.plots{j,1}.Graph1.label)
            warning(' the Field Graph1.label must be a char in the plot %d in the figure %d',j,i);
            %%   checking the Field Graph1.limits
        end
        
        %% checking the Field Graph1.stylePred and Graph1.styleReal
        if isfield(plotConfig{i,1}.plots{j,1}.Graph1,'stylePred')
            if isempty(plotConfig{i,1}.plots{j,1}.Graph1.stylePred)
                plotConfig{i,1}.plots{j,1}.Graph1.stylePred = {'--'};
            end
        end
        
        if isfield(plotConfig{i,1}.plots{j,1}.Graph1,'styleReal')
            if isempty(plotConfig{i,1}.plots{j,1}.Graph1.styleReal)
                plotConfig{i,1}.plots{j,1}.Graph1.stylePred = {'-'};
            end
        end
        
        %% check if hide field is set, otherwise set it
        if ~isfield(plotConfig{i, 1}.plots{j, 1}.Graph1, 'hide')
            plotConfig{i, 1}.plots{j, 1}.Graph1.hide = 0;
        end
        
        %% Graph 2
        if isfield(plotConfig{i,1}.plots{j,1},'Graph2')
            
            sources={'state','input','disturbance', 'mon_costs', 'mon_costs_per_k', 'opt_costs', 'opt_costs_per_k', 'price', 'peak_costs_per_k','comfort_costs', 'custom'};
            k=1;
            while 1
                if strcmp(plotConfig{i,1}.plots{j,1}.Graph2.source,sources(k))
                    break
                else
                    k=k+1;
                end
                if k >max(size(sources))
                    warning('please enter a valid name in the Field Graph2.source in the plot %d in the figure %d',j,i);
                    break
                end
            end
            %% checking the Field Graph.data
            if ( plotConfig{i,1}.plots{j,1}.Graph2.source ~= "custom" && ~isnumeric(plotConfig{i,1}.plots{j,1}.Graph2.data) )
                warning('please enter numeric values in the Field Graph2.data in the plot %d in the figure %d',j,i);
            elseif( plotConfig{i,1}.plots{j,1}.Graph2.source == "custom" && ~isa(plotConfig{i,1}.plots{j,1}.Graph2.data, 'function_handle'))
                warning('Source for Graph2 is set to custom, so data must be a function handle');
            end
            switch plotConfig{i,1}.plots{j,1}.Graph2.source
                case "state"
                    dataSymb='x';
                    if isempty(plotConfig{i,1}.plots{j,1}.Graph2.data)
                        plotConfig{i,1}.plots{j,1}.Graph2.data=(1:n_x); % all components of x.
                    end
                case "input"
                    dataSymb='u';
                    if isempty(plotConfig{i,1}.plots{j,1}.Graph2.data)
                        plotConfig{i,1}.plots{j,1}.Graph2.data=(1:n_u); % all components of u.
                    end
                case "disturbance"
                    dataSymb='d';
                    if isempty(plotConfig{i,1}.plots{j,1}.Graph2.data)
                        plotConfig{i,1}.plots{j,1}.Graph2.data=(1:n_d); % all components of d.
                    end
                case "mon_costs"
                    dataSymb='mon_costs';
                    if isempty(plotConfig{i,1}.plots{j,1}.Graph1.data)
                        plotConfig{i,1}.plots{j,1}.Graph1.data=1;
                    end
                case "mon_costs_per_k"
                    dataSymb='mon_costs';
                    if isempty(plotConfig{i,1}.plots{j,1}.Graph1.data)
                        plotConfig{i,1}.plots{j,1}.Graph1.data=1;
                    end
                case "opt_costs"
                    dataSymb='opt_costs_per_k';
                    if isempty(plotConfig{i,1}.plots{j,1}.Graph1.data)
                        plotConfig{i,1}.plots{j,1}.Graph1.data=1;
                    end
                case "opt_costs_per_k"
                    dataSymb='opt_costs_per_k';
                    if isempty(plotConfig{i,1}.plots{j,1}.Graph1.data)
                        plotConfig{i,1}.plots{j,1}.Graph1.data=1;
                    end
                case "price"
                    dataSymb='price';
                    if isempty(plotConfig{i,1}.plots{j,1}.Graph1.data)
                        plotConfig{i,1}.plots{j,1}.Graph1.data=1;
                    end
                case "peak_costs_per_k"
                    dataSymb='peak_costs_per_k';
                    if isempty(plotConfig{i,1}.plots{j,1}.Graph1.data)
                        plotConfig{i,1}.plots{j,1}.Graph1.data=1;
                    end
                case "comfort_costs"
                    dataSymb='comfort_costs';
                    if isempty(plotConfig{i,1}.plots{j,1}.Graph1.data)
                        plotConfig{i,1}.plots{j,1}.Graph1.data=1;
                    end
            end
            
            
            %% checking the Field Graph2.constraints
            if isempty(plotConfig{i,1}.plots{j,1}.Graph2.constraints)
                plotConfig{i,1}.plots{j,1}.Graph2.constraints=0;
            end
            if (plotConfig{i,1}.plots{j,1}.Graph2.constraints~=0 && plotConfig{i,1}.plots{j,1}.Graph2.constraints~=1)
                warning( ' please enter On or Off in the field Graph2.constraints');
            end
            %% checking the Field Graph1.legend
            if iscell(plotConfig{i,1}.plots{j,1}.Graph2.legend)
                if max(size(plotConfig{i,1}.plots{j,1}.Graph2.data))~= max(size((plotConfig{i,1}.plots{j,1}.Graph2.legend)))
                    warning('nmber of Data and Legends don�t match');
                    
                end
            else
                warning('the field legend must be a cell array');
            end
            
            %% checking the Field Graph2.position
            if isempty(plotConfig{i,1}.plots{j,1}.Graph2.position)
                plotConfig{i,1}.plots{j,1}.Graph2.position='left';
            end
            if ~ischar(plotConfig{i,1}.plots{j,1}.Graph2.position)
                warning( ' please enter right or left in the field Graph2.position');
            end
            %% checking the Field Graph2.Label
            if ~ischar(plotConfig{i,1}.plots{j,1}.Graph2.label)
                warning(' the Field Graph2.label must be a char');
                %%   checking the Field Graph2.limits
            end
            
            if strcmp(plotConfig{i,1}.plots{j,1}.Graph2.position ,plotConfig{i,1}.plots{j,1}.Graph1.position)
                warning('in each side only one Graph');
            end
            %% checking the Field Graph2.stylePred and Graph2.styleReal
            if isfield(plotConfig{i,1}.plots{j,1}.Graph2,'stylePred')
                if isempty(plotConfig{i,1}.plots{j,1}.Graph2.stylePred)
                    plotConfig{i,1}.plots{j,1}.Graph2.stylePred = {'--'};
                end
            end
            
            if isfield(plotConfig{i,1}.plots{j,1}.Graph2,'styleReal')
                if isempty(plotConfig{i,1}.plots{j,1}.Graph2.styleReal)
                    plotConfig{i,1}.plots{j,1}.Graph2.stylePred = {'-'};
                end
            end
            
            %% check if hide field is set, otherwise set it
            if ~isfield(plotConfig{i, 1}.plots{j, 1}.Graph2, 'hide')
                plotConfig{i, 1}.plots{j, 1}.Graph2.hide = 0;
            end
            
        end
    end
end
end