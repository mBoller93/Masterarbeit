function plotSubplot(p, m, n, PlotConfig, V, k, live, T_sim, common, instance)
%Function to plot values in subplots.
% Inputs: - object p of axes handles with m rows and n columns
%         - the index of the figure m
%         - the index of the plot n
%         - cell array PlotConfig containing the information about the plot
%         - struct V containing all values that should be plotted
%         - step k
%         - boolean variable live that indicates live plotting
%         - total simulation time
% The function plots the values from V to the axes given by p using the
% information from PlotConfig.

n_x = instance.model.n_x;
n_d = instance.model.n_u;
n_u = instance.model.n_d;
N_pred = common.config.N_pred;

xScale=PlotConfig{m,1}.plots{n,1}.xScale;
xTickFaktor=PlotConfig{m,1}.xTickFaktor;

graph(1) = PlotConfig{m,1}.plots{n,1}.Graph1;       % the array graph gives the path to graph 1 and 2
if(isfield(PlotConfig{m,1}.plots{n,1}, 'Graph2'))
    graph(2) = PlotConfig{m,1}.plots{n,1}.Graph2;
    
end

for g=1:length(graph)       %for loop for left and right axes usually
    if(strcmp(graph(g).position, 'left')||strcmp(graph(g).position, 'Left'))
        ax = p(m,n);
        if ~isempty(graph(g).limits)
            ylim(ax, graph(g).limits);                %Set limits for y-axis
        end
        xlim(ax, [0 T_sim]);                      %Set limits for x-axis
        xtickat = 0:xTickFaktor/xScale:T_sim-1;
        set(gca, 'XTick', xtickat, 'XTickLabel', cellstr( num2str( xtickat.'* xScale)  ) );
        ylabel(ax, graph(g).label);               %Label left axis
        grid on;
        set(ax, 'Box', 'off');                  %No marks at right axis
        hold on;
        
    elseif(strcmp(graph(g).position, 'right')||strcmp(graph(g).position, 'Right'))
        yyaxis(p(m,n), 'right');
        ax = p(m,n);
        if ~isempty(graph(g).limits)
            ylim(ax, graph(g).limits);                %Set limits for y-axis
        end
        xlim(ax, [0 T_sim]);
        xtickat = 0:xTickFaktor/xScale:T_sim-1;          %later replace 60 with 1/xscale)
        set(gca, 'XTick', xtickat, 'XTickLabel', cellstr( num2str( xtickat.'* xScale)  ) );
        ylabel(ax, graph(g).label);
        
        if( isfield( graph(g), 'hide' ) && graph(g).hide == 1)
            ax.YAxis(2).Visible = 'off';
        end
        hold on;
    end
    
    
    switch(graph(g).source)         % switch-structure to plot the values specified as source
        case 'state'
            
            x_pred_plot = reshape(V.x_pred, n_x, (N_pred+1));
            for i=1:length(graph(g).data)                       %for loop for data for same axis
                xIndex = graph(g).data(i);
                
                if(graph(g).constraints)
                    if(live)
                        stairs(ax, V.T_s*(0:k),V.constraints_traj(xIndex,1:k+1), ['r' graph(g).styleReal{i}],...
                            'HandleVisibility', 'off', 'LineWidth', PlotConfig{m,1}.lineWidth);      %%plot lower bound of previous constraints
                        stairs(ax, V.T_s*(0:k),V.constraints_traj(xIndex+n_x,1:k+1), ['r' graph(g).styleReal{i}],...
                            'HandleVisibility', 'off', 'LineWidth', PlotConfig{m,1}.lineWidth);  %%plot upper bound of previous constraints
                        
                        stairs(ax, V.T_s*(k:k+N_pred), [V.constraints_traj(xIndex, k+1) V.loopConstraints(xIndex, :)],...
                            ['r' graph(g).stylePred{i}], 'HandleVisibility', 'off', 'LineWidth', PlotConfig{m,1}.lineWidth) ; %%plot lower bound of current constraints
                        stairs(ax, V.T_s*(k:k+N_pred), [V.constraints_traj(xIndex+n_x,k+1) V.loopConstraints(xIndex+n_x, :)],...
                            ['r' graph(g).stylePred{i}], 'HandleVisibility', 'off', 'LineWidth', PlotConfig{m,1}.lineWidth) ; %%plot lower bound of current constraints
                    else
                        stairs(ax, V.T_s*(0:k+1), [V.constraints_traj(xIndex,1:k+1), V.constraints_traj(xIndex,k+1)], ...
                            ['r' graph(g).styleReal{i}], 'HandleVisibility', 'off', 'LineWidth', PlotConfig{m,1}.lineWidth);      %%plot lower bound of previous constraints
                        stairs(ax, V.T_s*(0:k+1), [V.constraints_traj(xIndex+n_x,1:k+1), V.constraints_traj(xIndex+n_x,k+1)],...
                            ['r' graph(g).styleReal{i}], 'HandleVisibility', 'off', 'LineWidth', PlotConfig{m,1}.lineWidth);  %%plot upper bound of previous constraints
                    end
                end
                
                if(live)
                    stairs(ax, V.T_s*(0:k), V.x_traj_real(xIndex,1:k+1), graph(g).styleReal{i}, 'Color', graph(g).color{i},...
                        'DisplayName', graph(g).legend{i}, 'LineWidth', PlotConfig{m,1}.lineWidth); %%  plotting x_traj_real
                    stairs(ax, V.T_s*(k:k+N_pred), x_pred_plot(xIndex, :), graph(g).stylePred{i}, 'Color', graph(g).color{i},...
                        'HandleVisibility', 'off', 'LineWidth', PlotConfig{m,1}.lineWidth);    %%  plotting x_traj_pred
                else
                    stairs(ax, V.T_s*(0:k+1), [V.x_traj_real(xIndex,1:k+1), V.x_traj_real(xIndex,k+1)],...
                        graph(g).styleReal{i}, 'Color', graph(g).color{i}, 'DisplayName', graph(g).legend{i}, 'LineWidth', PlotConfig{m,1}.lineWidth); %%  plotting x_traj_real
                end
            end
            
            
            
        case 'input'
            u_pred_plot = reshape(V.u_opt, n_u, N_pred);
            for i=1:length(graph(g).data)
                uIndex = graph(g).data(i);
                
                if(graph(g).constraints)
                    if(live)
                        stairs(ax, V.T_s*(0:k), V.constraints_traj((2*n_x)+uIndex, 1:k+1), ['r' graph(g).styleReal{i}],...
                            'HandleVisibility', 'off', 'LineWidth', PlotConfig{m,1}.lineWidth) ; %%plot lower bound of previous constraints
                        stairs(ax, V.T_s*(0:k), V.constraints_traj((2*n_x)+n_u+uIndex, 1:k+1), ['r' graph(g).styleReal{i}],...
                            'HandleVisibility', 'off', 'LineWidth', PlotConfig{m,1}.lineWidth); %%plot upper bound of previous constraints
                        
                        stairs(ax, V.T_s*(k:k+N_pred), [V.loopConstraints((2*n_x)+uIndex, :), V.loopConstraints((2*n_x)+uIndex, N_pred)], ...
                            ['r' graph(g).stylePred{i}], 'HandleVisibility', 'off', 'LineWidth', PlotConfig{m,1}.lineWidth) ; %%plot lower bound of current constraints
                        stairs(ax, V.T_s*(k:k+N_pred), [V.loopConstraints((2*n_x)+n_u+uIndex, :), V.loopConstraints((2*n_x)+n_u+uIndex, N_pred)], ...
                            ['r' graph(g).stylePred{i}], 'HandleVisibility', 'off', 'LineWidth', PlotConfig{m,1}.lineWidth) ; %%plot lower bound of current constraints
                    else
                        stairs(ax, V.T_s*(0:k+1), [V.constraints_traj((2*n_x)+uIndex, 1:k+1), V.constraints_traj((2*n_x)+uIndex, k+1)],...
                            ['r' graph(g).styleReal{i}], 'HandleVisibility', 'off', 'LineWidth', PlotConfig{m,1}.lineWidth) ; %%plot lower bound of previous constraints
                        stairs(ax, V.T_s*(0:k+1), [V.constraints_traj((2*n_x)+n_u+uIndex, 1:k+1), V.constraints_traj((2*n_x)+n_u+uIndex, k+1)],...
                            ['r' graph(g).styleReal{i}], 'HandleVisibility', 'off', 'LineWidth', PlotConfig{m,1}.lineWidth); %%plot upper bound of previous constraints
                        
                    end
                end
                
                if(live)
                    stairs(ax, V.T_s*(0:k), V.u_traj_real(uIndex, 1:k+1), graph(g).styleReal{i}, 'Color', graph(g).color{i},...
                        'DisplayName', graph(g).legend{i}, 'LineWidth', PlotConfig{m,1}.lineWidth); %%  plotting u_traj_real
                    stairs(ax, V.T_s*(k:k+N_pred), [u_pred_plot(uIndex, :), u_pred_plot(uIndex, N_pred)], graph(g).stylePred{i}, 'Color', graph(g).color{i},...
                        'HandleVisibility', 'off', 'LineWidth', PlotConfig{m,1}.lineWidth);    %%  plotting u_traj_pred
                else
                    stairs(ax, V.T_s*(0:k+1), [V.u_traj_real(uIndex, 1:k+1), V.u_traj_real(uIndex, k+1)],...
                        graph(g).styleReal{i}, 'Color', graph(g).color{i}, 'DisplayName', graph(g).legend{i}, 'LineWidth', PlotConfig{m,1}.lineWidth); %%  plotting u_traj_real
                end
            end
            
        case 'disturbance'
            d_pred_plot = reshape(V.d_pred, n_d, N_pred);
            for i=1:length(graph(g).data)
                dIndex = graph(g).data(i);
                
                if(graph(g).constraints)
                    if(live)
                        stairs(ax, V.T_s*(0:k), V.constraints_traj((2*n_x)+2*n_u+dIndex, 1:k+1), ['r' graph(g).styleReal{i}],...
                            'HandleVisibility', 'off', 'LineWidth', PlotConfig{m,1}.lineWidth) ; %%plot lower bound of previous constraints
                        stairs(ax, V.T_s*(0:k), V.constraints_traj((2*n_x)+2*n_u+n_d+dIndex, 1:k+1), ['r' graph(g).styleReal{i}],...
                            'HandleVisibility', 'off', 'LineWidth', PlotConfig{m,1}.lineWidth); %%plot upper bound of previous constraints
                        
                        stairs(ax, V.T_s*(k:k+N_pred), [V.loopConstraints((2*n_x)+2*n_u+dIndex, :), V.loopConstraints((2*n_x)+2*n_u+dIndex, N_pred)],...
                            ['r' graph(g).stylePred{i}], 'HandleVisibility', 'off', 'LineWidth', PlotConfig{m,1}.lineWidth) ; %%plot lower bound of current constraints
                        stairs(ax, V.T_s*(k:k+N_pred), [V.loopConstraints((2*n_x)+2*n_u+n_d+dIndex, :), V.loopConstraints((2*n_x)+2*n_u+n_d+dIndex, N_pred)],...
                            ['r' graph(g).stylePred{i}], 'HandleVisibility', 'off', 'LineWidth', PlotConfig{m,1}.lineWidth) ; %%plot lower bound of current constraints
                    else
                        stairs(ax, V.T_s*(0:k+1), [V.constraints_traj((2*n_x)+2*n_u+dIndex, 1:k+1), V.constraints_traj((2*n_x)+2*n_u+dIndex, k+1)],...
                            ['r' graph(g).styleReal{i}], 'HandleVisibility', 'off', 'LineWidth', PlotConfig{m,1}.lineWidth) ; %%plot lower bound of previous constraints
                        stairs(ax, V.T_s*(0:k+1), [V.constraints_traj((2*n_x)+2*n_u+n_d+dIndex, 1:k+1), V.constraints_traj((2*n_x)+2*n_u+n_d+dIndex, k+1)],...
                            ['r' graph(g).styleReal{i}], 'HandleVisibility', 'off', 'LineWidth', PlotConfig{m,1}.lineWidth); %%plot upper bound of previous constraints
                        
                    end
                end
                
                if(live)
                    stairs(ax, V.T_s*(0:k), V.d_traj_real(dIndex, 1:k+1), graph(g).styleReal{i}, 'Color', graph(g).color{i},...
                        'DisplayName', graph(g).legend{i}, 'LineWidth', PlotConfig{m,1}.lineWidth); %%  plotting d_traj_real
                    stairs(ax, V.T_s*(k:k+N_pred), [d_pred_plot(dIndex, :), d_pred_plot(dIndex, N_pred)], ...
                        graph(g).stylePred{i}, 'Color', graph(g).color{i}, 'HandleVisibility', 'off', 'LineWidth', PlotConfig{m,1}.lineWidth);    %%  plotting d_traj_pred
                else
                    stairs(ax, V.T_s*(0:k+1), [V.d_traj_real(dIndex, 1:k+1), V.d_traj_real(dIndex, k+1)],...
                        graph(g).styleReal{i}, 'Color', graph(g).color{i}, 'DisplayName', graph(g).legend{i}, 'LineWidth', PlotConfig{m,1}.lineWidth); %%  plotting d_traj_real
                end
                
            end
            
        case 'mon_costs'
            costDataReal = V.J_mon_traj_real(1:k+1);
            costDataPred = V.J_mon_pred';
            
            if(live)
                stairs(ax, V.T_s*(0:k), costDataReal, graph(g).styleReal{1}, 'Color', graph(g).color{1},...
                    'DisplayName', graph(g).legend{1}, 'LineWidth', PlotConfig{m,1}.lineWidth); %%plotting J_mon_traj_real
                stairs(ax, V.T_s*(k:k+N_pred), [costDataPred; costDataPred(N_pred)], graph(g).stylePred{1}, 'Color', graph(g).color{1},...
                    'HandleVisibility', 'off', 'LineWidth', PlotConfig{m,1}.lineWidth);
            else
                stairs(ax, V.T_s*(0:k+1), [costDataReal, costDataReal(k+1)], graph(g).styleReal{1}, 'Color', graph(g).color{1},...
                    'DisplayName', graph(g).legend{1}, 'LineWidth', PlotConfig{m,1}.lineWidth); %%plotting J_mon_traj_real
            end
            
        case 'mon_costs_per_k'
            costDataReal = V.J_mon_k_traj_real(1:k+1);
            costDataPred = V.J_mon_k_pred';
            
            if(live)
                stairs(ax, V.T_s*(0:k), costDataReal, graph(g).styleReal{1}, 'Color', graph(g).color{1},...
                    'DisplayName', graph(g).legend{1}, 'LineWidth', PlotConfig{m,1}.lineWidth); %%plotting J_mon_traj_real
                stairs(ax, V.T_s*(k:k+N_pred), [costDataPred; costDataPred(N_pred)], graph(g).stylePred{1}, 'Color', graph(g).color{1},...
                    'HandleVisibility', 'off', 'LineWidth', PlotConfig{m,1}.lineWidth);
            else
                stairs(ax, V.T_s*(0:k+1), [costDataReal, costDataReal(k+1)], graph(g).styleReal{1}, 'Color', graph(g).color{1},...
                    'DisplayName', graph(g).legend{1}, 'LineWidth', PlotConfig{m,1}.lineWidth); %%plotting J_mon_traj_real
            end
            
        case 'opt_costs'
            if(live)
                stairs(ax, V.T_s*(0:k), V.J_opt_traj_real(1:k+1), graph(g).styleReal{1}, 'Color', graph(g).color{1},...
                    'DisplayName', graph(g).legend{1}, 'LineWidth', PlotConfig{m,1}.lineWidth); %%plotting J_opt_traj_real
                stairs(ax, V.T_s*(k:k+N_pred), [V.J_opt_pred'; V.J_opt_pred(N_pred)], graph(g).stylePred{1}, 'Color', graph(g).color{1},...
                    'HandleVisibility', 'off', 'LineWidth', PlotConfig{m,1}.lineWidth);
            else
                stairs(ax, V.T_s*(0:k+1), [V.J_opt_traj_real(1:k+1), V.J_opt_traj_real(k+1)],...
                    graph(g).styleReal{1}, 'Color', graph(g).color{1}, 'DisplayName', graph(g).legend{1}, 'LineWidth', PlotConfig{m,1}.lineWidth); %%plotting J_opt_traj_real
            end
            
        case 'opt_costs_per_k'
            costDataReal = V.J_opt_k_traj_real(1:k+1);
            costDataPred = V.J_opt_k_pred';
            if(live)
                stairs(ax, V.T_s*(0:k), costDataReal, graph(g).styleReal{1}, 'Color', graph(g).color{1},...
                    'DisplayName', graph(g).legend{1}, 'LineWidth', PlotConfig{m,1}.lineWidth); %%plotting J_mon_traj_real
                stairs(ax, V.T_s*(k:k+N_pred), [costDataPred; costDataPred(N_pred)], graph(g).stylePred{1}, 'Color', graph(g).color{1},...
                    'HandleVisibility', 'off', 'LineWidth', PlotConfig{m,1}.lineWidth);
            else
                stairs(ax, V.T_s*(0:k+1), [costDataReal, costDataReal(k+1)], graph(g).styleReal{1}, 'Color', graph(g).color{1},...
                    'DisplayName', graph(g).legend{1}, 'LineWidth', PlotConfig{m,1}.lineWidth); %%plotting J_mon_traj_real
            end
            
        case 'peak_costs_per_k'
            costDataReal = V.peak_cost_traj_real(1:k+1);
            costDataPred = V.peak_cost_pred';
            if(live)
                stairs(ax, V.T_s*(0:k), costDataReal, graph(g).styleReal{1}, 'Color', graph(g).color{1},...
                    'DisplayName', graph(g).legend{1}, 'LineWidth', PlotConfig{m,1}.lineWidth); %%plotting J_mon_traj_real
                stairs(ax, V.T_s*(k:k+N_pred), [costDataPred; costDataPred(N_pred)], graph(g).stylePred{1}, 'Color', graph(g).color{1},...
                    'HandleVisibility', 'off', 'LineWidth', PlotConfig{m,1}.lineWidth);
            else
                stairs(ax, V.T_s*(0:k+1), [costDataReal, costDataReal(k+1)], graph(g).styleReal{1}, 'Color', graph(g).color{1},...
                    'DisplayName', graph(g).legend{1}, 'LineWidth', PlotConfig{m,1}.lineWidth); %%plotting J_mon_traj_real
            end
            
        case 'price'
            if(live)
                stairs(ax, V.T_s*(0:k), V.price_traj_real(1:k+1), graph(g).styleReal{1}, 'Color', graph(g).color{1},...
                    'DisplayName', graph(g).legend{1}, 'LineWidth', PlotConfig{m,1}.lineWidth); %%plotting price_traj_real
                stairs(ax, V.T_s*(k:k+N_pred), [V.price_pred'; V.price_pred(N_pred)], graph(g).stylePred{1}, 'Color', graph(g).color{1},...
                    'HandleVisibility', 'off', 'LineWidth', PlotConfig{m,1}.lineWidth);         %%plotting predicted price
            else
                stairs(ax, V.T_s*(0:k+1), [V.price_traj_real(1:k+1), V.price_traj_real(k+1)],...
                    graph(g).styleReal{1}, 'Color', graph(g).color{1}, 'DisplayName', graph(g).legend{1}, 'LineWidth', PlotConfig{m,1}.lineWidth); %%plotting price_traj_real
            end
            
        case 'custom'
            
            [data_traj_real, data_traj_pred] = graph(g).data(k, N_pred, V);
            pred_length = size(data_traj_pred, 2);
            for i=1:size(data_traj_real, 1)
                dIndex = i;
                if(live)
                    stairs(ax, V.T_s*(0:k), data_traj_real(dIndex, 1:k+1), graph(g).styleReal{i}, 'Color', graph(g).color{i},...
                        'DisplayName', graph(g).legend{i}, 'LineWidth', PlotConfig{m,1}.lineWidth); %%  plotting d_traj_real
                    stairs(ax, V.T_s*(k:k+pred_length), [data_traj_pred(dIndex, :), data_traj_pred(dIndex, N_pred)], ...
                        graph(g).stylePred{1}, 'Color', graph(g).color{i}, 'HandleVisibility', 'off', 'LineWidth', PlotConfig{m,1}.lineWidth);    %%  plotting d_traj_pred
                else
                    stairs(ax, V.T_s*(0:k+1), [data_traj_real(dIndex, 1:k+1), data_traj_real(dIndex, k+1)],...
                        graph(g).styleReal{1}, 'Color', graph(g).color{i}, 'DisplayName', graph(g).legend{i}, 'LineWidth', PlotConfig{m,1}.lineWidth); %%  plotting d_traj_real
                end
                
            end
            
    end
end

if(live)
    % add prediction horizon bars

    ylimpatch=get(ax,'YLim');
    vert = [V.T_s*k ylimpatch(1); V.T_s*(k+N_pred) ylimpatch(1); V.T_s*(k+N_pred) ylimpatch(2); V.T_s*k ylimpatch(2)];
    faces = [1 2 3 4];  %Create grey box for prediction horizon:
    patch(ax, 'Faces',faces,'Vertices',vert,'Facecolor','black','FaceAlpha',.04, 'HandleVisibility', 'off');
end

legend; %Create legends

end

