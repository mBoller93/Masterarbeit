%% Create and SAVE plotConf.mat for Plots of Model 1, Advisory Report 
clear all;

%% overall settings
xTickFaktor = 12;

%%

plotConf.fig1.name = 'SoC and Temperature';
plotConf.fig1.title = 'SoC and Temperature';
plotConf.fig1.live = 1;
plotConf.fig1.size = [+30.0000    +30.0000   +600.0000   +600.0000];
plotConf.fig1.plots.plot1.title = 'Battery SoC vs. Electricity Price';
plotConf.fig1.plots.plot1.fileName = plotConf.fig1.plots.plot1.title;
plotConf.fig1.plots.plot1.xLabel = 'Time in Hours';
plotConf.fig1.plots.plot1.xScale = 0.016667;
plotConf.fig1.plots.plot1.Graph1.constraints = 1;
plotConf.fig1.plots.plot1.Graph1.source = 'state';
plotConf.fig1.plots.plot1.Graph1.data = 1;
plotConf.fig1.plots.plot1.Graph1.legend = {  'SoC'  };
plotConf.fig1.plots.plot1.Graph1.position = 'left';
plotConf.fig1.plots.plot1.Graph1.label = 'SoC kWh';
plotConf.fig1.plots.plot1.Graph1.limits = [];
plotConf.fig1.plots.plot1.Graph1.color = {'b'};%{  [+0.0000   +1.0000   +1.0000]  };
plotConf.fig1.plots.plot1.Graph1.stylePred = {  '--'  };
plotConf.fig1.plots.plot1.Graph1.styleReal = {  '-'  };
plotConf.fig1.plots.plot1.Graph2.constraints = 0;
plotConf.fig1.plots.plot1.Graph2.source = 'price';
plotConf.fig1.plots.plot1.Graph2.data = 1;
plotConf.fig1.plots.plot1.Graph2.legend = {  'Price'  };
plotConf.fig1.plots.plot1.Graph2.position = 'right';
plotConf.fig1.plots.plot1.Graph2.label = ['Price in ' char(8364)];
plotConf.fig1.plots.plot1.Graph2.limits = [];
plotConf.fig1.plots.plot1.Graph2.color = {  'c'  };
plotConf.fig1.plots.plot1.Graph2.stylePred = {  '--'  };
plotConf.fig1.plots.plot1.Graph2.styleReal = {  '-'  };


% plotConf.fig1.plots.plot1.title = 'Electricity Price';
% plotConf.fig1.plots.plot1.fileName = 'Electricity Price';

% plotConf.fig1.plots.plot1.xLabel = 'Time in Hours';
% plotConf.fig1.plots.plot1.xScale = 0.016667;
% plotConf.fig1.plots.plot1.Graph2.constraints = 0;
% plotConf.fig1.plots.plot1.Graph2.source = 'price';
% plotConf.fig1.plots.plot1.Graph2.data = [1];
% plotConf.fig1.plots.plot1.Graph2.legend = { 'price' };
% plotConf.fig1.plots.plot1.Graph2.position = 'right';
% plotConf.fig1.plots.plot1.Graph2.label = 'price_{el} in Euro/kWh';
% plotConf.fig1.plots.plot1.Graph2.limits = [];
% plotConf.fig1.plots.plot1.Graph2.color = {  'b' };
% plotConf.fig1.plots.plot1.Graph2.stylePred = {  '-'};
% plotConf.fig1.plots.plot1.Graph2.styleReal = {  '-'};


plotConf.fig1.plots.plot2.title = 'Building Temperature';
plotConf.fig1.plots.plot2.fileName = 'Temp';
plotConf.fig1.plots.plot2.xLabel = 'Time in Hours';
plotConf.fig1.plots.plot2.xScale = 0.016667;
plotConf.fig1.plots.plot2.Graph1.constraints = 0;
plotConf.fig1.plots.plot2.Graph1.source = 'state';
plotConf.fig1.plots.plot2.Graph1.data = 2;
plotConf.fig1.plots.plot2.Graph1.legend = {  '\vartheta_b'  };
plotConf.fig1.plots.plot2.Graph1.position = 'left';
plotConf.fig1.plots.plot2.Graph1.label = '\vartheta_b in °C';
% plotConf.fig1.plots.plot2.Graph1.limits = [14, 32];%[19, 24];
plotConf.fig1.plots.plot2.Graph1.limits = [19, 24];
plotConf.fig1.plots.plot2.Graph1.color = {  'b'  };
plotConf.fig1.plots.plot2.Graph1.stylePred = {  '--'  };
plotConf.fig1.plots.plot2.Graph1.styleReal = {  '-'  };

