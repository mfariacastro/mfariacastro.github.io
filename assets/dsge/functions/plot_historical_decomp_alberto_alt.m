function plot_historical_decomp_alberto_alt(M_,oo_,dates,vars,var_labels,start)
    % % Shocks grouped according to the reduced form definition on impact
    % supply_shocks    = {'Z'; 'mu_w'; 'mu_p'; 'Tb'; 'covid_mu_w'; 'covid_mu_p'; 'covid_Gamma'};
    % demand_shocks    = {'zeta'; 'covid_zeta'; 'chi'; 'covid_chi'; 'G';  'covid_Gshock';  'mp'; 'Pi_tgt'; 'covid_mp'; 'nx'; 'risk'; 'covid_Tb'};
    % other_shocks     = {};

    % Shocks grouped according to the reduced form definition over 4
    % quarters
    supply_shocks    = {'Z'; 'mu_w'; 'mu_p'; 'Tb'; 'covid_mu_w'; 'covid_mu_p'; 'covid_Gamma'; 'chi'; 'covid_chi'; 'risk';  'covid_Gshock'; 'covid_Tb'};
    demand_shocks    = {'zeta'; 'covid_zeta'; 'G';  'mp'; 'Pi_tgt'; 'covid_mp'; 'nx'; 'risk_bgg'};
    other_shocks     = {};

    for ii = 1:size(vars,1)
        currvar = vars{ii};
        endoindex  = find(strcmp(M_.endo_names, currvar));

        % smoothed variable
        smoothvar = oo_.shock_decomposition(endoindex, M_.exo_nbr+2, :);
        smoothvar = reshape(smoothvar,[],1);

        % 0. initial conditions
        initcond = oo_.shock_decomposition(endoindex, M_.exo_nbr+1, :);
        initcond = reshape(initcond,[],1);

        % stack = [initcond];
        
        % 1. supply shocks
        contrib_supply = zeros(size(initcond));
        for jj = 1:size(supply_shocks,1)
            currshock = strcat('ee_',supply_shocks{jj});
            exoindex  = find(strcmp(M_.exo_names, currshock));

            contrib_shock = oo_.shock_decomposition(endoindex, exoindex, :);
            contrib_shock = reshape(contrib_shock,[],1);

            contrib_supply = contrib_supply + contrib_shock;
        end

        % 2. demand shocks
        contrib_demand = zeros(size(initcond));
        for jj = 1:size(demand_shocks,1)
            currshock = strcat('ee_',demand_shocks{jj});
            exoindex  = find(strcmp(M_.exo_names, currshock));

            contrib_shock = oo_.shock_decomposition(endoindex, exoindex, :);
            contrib_shock = reshape(contrib_shock,[],1);

            contrib_demand = contrib_demand + contrib_shock;
        end

        % 3. other shocks
        contrib_other = zeros(size(initcond));
        for jj = 1:size(other_shocks,1)
            currshock = strcat('ee_',other_shocks{jj});
            exoindex  = find(strcmp(M_.exo_names, currshock));

            contrib_shock = oo_.shock_decomposition(endoindex, exoindex, :);
            contrib_shock = reshape(contrib_shock,[],1);

            contrib_other = contrib_other + contrib_shock;
        end

        h = figure;
        plot(dates(start:end), smoothvar(start:end), 'k', 'LineWidth', 2), hold on
        plot(dates(start:end), contrib_supply(start:end), '--', 'color', [0.4660 0.6740 0.1880], 'LineWidth', 2)
        plot(dates(start:end), contrib_demand(start:end), 'r-.', 'LineWidth', 2)
        plot(dates(start:end), zeros(size(dates(start:end))), 'k--', 'LineWidth', 0.5)
        set(gca, 'Xtick', dates(start:end))
        datetick('x','QQ-YY', 'keepticks', 'keeplimits')
        xtickangle(45)
        xlim([dates(start) dates(end)]) 
        legend('Data', 'Supply', 'Demand', 'Location', 'southeast')
        title(strcat(var_labels{ii}, ', reduced-form classification'))
        colororder("gem12")
        fig_name = strcat('figures/shock_decomp_',num2str(start),'_',currvar,'_alberto_alt.png');
        print(h,fig_name,'-dpng','-r400');
    end

end