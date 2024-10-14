function plot_inflation_target(oo_,dates)

    h = figure;
    plot(dates, oo_.SmoothedVariables.inflation_exp10y, 'LineWidth', 2), hold on
    infl_target = 100*(exp(oo_.SmoothedVariables.Pi_tgt).^4-1);
    plot(dates, infl_target, 'LineWidth',2)
    plot(dates, 2*ones(size(dates)), 'k--')
    legend('Infl. Exp. 10y', 'Infl. target')

    fig_name = strcat('figures/inflation_target.png');
    print(h,fig_name,'-dpng','-r400');
end