plotConf.fig1.plots.plot2.Graph2.constraints = 0;
plotConf.fig1.plots.plot2.Graph2.source = 'disturbance';
plotConf.fig1.plots.plot2.Graph2.data = [3];
plotConf.fig1.plots.plot2.Graph2.legend = { '\vartheta_{air}'};
plotConf.fig1.plots.plot2.Graph2.position = 'right';
plotConf.fig1.plots.plot2.Graph2.label = '\vartheta_{air} in °C';
% plotConf.fig1.plots.plot2.Graph2.limits = [14, 32];
plotConf.fig1.plots.plot2.Graph2.limits = [];
plotConf.fig1.plots.plot2.Graph2.color = {  'c'  };
plotConf.fig1.plots.plot2.Graph2.stylePred = {  '-'  };
plotConf.fig1.plots.plot2.Graph2.styleReal = {  '-'  };

plotConf.fig1.xTickFaktor = xTickFaktor;
plotConf.fig1.lineWidth = 1.5;


%% Figure 2: Powers, Electrical + Heat

plotConf.fig2.name = 'Powers, Electrical + Heat';
plotConf.fig2.title = 'Powers, Electrical + Heat';
plotConf.fig2.live = 1;
plotConf.fig2.size = [+630.0000    +30.0000   +600.0000   +600.0000];

plotConf.fig2.plots.plot1.title = 'Decision Variables (Powers)';
plotConf.fig2.plots.plot1.fileName = 'Electrical Powers';
plotConf.fig2.plots.plot1.xLabel = 'Time in Hours';
plotConf.fig2.plots.plot1.xScale = 0.016667;
plotConf.fig2.plots.plot1.Graph1.constraints = 0;
plotConf.fig2.plots.plot1.Graph1.source = 'input';
plotConf.fig2.plots.plot1.Graph1.data = [1:4];
plotConf.fig2.plots.plot1.Graph1.legend = {  'P_{grid}', 'P_{CHP}', 'Q_{rad}', 'Q_{cool}' }; %
plotConf.fig2.plots.plot1.Graph1.position = 'left';
plotConf.fig2.plots.plot1.Graph1.label = 'P or Q in kW';
plotConf.fig2.plots.plot1.Graph1.limits = [];
plotConf.fig2.plots.plot1.Graph1.color = {  'b', 'k', 'c', 'g'  };
plotConf.fig2.plots.plot1.Graph1.stylePred = {  '--', '--','--', '--'  };
plotConf.fig2.plots.plot1.Graph1.styleReal = {  '-', '-','-', '-'  };


plotConf.fig2.plots.plot2.title = 'Disturbances / Uncertainties';
plotConf.fig2.plots.plot2.fileName = 'Electricity Price';
plotConf.fig2.plots.plot2.xLabel = 'Time in Hours';
plotConf.fig2.plots.plot2.xScale = 0.016667;

plotConf.fig2.plots.plot2.Graph1.constraints = 0;
plotConf.fig2.plots.plot2.Graph1.source = 'disturbance';
plotConf.fig2.plots.plot2.Graph1.data = [1:2];
plotConf.fig2.plots.plot2.Graph1.legend = {  'P_{ren}', 'P_{dem}'  };
plotConf.fig2.plots.plot2.Graph1.position = 'left';
plotConf.fig2.plots.plot2.Graph1.label = 'P or Q in kW';
plotConf.fig2.plots.plot2.Graph1.limits = [];
plotConf.fig2.plots.plot2.Graph1.color = {  'y', 'm'  };
plotConf.fig2.plots.plot2.Graph1.stylePred = {  '--','--'  };
plotConf.fig2.plots.plot2.Graph1.styleReal = {  '-','-'  };
% plotConf.fig2.plots.plot2.Graph1.hide = 1;

plotConf.fig2.plots.plot2.Graph2.constraints = 0;
plotConf.fig2.plots.plot2.Graph2.source = 'disturbance';
plotConf.fig2.plots.plot2.Graph2.data = [3];
plotConf.fig2.plots.plot2.Graph2.legend = {  '\vartheta_{air}'  };
plotConf.fig2.plots.plot2.Graph2.position = 'right';
plotConf.fig2.plots.plot2.Graph2.label = '\vartheta_{air} in °C';
plotConf.fig2.plots.plot2.Graph2.limits = [];
plotConf.fig2.plots.plot2.Graph2.color = {  'b'  };
plotConf.fig2.plots.plot2.Graph2.stylePred = {  '--'  };
plotConf.fig2.plots.plot2.Graph2.styleReal = {  '-'  };
% plotConf.fig2.plots.plot2.Graph1.hide = 1;


