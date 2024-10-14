function plot_covid_shocks(oo_,dates,T_covid,covid_horizon)
    % Plot smoothed shocks
    shocks = {'covid_chi'; 'covid_mu_w'; 'covid_mu_p'; 'covid_zeta'; 'covid_Gshock'; 'covid_Tb'; 'covid_Gamma'; 'covid_mp'};
    shock_labels = {'Mg. Util'; 'Wage markup'; 'Price markup'; 'Mg. Eff. Inv.'; 'Govt. Cons.'; 'Transfers'; 'TFP'; 'Monetary Policy'};

    h = figure;
    for jj = 1:size(shocks,1)
        currshock = strcat('ee_',shocks{jj});
        % exoindex  = find(strcmp(M_.exo_names, currshock));

        subplot(3,3,jj)
        plot(dates(T_covid-3:T_covid+covid_horizon+1), oo_.SmoothedShocks.(currshock)(T_covid-3:T_covid+covid_horizon+1), 'Linewidth', 2), hold on
        plot(dates(T_covid-3:T_covid+covid_horizon+1), zeros(size(dates(T_covid-3:T_covid+covid_horizon+1))), 'k--')
        xline(datetime(2019,12,31), 'k--')

        set(gca, 'Xtick', dates(T_covid-3:T_covid+covid_horizon+1))
        datetick('x','QQ-YY', 'keepticks', 'keeplimits')
        xtickangle(45)
        xlim([dates(T_covid-3) dates(T_covid+covid_horizon+1)]) 

        title(shock_labels{jj})
    end
    set(h, 'Position', [100,100,1000,1000])
    fig_name = strcat('figures/smoothed_shocks_covid.png');
    print(h,fig_name,'-dpng','-r400');
end