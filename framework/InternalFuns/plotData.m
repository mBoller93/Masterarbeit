function plotData(PlotConfig,live,plotValues,T_sim, k, SimName, common, instance)
% Function that prepares and manages The Figures ( open and close ) and
% save them after the Simulation.
% Inputs : PlotConfig : plot's Configuration 
%Live ( 1 to show live figures / 0  if not )
% PlotValues: Structur containing the Values to Plot .
% T_sim : simulation time
% k : step
% SimName : the Name under which the figure will be saved.
persistent isFigOpen

numFigures=max(size(PlotConfig)); %% number of Figures according to PlotConfig
if isempty(isFigOpen)
    isFigOpen= zeros(numFigures, 1);
end
if (live==1)
    for m=1:numFigures
        numPlots=max(size(PlotConfig{m,1}.plots));
        if (PlotConfig{m,1}.live)
            if ~(isFigOpen(m))
                f=figure(m);
                f.Name=PlotConfig{m,1}.title;
                f.Position=[PlotConfig{m,1}.size(1) , PlotConfig{m,1}.size(2) ,...
                    PlotConfig{m,1}.size(3), PlotConfig{m,1}.size(4)];
                isFigOpen(m) = 1;
            else
                figure(m);
                clf;
                
            end
            
            
            for n=1:numPlots
                p(m,n)=subplot(numPlots,1,n); % m Figure number / n Plot number in the coressponding figure
                title(p(m,n),PlotConfig{m,1}.plots{n,1}.title);
%                 xlim(p(m,n),PlotConfig{m,1}.plots{n,1}.xLimits);
                xlabel(p(m,n),PlotConfig{m,1}.plots{n,1}.xLabel);
                %% PLOTTING plotSubplot
                plotSubplot(p, m, n, PlotConfig, plotValues, k, live, T_sim, common, instance);
                
            end
        end
    end
else % if live==0
    mkdir([getRootDir() '/Results/', SimName, '/plots/']);
    for m=1:numFigures
        figure(m);
        clf;
       
    end
    
    for m=1:numFigures
        numPlots=max(size(PlotConfig{m,1}.plots));
        figure(m);


        for n=1:numPlots
            p(m,n)=subplot(numPlots,1,n); % m Figure number / n Plot number in the coressponding figure
            title(p(m,n),PlotConfig{m,1}.plots{n,1}.title);
%             xlim(p(m,n),PlotConfig{m,1}.plots{n,1}.xLimits);
            xlabel(p(m,n),PlotConfig{m,1}.plots{n,1}.xLabel);
            %% PLOTTING plotSubplot
            plotSubplot(p, m, n, PlotConfig, plotValues, k, live, T_sim, common, instance);

        end
        
        %% PRINTING
        print(gcf, PlotConfig{m,1}.name,'-dpng')
        movefile([PlotConfig{m,1}.name '.png'],[getRootDir() '/Results/' SimName '/plots/' ]);
        print(gcf,PlotConfig{m,1}.name,'-depsc')
        movefile([PlotConfig{m,1}.name '.eps'],[getRootDir() '/Results/' SimName '/plots/']);
        saveas(gcf,PlotConfig{m,1}.name, 'fig');
        movefile([PlotConfig{m,1}.name '.fig'],[getRootDir() '/Results/' SimName '/plots/']);
    end
end  

    
end