% plotConf.fig2.plots.plot2.title = 'Electricity Price';
% plotConf.fig2.plots.plot2.fileName = 'Electricity Price';
% plotConf.fig2.plots.plot2.xLabel = 'Time in Hours';
% plotConf.fig2.plots.plot2.xScale = 0.016667;
% plotConf.fig2.plots.plot2.Graph1.constraints = 0;
% plotConf.fig2.plots.plot2.Graph1.source = 'price';
% plotConf.fig2.plots.plot2.Graph1.data = [1];
% plotConf.fig2.plots.plot2.Graph1.legend = { 'price' };
% plotConf.fig2.plots.plot2.Graph1.position = 'left';
% plotConf.fig2.plots.plot2.Graph1.label = 'price_{el} in Euro/kWh';
% plotConf.fig2.plots.plot2.Graph1.limits = [];
% plotConf.fig2.plots.plot2.Graph1.color = {  'b' };
% plotConf.fig2.plots.plot2.Graph1.stylePred = {  '-'};
% plotConf.fig2.plots.plot2.Graph1.styleReal = {  '-'};

plotConf.fig2.xTickFaktor = xTickFaktor;
plotConf.fig2.lineWidth = 1.5;


%% Figure 3: SoC vs. Pcharge and Jmon vs OptCosts
% thisfig=plotConf.fig3;

plotConf.fig3.name = 'Pcharge';
plotConf.fig3.title = 'P_{charge} and so on';
plotConf.fig3.live = 1;
plotConf.fig3.size = [+1230.0000    +30.0000   +600.0000   +600.0000];
plotConf.fig3.plots.plot1.title = 'P_{charge}';
plotConf.fig3.plots.plot1.fileName = 'Pcharge';
plotConf.fig3.plots.plot1.xLabel = 'Time in Hours';
plotConf.fig3.plots.plot1.xScale = 0.016667;
plotConf.fig3.plots.plot1.Graph1.constraints = 0;
plotConf.fig3.plots.plot1.Graph1.source = 'custom';
plotConf.fig3.plots.plot1.Graph1.data = @get_Pcharge_model1;
plotConf.fig3.plots.plot1.Graph1.legend = {  'P_{charge,max}'  'P_{charge}'  'P_{charge,min}'  };
plotConf.fig3.plots.plot1.Graph1.position = 'left';
plotConf.fig3.plots.plot1.Graph1.label = 'P_{charge} in kW';
plotConf.fig3.plots.plot1.Graph1.limits = [];
plotConf.fig3.plots.plot1.Graph1.color = {  'r'  'k'  'r'  };
plotConf.fig3.plots.plot1.Graph1.stylePred = {  '--'  '--'  '--'  };
plotConf.fig3.plots.plot1.Graph1.styleReal = {  '-'  '-'  '-'  };
plotConf.fig3.xTickFaktor = xTickFaktor;
plotConf.fig3.lineWidth = 1.5;


% plotConf.fig3.name = 'J mon  vs Opt costs';
% plotConf.fig3.title = 'J mon  vs Opt costs';
% plotConf.fig3.live = 1;
% plotConf.fig3.size = [+330.0000    +30.0000   +300.0000   +600.0000];
plotConf.fig3.plots.plot2.title = 'J mon  vs Opt costs';
plotConf.fig3.plots.plot2.fileName = 'J mon  vs Opt costs';
plotConf.fig3.plots.plot2.xLabel = 'Time in Hours';
plotConf.fig3.plots.plot2.xScale = 0.016667;
plotConf.fig3.plots.plot2.Graph1.constraints = 0;
plotConf.fig3.plots.plot2.Graph1.source = 'mon_costs_per_k';
plotConf.fig3.plots.plot2.Graph1.data = 1;
plotConf.fig3.plots.plot2.Graph1.legend = {  'J_{mon}'  };
plotConf.fig3.plots.plot2.Graph1.position = 'left';
plotConf.fig3.plots.plot2.Graph1.label = 'J_{mon} in ';
plotConf.fig3.plots.plot2.Graph1.limits = [];
plotConf.fig3.plots.plot2.Graph1.color = {  [+1.0000   +0.0000   +0.0000]  };
plotConf.fig3.plots.plot2.Graph1.stylePred = {  '--'  };
plotConf.fig3.plots.plot2.Graph1.styleReal = {  '-'  };

