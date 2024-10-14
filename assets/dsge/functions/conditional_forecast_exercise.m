function conditional_forecast_exercise(M_,options_,oo_,cf_nocut,cf_25bpscut,cf_50bpscut,date_start,dates_forecast,vars_plot,titles_plot)
    % Simulate the model forward and plot the path of endogenous variables
    
    T_forecast = size(dates_forecast,1); % how many periods to forecast
    
    ForecastVariables = struct;
    y0 = zeros(M_.endo_nbr,1);
    
    for jj=1:size(M_.endo_names,1)
        currvar = M_.endo_names{jj};
        y0(jj,1) = oo_.SmoothedVariables.(currvar)(end,1);
    end
    
    shocks = zeros(T_forecast, M_.exo_nbr); % set all shocks to zero, this is where we change things for different scenarios
    
    y_ = simult_(M_,options_,y0,oo_.dr,shocks,1);
    
    for jj=1:size(M_.endo_names,1)
        currvar = M_.endo_names{jj};
        ForecastVariables.(currvar) = y_(jj,:);
    end

    % Adjust colors
    C = colororder('gem');
    Cnew = C(2:end,:);
    Cyellow = Cnew(2,:);
    Cnew = [Cnew(1,:); Cnew(3:end,:)];
    Cnew = [Cnew; Cyellow];

    % Plots
    dates_plot = (date_start:calmonths(3):dates_forecast(end))';
    T_data     = size(dates_plot,1) - T_forecast;

    % 1. Unconditional vs. no cuts
    h=figure;
    for ii = 1:size(vars_plot,1)
        currvar   = vars_plot{ii};

        subplot(2,2,ii)
        temp_base = [oo_.SmoothedVariables.(currvar)(end-T_data+1:end); ForecastVariables.(currvar)(2:end)'];
        temp_cf   = [oo_.SmoothedVariables.(currvar)(end-T_data+1:end); cf_nocut.conditional_forecast.cond.Mean.(currvar)(2:T_forecast+1)];
        if strcmp(currvar, 'FFR')
            temp_base = max(0,temp_base);
            temp_cf   = max(0,temp_cf);
        end
        plot(dates_plot, temp_base, 'LineWidth', 2), hold on
        plot(dates_plot, temp_cf, '--', 'LineWidth', 2)
        currindex = find(strcmp(M_.endo_names, currvar));
        ss_temp  = oo_.steady_state(currindex)*ones(size(dates_plot,1),1);
        plot(dates_plot, ss_temp, 'k--')
        xline(dates_forecast(1)-calmonths(3), 'k--')
        axis tight
        grid minor
        if strcmp(currvar, 'y_growth') || strcmp(currvar, 'r_star')
            ylims = get(gca,'YLim');
            ylim([max(-3.0,ylims(1)) min(8.0,ylims(2))])
        end
        if ii == 4
            legend('Unconditional', 'No cut', 'Location', 'southeast');
            legend('boxoff')
        end
        title(titles_plot{ii})
    end
    set(h, 'Position', [100,100,1000,400])
    fig_name = 'figures/conditional_forecast_nocut.png';
    print(h,fig_name,'-dpng','-r400');

    % 2. Unconditional vs 25 bps cut
    h=figure;
    for ii = 1:size(vars_plot,1)
        currvar   = vars_plot{ii};
        subplot(2,2,ii)
        
        temp_base = [oo_.SmoothedVariables.(currvar)(end-T_data+1:end); ForecastVariables.(currvar)(2:end)'];
        temp_cf   = [oo_.SmoothedVariables.(currvar)(end-T_data+1:end); cf_25bpscut.conditional_forecast.cond.Mean.(currvar)(2:T_forecast+1)];
        if strcmp(currvar, 'FFR')
            temp_base = max(0,temp_base);
            temp_cf   = max(0,temp_cf);
        end
        plot(dates_plot, temp_base, 'LineWidth', 2), hold on
        plot(dates_plot, temp_cf, '--', 'LineWidth', 2)
        currindex = find(strcmp(M_.endo_names, currvar));
        ss_temp  = oo_.steady_state(currindex)*ones(size(dates_plot,1),1);
        plot(dates_plot, ss_temp, 'k--')
        xline(dates_forecast(1)-calmonths(3), 'k--')
        axis tight
        grid minor
        if strcmp(currvar, 'y_growth') || strcmp(currvar, 'r_star')
            ylims = get(gca,'YLim');
            ylim([max(-3.0,ylims(1)) min(8.0,ylims(2))])
        end
        if ii == 4
            legend('Unconditional', '25 bps cut', 'Location', 'southeast');
            legend('boxoff');
        end        
        title(titles_plot{ii})
    end
    % colororder(Cnew);
    set(h, 'Position', [100,100,1000,400])
    fig_name = 'figures/conditional_forecast_25bpscut.png';
    print(h,fig_name,'-dpng','-r400');

    % 3. Unconditional vs 50 bps cut
    h=figure;
    for ii = 1:size(vars_plot,1)
        currvar   = vars_plot{ii};
        subplot(2,2,ii)
        
        temp_base = [oo_.SmoothedVariables.(currvar)(end-T_data+1:end); ForecastVariables.(currvar)(2:end)'];
        temp_cf   = [oo_.SmoothedVariables.(currvar)(end-T_data+1:end); cf_50bpscut.conditional_forecast.cond.Mean.(currvar)(2:T_forecast+1)];
        if strcmp(currvar, 'FFR')
            temp_base = max(0,temp_base);
            temp_cf   = max(0,temp_cf);
        end
        plot(dates_plot, temp_base, 'LineWidth', 2), hold on
        plot(dates_plot, temp_cf, '--', 'LineWidth', 2)
        currindex = find(strcmp(M_.endo_names, currvar));
        ss_temp  = oo_.steady_state(currindex)*ones(size(dates_plot,1),1);
        plot(dates_plot, ss_temp, 'k--')
        xline(dates_forecast(1)-calmonths(3), 'k--')
        axis tight
        grid minor
        if strcmp(currvar, 'y_growth') || strcmp(currvar, 'r_star')
            ylims = get(gca,'YLim');
            ylim([max(-3.0,ylims(1)) min(8.0,ylims(2))])
        end
        if ii == 4
            legend('Unconditional', '50 bps cut', 'Location', 'southeast');
            legend('boxoff');
        end        
        title(titles_plot{ii})
    end
    % colororder(Cnew);
    set(h, 'Position', [100,100,1000,400])
    fig_name = 'figures/conditional_forecast_50bpscut.png';
    print(h,fig_name,'-dpng','-r400');

end