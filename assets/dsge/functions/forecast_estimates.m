function forecast_estimates(M_,options_,oo_,unemp,date_start,dates_forecast,vars_plot,titles_plot,p,string)

% Simulate the model forward to obtain unconditional forecasts
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

% Unemployment is equal to the data until last point in the sample
oo_.SmoothedVariables.unemp(1:end-1) = unemp(1:end-1);
if ~isnan(unemp(end))
    oo_.SmoothedVariables.unemp(end) = unemp(end);
end

% Unemployment forecasts given by estimated function
empgap_forecast = [oo_.SmoothedVariables.employment_gap(end); ForecastVariables.employment_gap(2:end)'];
unemp_forecast = p.unemp_b0 + p.unemp_b1*empgap_forecast;
ForecastVariables.unemp = unemp_forecast';

% Plots
dates_plot = (date_start:calmonths(3):dates_forecast(end))';
T_data     = size(dates_plot,1) - T_forecast;

h=figure;
for ii = 1:size(vars_plot,1)
    currvar   = vars_plot{ii};

    subplot(2,2,ii)
    temp = [oo_.SmoothedVariables.(currvar)(end-T_data+1:end); ForecastVariables.(currvar)(2:end)'];
    if strcmp(currvar, 'FFR')
        temp = max(0,temp);
    end

    plot(dates_plot, temp, 'LineWidth', 2), hold on
    currindex = find(strcmp(M_.endo_names, currvar));
    ss_temp  = oo_.steady_state(currindex)*ones(size(dates_plot,1),1);
    plot(dates_plot, ss_temp, 'k--')
    xline(dates_forecast(1)-calmonths(3), 'k--')
    axis tight
    grid minor
    if strcmp(currvar, 'y_growth')
        ylims = get(gca,'YLim');
        ylim([max(-3.0,ylims(1)) min(8.0,ylims(2))])
    end
    title(titles_plot{ii})
end
set(h, 'Position', [100,100,1000,400])

fig_name = strcat('figures/forecasts_',string,'.png');
print(h,fig_name,'-dpng','-r400');

% set(h, 'Position', [100,100,800,400])
% fig_name = strcat('figures/irf_',curr_shock,'.png');
% print(h,fig_name,'-dpng','-r400');
end