plotConf.fig3.plots.plot2.Graph2.constraints = 0;
plotConf.fig3.plots.plot2.Graph2.source = 'opt_costs_per_k';
plotConf.fig3.plots.plot2.Graph2.data = 1;
plotConf.fig3.plots.plot2.Graph2.legend = {  'J_{opt}'  };
plotConf.fig3.plots.plot2.Graph2.position = 'right';
plotConf.fig3.plots.plot2.Graph2.label = 'J_{opt} (no unit)';
plotConf.fig3.plots.plot2.Graph2.limits = [];
plotConf.fig3.plots.plot2.Graph2.color = {  'k'  };
plotConf.fig3.plots.plot2.Graph2.stylePred = {  '--'  };
plotConf.fig3.plots.plot2.Graph2.styleReal = {  '-'  };
% plotConf.fig3.xTickFaktor = xTickFaktor;
% plotConf.fig3.lineWidth = 0.5;



% plotConf.fig3.name = 'Powers, Electrical + Heat';
% plotConf.fig3.title = 'Powers, Electrical + Heat';
% plotConf.fig3.live = 1;
% plotConf.fig3.size = [+630.0000    +30.0000   +600.0000   +600.0000];
% 
% plotConf.fig3.plots.plot1.title = 'Electrical + Thermal Powers';
% plotConf.fig3.plots.plot1.fileName = 'Electrical Powers';
% plotConf.fig3.plots.plot1.xLabel = 'Time in Hours';
% plotConf.fig3.plots.plot1.xScale = 0.016667;
% plotConf.fig3.plots.plot1.Graph1.constraints = 0;
% plotConf.fig3.plots.plot1.Graph1.source = 'input';
% plotConf.fig3.plots.plot1.Graph1.data = [1:4];
% plotConf.fig3.plots.plot1.Graph1.legend = {  'P_{grid}', 'P_{CHP}', 'Q_{rad}', 'Q_{cool}' }; %
% plotConf.fig3.plots.plot1.Graph1.position = 'left';
% plotConf.fig3.plots.plot1.Graph1.label = 'P or Q in kW';
% plotConf.fig3.plots.plot1.Graph1.limits = [];
% plotConf.fig3.plots.plot1.Graph1.color = {  'b', 'k', 'c', 'g'  };
% plotConf.fig3.plots.plot1.Graph1.stylePred = {  '--', '--','--', '--'  };
% plotConf.fig3.plots.plot1.Graph1.styleReal = {  '-', '-','-', '-'  };
% 
% plotConf.fig3.xTickFaktor = xTickFaktor;
% plotConf.fig3.lineWidth = 1.5;

% plotConf.fig2.plots.plot2.title = 'Heat Powers';
% plotConf.fig2.plots.plot2.fileName = 'Heat Powers';
% plotConf.fig2.plots.plot2.xLabel = 'Time in Hours';
% plotConf.fig2.plots.plot2.xScale = 0.016667;
% plotConf.fig2.plots.plot2.Graph1.constraints = 1;
% plotConf.fig2.plots.plot2.Graph1.source = 'input';
% plotConf.fig2.plots.plot2.Graph1.data = [1:4];
% plotConf.fig2.plots.plot2.Graph1.legend = {  '_{grid}', 'P_{CHP}', 'Q_{rad}', 'Q_{cool}',  };
% plotConf.fig2.plots.plot2.Graph1.position = 'left';
% plotConf.fig2.plots.plot2.Graph1.label = 'Q in kW';
% plotConf.fig2.plots.plot2.Graph1.limits = [];
% plotConf.fig2.plots.plot2.Graph1.color = {  'b', 'k', 'c', 'g'  };
% plotConf.fig2.plots.plot2.Graph1.stylePred = {  '--', '--','--', '--'  };
% plotConf.fig2.plots.plot2.Graph1.styleReal = {  '-', '-','-', '-'  };



