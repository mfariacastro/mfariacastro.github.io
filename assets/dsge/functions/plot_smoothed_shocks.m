function plot_smoothed_shocks(oo_,dates)
    % Plot smoothed shocks
    shocks = {'Z'; 'mu_w'; 'mu_p'; 'zeta'; 'risk'; 'chi'; 'nx'; 'G'; 'Tb'; 'mp'; 'Pi_tgt'; 'risk_bgg'};
    shock_labels = {'TFP'; 'Wage markup'; 'Product markup'; 'Mg. eff. investment'; 'Safety premium';...
        'Aggregate demand'; 'Net exports'; 'Govt consumption'; 'Fiscal transfers'; 'Monetary policy'; 'Inflation target'; 'Risk BGG'};

    h = figure;
    for jj = 1:size(shocks,1)
        currshock = strcat('ee_',shocks{jj});
        % exoindex  = find(strcmp(M_.exo_names, currshock));

        subplot(6,2,jj)
        plot(dates, oo_.SmoothedShocks.(currshock), 'Linewidth', 1.5), hold on
        plot(dates, zeros(size(dates)), 'k--')
        xline(datetime(2019,12,31), 'k--')

        title(shock_labels{jj})
    end
    set(h, 'Position', [100,100,800,1000])
    fig_name = strcat('figures/smoothed_shocks.png');
    print(h,fig_name,'-dpng','-r400');
end