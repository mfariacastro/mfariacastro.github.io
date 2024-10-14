function plot_smoothed_observables(oo_,dates)
    % Plot smoothed observables
    varobs = {'y_growth', 'c_growth', 'i_growth', 'w_growth', 'g_growth', 'GT_Y', 'log_hours', 'FFR', 'inflation', 'inflation_exp10y', 'treasury10y', 'baa_spread'};
    varobs_labels = {'GDP growth', 'Consumption growth', 'Investment growth', 'Wage growth', 'Govt consumption growth', 'Govt spending/GDP',...
        'log Hours', 'FFR', 'Core PCE inflation', '10y inflation expectations', '10y Treasury', 'BAA spread'};

    h = figure;
    for jj = 1:size(varobs,2)
        currvar = varobs{jj};

        subplot(4,3,jj)
        plot(dates, oo_.SmoothedVariables.(currvar), 'LineWidth',1.5), hold on
        % plot(dates, zeros(size(dates)), 'k--')
        xline(datetime(2019,12,31), 'k--')
        title(varobs_labels{jj})
    end
    set(h, 'Position', [100,100,800,1000])
    fig_name = strcat('figures/smoothed_observables.png');
    print(h,fig_name,'-dpng','-r400');
end