% 
% 
% plotConf.fig3.name = 'P elGrid vs P elChp ';
% plotConf.fig3.title = 'P_{el,grid} vs P_{el,chp}';
% plotConf.fig3.live = 1;
% plotConf.fig3.size = [+30.0000    +30.0000   +300.0000   +600.0000];
% plotConf.fig3.plots.plot1.title = 'P_{el,grid} vs P_{el,chp}';
% plotConf.fig3.plots.plot1.fileName = 'P elGrid vs P elChp';
% plotConf.fig3.plots.plot1.xLabel = 'Time in Hours';
% plotConf.fig3.plots.plot1.xScale = 0.016667;
% plotConf.fig3.plots.plot1.Graph1.constraints = 0;
% plotConf.fig3.plots.plot1.Graph1.source = 'input';
% plotConf.fig3.plots.plot1.Graph1.data = 1;
% plotConf.fig3.plots.plot1.Graph1.legend = {  'P_{el,grid}'  };
% plotConf.fig3.plots.plot1.Graph1.position = 'left';
% plotConf.fig3.plots.plot1.Graph1.label = 'P in kW';
% plotConf.fig3.plots.plot1.Graph1.limits = [-550.0000   +200.0000];
% plotConf.fig3.plots.plot1.Graph1.color = {  'r'  };
% plotConf.fig3.plots.plot1.Graph1.stylePred = {  '--'  };
% plotConf.fig3.plots.plot1.Graph1.styleReal = {  '-.'  };
% plotConf.fig3.plots.plot1.Graph2.constraints = 0;
% plotConf.fig3.plots.plot1.Graph2.source = 'input';
% plotConf.fig3.plots.plot1.Graph2.data = 2;
% plotConf.fig3.plots.plot1.Graph2.legend = {  'Pel,Chp'  };
% plotConf.fig3.plots.plot1.Graph2.position = 'right';
% plotConf.fig3.plots.plot1.Graph2.label = '';
% plotConf.fig3.plots.plot1.Graph2.limits = [-550.0000   +200.0000];
% plotConf.fig3.plots.plot1.Graph2.color = {  'k'  };
% plotConf.fig3.plots.plot1.Graph2.stylePred = {  '--'  };
% plotConf.fig3.plots.plot1.Graph2.styleReal = {  '-'  };
% plotConf.fig3.plots.plot1.Graph2.hide = 1;
% plotConf.fig3.xTickFaktor = xTickFaktor;
% plotConf.fig3.lineWidth = 0.5;
% 
% 
% 
% plotConf.fig4.name = 'PelCont vs PelDemCont  PelEV vs PelDemEV';
% plotConf.fig4.title = 'P_{el,cont} vs P_{el,dem,cont} P_{el,ev} vs P_{el,dem,ev}';
% plotConf.fig4.live = 1;
% plotConf.fig4.size = [+930.0000    +30.0000   +300.0000   +600.0000];
% plotConf.fig4.plots.plot1.title = 'P_{el,dem,cont} vs P_{el,cont}';
% plotConf.fig4.plots.plot1.fileName = 'Pel,Dem,Cont vs Pel,Cont';
% plotConf.fig4.plots.plot1.xLabel = 'Time in Hours';
% plotConf.fig4.plots.plot1.xScale = 0.016667;
% plotConf.fig4.plots.plot1.Graph1.constraints = 0;
% plotConf.fig4.plots.plot1.Graph1.source = 'disturbance';
% plotConf.fig4.plots.plot1.Graph1.data = 3;
% plotConf.fig4.plots.plot1.Graph1.legend = {  'P_{el,dem,cont}'  };
% plotConf.fig4.plots.plot1.Graph1.position = 'left';
% plotConf.fig4.plots.plot1.Graph1.label = 'P in kW';
% plotConf.fig4.plots.plot1.Graph1.limits = [-30.0000    +0.0000];
% plotConf.fig4.plots.plot1.Graph1.color = {  [+1.0000   +0.0000   +0.0000]  };
% plotConf.fig4.plots.plot1.Graph1.stylePred = {  '--'  };
% plotConf.fig4.plots.plot1.Graph1.styleReal = {  '-.'  };
% plotConf.fig4.plots.plot1.Graph2.constraints = 0;
% plotConf.fig4.plots.plot1.Graph2.source = 'input';
% plotConf.fig4.plots.plot1.Graph2.data = 3;
% plotConf.fig4.plots.plot1.Graph2.legend = {  'P_{el,cont}'  };
% plotConf.fig4.plots.plot1.Graph2.position = 'right';
% plotConf.fig4.plots.plot1.Graph2.label = '';
% plotConf.fig4.plots.plot1.Graph2.limits = [-30.0000    +0.0000];
% plotConf.fig4.plots.plot1.Graph2.color = {  [+0.0000   +0.0000   +0.0000]  };
% plotConf.fig4.plots.plot1.Graph2.stylePred = {  '--'  };
% plotConf.fig4.plots.plot1.Graph2.styleReal = {  '-'  };
% plotConf.fig4.plots.plot1.Graph2.hide = 1;
% 
% plotConf.fig4.plots.plot2.title = 'Pel,EV vs Pel,Dem,EV';
% plotConf.fig4.plots.plot2.fileName = 'P elEV vs P elDemEV';
% plotConf.fig4.plots.plot2.xLabel = 'Time in Hours';
% plotConf.fig4.plots.plot2.xScale = 0.016667;
% plotConf.fig4.plots.plot2.Graph1.constraints = 0;
% plotConf.fig4.plots.plot2.Graph1.source = 'input';
% plotConf.fig4.plots.plot2.Graph1.data = 4;
% plotConf.fig4.plots.plot2.Graph1.legend = {  'P_{el.ev}'  };
% plotConf.fig4.plots.plot2.Graph1.position = 'left';
% plotConf.fig4.plots.plot2.Graph1.label = 'P in kW';
% plotConf.fig4.plots.plot2.Graph1.limits = [-300.0000     +0.0000];
% plotConf.fig4.plots.plot2.Graph1.color = {  [+0.0000   +0.0000   +0.0000]  };
% plotConf.fig4.plots.plot2.Graph1.stylePred = {  '-'  };
% plotConf.fig4.plots.plot2.Graph1.styleReal = {  '-'  };
% plotConf.fig4.plots.plot2.Graph2.constraints = 0;
% plotConf.fig4.plots.plot2.Graph2.source = 'disturbance';
% plotConf.fig4.plots.plot2.Graph2.data = 4;
% plotConf.fig4.plots.plot2.Graph2.legend = {  'P_{el,dem,ev}'  };
% plotConf.fig4.plots.plot2.Graph2.position = 'right';
% plotConf.fig4.plots.plot2.Graph2.label = 'P in kW';
% plotConf.fig4.plots.plot2.Graph2.limits = [-300.0000     +0.0000];
% plotConf.fig4.plots.plot2.Graph2.color = {  [+1.0000   +0.0000   +0.0000]  };
% plotConf.fig4.plots.plot2.Graph2.stylePred = {  '--'  };
% plotConf.fig4.plots.plot2.Graph2.styleReal = {  '-.'  };
% plotConf.fig4.plots.plot2.Graph2.hide = 1;
% plotConf.fig4.xTickFaktor = xTickFaktor;
% plotConf.fig4.lineWidth = 0.5;
% 
% 


