function forecast_estimates_shock_uncertainty(M_,options_,oo_,unemp,date_start,dates_forecast,N,vars_plot,titles_plot,p,string)
    % Simulate the model forward and plot the path of endogenous variables
    % as well as shock decompositions
    
    T_forecast = size(dates_forecast,1); % how many periods to forecast
    
    ForecastVariables = struct;
    y0 = zeros(M_.endo_nbr,1);
    
    for jj=1:size(M_.endo_names,1)
        currvar = M_.endo_names{jj};
        y0(jj,1) = oo_.SmoothedVariables.(currvar)(end,1);
    end
    
    shocks = randn(T_forecast, M_.exo_nbr, N); % set all shocks to zero, this is where we change things for different scenarios
    shocks(:, M_.exo_nbr-7:M_.exo_nbr, :) = 0; % set Covid shocks to zero
    
    y_ = zeros(M_.endo_nbr, T_forecast+1, N);

    for ii = 1:N
        y_(:,:,ii) = simult_(M_,options_,y0,oo_.dr,shocks(:,:,ii),1);
    end
    
    for jj=1:size(M_.endo_names,1)
        currvar = M_.endo_names{jj};
        ForecastVariables.(currvar) = y_(jj,:,:);
    end

    % Unemployment is equal to the data until last point in the sample
    oo_.SmoothedVariables.unemp(1:end-1) = unemp(1:end-1);
    if ~isnan(unemp(end))
        oo_.SmoothedVariables.unemp(end) = unemp(end);
    end
    
    % Unemployment forecasts given by estimated function
    unemp_forecast = zeros(size(ForecastVariables.employment_gap));
    for ii = 1:N
        empgap_forecast = [oo_.SmoothedVariables.employment_gap(end); ForecastVariables.employment_gap(1,2:end,ii)'];
        unemp_forecast(1,:,ii) = p.unemp_b0 + p.unemp_b1*empgap_forecast;
    end
    ForecastVariables.unemp = unemp_forecast;

    % %% Simulate unemployment forward
    % %unemp_forecast = zeros(size(ForecastVariables.employment_gap));
    % %for ii = 1:N
    % %    forecast_temp = log_unemp(end)*ones(size(ForecastVariables.employment_gap,2),1);
    % %    empgap_forecast    = [oo_.SmoothedVariables.employment_gap(end); ForecastVariables.employment_gap(1,2:end,ii)'];
    % %    for tt = 2:size(forecast_temp,1)
    % %        forecast_temp(tt) = s.beta(1) + s.beta(2)*forecast_temp(tt-1) + s.beta(2)*empgap_forecast(tt);
    % %    end
    % %    unemp_forecast(1,:,ii) = exp(forecast_temp);
    % %end
    % %ForecastVariables.unemp = unemp_forecast;

    % Plots
    dates_plot = (date_start:calmonths(3):dates_forecast(end))';
    T_data     = size(dates_plot,1) - T_forecast;

    h=figure;
    for ii = 1:size(vars_plot,1)
        currvar = vars_plot{ii};
        subplot(2,2,ii)

        p25 = zeros(T_forecast,1);
        p50 = zeros(T_forecast,1);
        p75 = zeros(T_forecast,1);
        avg = zeros(T_forecast,1);
        se  = zeros(T_forecast,1);

        for tt = 1:T_forecast
            p25(tt,1) = quantile(ForecastVariables.(currvar)(1,tt+1,:),.16);
            p50(tt,1) = quantile(ForecastVariables.(currvar)(1,tt+1,:),.50);
            p75(tt,1) = quantile(ForecastVariables.(currvar)(1,tt+1,:),.84);
            avg(tt,1) = mean(ForecastVariables.(currvar)(1,tt+1,:));
            se(tt,1)  = std(ForecastVariables.(currvar)(1,tt+1,:));
        end
        
        p25 = [oo_.SmoothedVariables.(currvar)(end-T_data+1:end); p25];
        p50 = [oo_.SmoothedVariables.(currvar)(end-T_data+1:end); p50];
        p75 = [oo_.SmoothedVariables.(currvar)(end-T_data+1:end); p75];
        avg = [oo_.SmoothedVariables.(currvar)(end-T_data+1:end); avg];
        se  = [zeros(T_data,1); se];

        if strcmp(currvar, 'FFR')
            p25 = max(0,p25);
            p50 = max(0,p50);
            p75 = max(0,p75);
            avg = max(0,avg);
        end
       
        plot(dates_plot, p50, 'LineWidth', 2), hold on
        currindex = find(strcmp(M_.endo_names, currvar));
        ss_temp  = oo_.steady_state(currindex)*ones(size(dates_plot,1),1);
        plot(dates_plot, ss_temp, 'k--')
        xline(dates_forecast(1)-calmonths(3), 'k--')
        plot(dates_plot, p25, 'LineWidth', 1)
        plot(dates_plot, p75, 'LineWidth', 1)
        x2 = [dates_plot; flipud(dates_plot)];
        inBetween = [p25, p75];
        fill(x2, [p25; flipud(p75)], 'b', 'FaceAlpha',0.10);
        
        axis tight
        grid minor
        if strcmp(currvar, 'y_growth')
            ylims = get(gca,'YLim');
            ylim([max(-3.0,ylims(1)) min(8.0,ylims(2))])
        % elseif strcmp(currvar, 'inflation')
        %     ylims = get(gca,'YLim');
        %     ylim([max(-1.0,ylims(1)) min(6.0,ylims(2))])
        % elseif strcmp(currvar, 'FFR')
        %     ylims = get(gca,'YLim');
        %     ylim([max(0.0,ylims(1)) min(10.0,ylims(2))])
        % elseif strcmp(currvar, 'output_gap')
        %     ylims = get(gca,'YLim');
        %     ylim([max(-8.0,ylims(1)) min(6.0,ylims(2))])
        end
               
        title(titles_plot{ii})
    end
    fig_name = strcat('figures/forecasts_ci_',string,'.png');
    set(h, 'Position', [100,100,1000,400])
    print(h,fig_name,'-dpng','-r400');

    % set(h, 'Position', [100,100,800,400])
    % fig_name = strcat('figures/irf_',curr_shock,'.png');
    % print(h,fig_name,'-dpng','-r400');
end