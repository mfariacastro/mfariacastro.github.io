function [unemp_b0, unemp_b1] = employment_gap(oo_,dates,unemp)

    empgap = oo_.SmoothedVariables.employment_gap;

    s = regstats(unemp, empgap, 'linear', {'r', 'beta'});

    if isnan(unemp(end))
        unemp_b0 = s.beta(1) + s.r(end-1);
        unemp_b1 = s.beta(2);
    else
        unemp_b0 = s.beta(1) + s.r(end);
        unemp_b1 = s.beta(2);
    end
    
    unemp_hat = unemp_b0 + unemp_b1*empgap;
    
    h = figure;
    plot(dates, unemp, 'LineWidth',2), hold on
    plot(dates, unemp_hat, 'LineWidth',2)
    legend('Unemployment rate', 'Model implied', 'Location','northwest')
    fig_name = 'figures/unemp_vs_unemphat.png';
    print(h,fig_name,'-dpng','-r400');
     
    % y = year(dates);
    % q = quarter(dates);
    % T = table(y, q, empgap, unemp);
    % writetable(T,'empgap.xlsx')
end