% 
% 
% 
% plotConf.fig6.name = 'J mon ';
% plotConf.fig6.title = 'J_{mon} ';
% plotConf.fig6.live = 0;
% plotConf.fig6.size = [+330.0000    +30.0000   +300.0000   +600.0000];
% plotConf.fig6.plots.plot1.title = 'J_{mon}  ';
% plotConf.fig6.plots.plot1.fileName = 'J mon  ';
% plotConf.fig6.plots.plot1.xLabel = 'Time in Hours';
% plotConf.fig6.plots.plot1.xScale = 0.016667;
% plotConf.fig6.plots.plot1.Graph1.constraints = 0;
% plotConf.fig6.plots.plot1.Graph1.source = 'mon_costs';
% plotConf.fig6.plots.plot1.Graph1.data = 1;
% plotConf.fig6.plots.plot1.Graph1.legend = {  'J_{mon}'  };
% plotConf.fig6.plots.plot1.Graph1.position = 'left';
% plotConf.fig6.plots.plot1.Graph1.label = 'J_{mon} in ';
% plotConf.fig6.plots.plot1.Graph1.limits = [];
% plotConf.fig6.plots.plot1.Graph1.color = {  [+1.0000   +0.0000   +0.0000]  };
% plotConf.fig6.plots.plot1.Graph1.stylePred = {  '--'  };
% plotConf.fig6.plots.plot1.Graph1.styleReal = {  '-.'  };
% plotConf.fig6.xTickFaktor = xTickFaktor;
% plotConf.fig6.lineWidth = 0.5;
% 
% 
% 
% plotConf.fig7.name = 'J opt';
% plotConf.fig7.title = 'J_{opt}';
% plotConf.fig7.live = 1;
% plotConf.fig7.size = [+330.0000    +30.0000   +300.0000   +600.0000];
% plotConf.fig7.plots.plot1.title = 'J_{opt}';
% plotConf.fig7.plots.plot1.fileName = 'J opt';
% plotConf.fig7.plots.plot1.xLabel = 'Time in Hours';
% plotConf.fig7.plots.plot1.xScale = 0.016667;
% plotConf.fig7.plots.plot1.Graph1.constraints = 0;
% plotConf.fig7.plots.plot1.Graph1.source = 'opt_costs';
% plotConf.fig7.plots.plot1.Graph1.data = 1;
% plotConf.fig7.plots.plot1.Graph1.legend = {  'J_{opt}'  };
% plotConf.fig7.plots.plot1.Graph1.position = 'left';
% plotConf.fig7.plots.plot1.Graph1.label = 'J_{opt} in  ';
% plotConf.fig7.plots.plot1.Graph1.limits = [];
% plotConf.fig7.plots.plot1.Graph1.color = {  [+1.0000   +0.0000   +0.0000]  };
% plotConf.fig7.plots.plot1.Graph1.stylePred = {  '--'  };
% plotConf.fig7.plots.plot1.Graph1.styleReal = {  '-'  };
% plotConf.fig7.xTickFaktor = xTickFaktor;
% plotConf.fig7.lineWidth = 0.5;
% 
% 
% 
% plotConf.fig8.name = 'Peak costs';
% plotConf.fig8.title = 'Peak costs';
% plotConf.fig8.live = 0;
% plotConf.fig8.size = [+330.0000    +30.0000   +300.0000   +600.0000];
% plotConf.fig8.plots.plot1.title = 'Peak costs';
% plotConf.fig8.plots.plot1.fileName = 'Peak costs';
% plotConf.fig8.plots.plot1.xLabel = 'Time in Hours';
% plotConf.fig8.plots.plot1.xScale = 0.016667;
% plotConf.fig8.plots.plot1.Graph1.constraints = 0;
% plotConf.fig8.plots.plot1.Graph1.source = 'peak_costs_per_k';
% plotConf.fig8.plots.plot1.Graph1.data = 1;
% plotConf.fig8.plots.plot1.Graph1.legend = {  'Peak costs'  };
% plotConf.fig8.plots.plot1.Graph1.position = 'left';
% plotConf.fig8.plots.plot1.Graph1.label = 'peak costs in ';
% plotConf.fig8.plots.plot1.Graph1.limits = [];
% plotConf.fig8.plots.plot1.Graph1.color = {  [+1.0000   +0.0000   +0.0000]  };
% plotConf.fig8.plots.plot1.Graph1.stylePred = {  '--'  };
% plotConf.fig8.plots.plot1.Graph1.styleReal = {  '-'  };
% plotConf.fig8.xTickFaktor = xTickFaktor;
% plotConf.fig8.lineWidth = 0.5;
% 
% 
% 
% plotConf.fig9.name = 'PelBat';
% plotConf.fig9.title = 'P_{el,bat}';
% plotConf.fig9.live = 1;
% plotConf.fig9.size = [+930.0000    +30.0000   +300.0000   +600.0000];
% plotConf.fig9.plots.plot1.title = 'P_{el,bat}';
% plotConf.fig9.plots.plot1.fileName = 'Pel,Bat';
% plotConf.fig9.plots.plot1.xLabel = 'Time in Hours';
% plotConf.fig9.plots.plot1.xScale = 0.016667;
% plotConf.fig9.plots.plot1.Graph1.constraints = 0;
% plotConf.fig9.plots.plot1.Graph1.source = 'custom';
% plotConf.fig9.plots.plot1.Graph1.data = @get_P_elBat;
% plotConf.fig9.plots.plot1.Graph1.legend = {  'P_{charge,max}'  'P_{el,bat}'  'P_{charge,min}'  };
% plotConf.fig9.plots.plot1.Graph1.position = 'left';
% plotConf.fig9.plots.plot1.Graph1.label = 'P_{el,bat} in kW';
% plotConf.fig9.plots.plot1.Graph1.limits = [];
% plotConf.fig9.plots.plot1.Graph1.color = {  'r'  'k'  'r'  };
% plotConf.fig9.plots.plot1.Graph1.stylePred = {  '--'  '--'  '--'  };
% plotConf.fig9.plots.plot1.Graph1.styleReal = {  '-'  '-'  '-'  };
% plotConf.fig9.xTickFaktor = xTickFaktor;
% plotConf.fig9.lineWidth = 0.5;
% 
% 
% 
% plotConf.fig10.name = 'P elDemCrit vs P elRen';
% plotConf.fig10.title = 'P_{el,dem,crit} vs P_{el,ren}';
% plotConf.fig10.live = 1;
% plotConf.fig10.size = [+30.0000    +30.0000   +300.0000   +600.0000];
% plotConf.fig10.plots.plot1.title = 'P_{el,dem,crit} vs P_{el,ren}';
% plotConf.fig10.plots.plot1.fileName = 'P elDemCrit vs P elRen';
% plotConf.fig10.plots.plot1.xLabel = 'Time in Hours';
% plotConf.fig10.plots.plot1.xScale = 0.016667;
% plotConf.fig10.plots.plot1.Graph1.constraints = 0;
% plotConf.fig10.plots.plot1.Graph1.source = 'disturbance';
% plotConf.fig10.plots.plot1.Graph1.data = 2;
% plotConf.fig10.plots.plot1.Graph1.legend = {  'P_{el,dem,crit} '  };
% plotConf.fig10.plots.plot1.Graph1.position = 'left';
% plotConf.fig10.plots.plot1.Graph1.label = 'P  in kW';
% plotConf.fig10.plots.plot1.Graph1.limits = [-150.0000   +600.0000];
% plotConf.fig10.plots.plot1.Graph1.color = {  [+1.0000   +0.0000   +0.0000]  };
% plotConf.fig10.plots.plot1.Graph1.stylePred = {  '--'  };
% plotConf.fig10.plots.plot1.Graph1.styleReal = {  '-.'  };
% plotConf.fig10.plots.plot1.Graph2.constraints = 0;
% plotConf.fig10.plots.plot1.Graph2.source = 'disturbance';
% plotConf.fig10.plots.plot1.Graph2.data = 1;
% plotConf.fig10.plots.plot1.Graph2.legend = {  'P_{el,ren}'  };
% plotConf.fig10.plots.plot1.Graph2.position = 'right';
% plotConf.fig10.plots.plot1.Graph2.label = '';
% plotConf.fig10.plots.plot1.Graph2.limits = [-150.0000   +600.0000];
% plotConf.fig10.plots.plot1.Graph2.color = {  'k'  };
% plotConf.fig10.plots.plot1.Graph2.stylePred = {  '--'  };
% plotConf.fig10.plots.plot1.Graph2.styleReal = {  '-'  };
% plotConf.fig10.plots.plot1.Graph2.hide = 1;
% plotConf.fig10.xTickFaktor = xTickFaktor;
% plotConf.fig10.lineWidth = 0.5;
% 
% 
% 
% plotConf.fig11.name = 'heat_dem_sup';
% plotConf.fig11.title = 'P_{heat,dem} vs. P_{el,chp}';
% plotConf.fig11.live = 1;
% plotConf.fig11.size = [+30.0000    +30.0000   +300.0000   +600.0000];
% plotConf.fig11.plots.plot1.title = '';
% plotConf.fig11.plots.plot1.fileName = 'P elDemCrit vs P elRen';
% plotConf.fig11.plots.plot1.xLabel = 'Time in Hours';
% plotConf.fig11.plots.plot1.xScale = 0.016667;
% plotConf.fig11.plots.plot1.Graph1.constraints = 0;
% plotConf.fig11.plots.plot1.Graph1.source = 'custom';
% plotConf.fig11.plots.plot1.Graph1.data = @(k,N_pred,V)(deal(0.751.*V.d_traj_real(end,1:k+1),0.751.*V.d_pred_matrix(end,:)));
% plotConf.fig11.plots.plot1.Graph1.legend = {  'c_{CHP} \cdot P_{heat,dem}'  };
% plotConf.fig11.plots.plot1.Graph1.position = 'left';
% plotConf.fig11.plots.plot1.Graph1.label = 'P  in kW';
% plotConf.fig11.plots.plot1.Graph1.limits = [+0.0000   +50.0000];
% plotConf.fig11.plots.plot1.Graph1.color = {  [+1.0000   +0.0000   +0.0000]  };
% plotConf.fig11.plots.plot1.Graph1.stylePred = {  '--'  };
% plotConf.fig11.plots.plot1.Graph1.styleReal = {  '-.'  };
% plotConf.fig11.plots.plot1.Graph2.constraints = 0;
% plotConf.fig11.plots.plot1.Graph2.source = 'input';
% plotConf.fig11.plots.plot1.Graph2.data = 2;
% plotConf.fig11.plots.plot1.Graph2.legend = {  'P_{el,chp}'  };
% plotConf.fig11.plots.plot1.Graph2.position = 'right';
% plotConf.fig11.plots.plot1.Graph2.label = '';
% plotConf.fig11.plots.plot1.Graph2.limits = [+0.0000   +50.0000];
% plotConf.fig11.plots.plot1.Graph2.color = {  'k'  };
% plotConf.fig11.plots.plot1.Graph2.stylePred = {  '--'  };
% plotConf.fig11.plots.plot1.Graph2.styleReal = {  '-'  };
% plotConf.fig11.plots.plot1.Graph2.hide = 1;
% plotConf.fig11.xTickFaktor = xTickFaktor;
% plotConf.fig11.lineWidth = 0.5;

save('../Configuration/plotconf_model1_advisory_report.mat', 'plotConf')
