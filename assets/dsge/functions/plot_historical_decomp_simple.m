function plot_historical_decomp_simple(M_,oo_,dates,vars,var_labels,start)
    % Simplified figure
    supply_shocks    = {'Z'; 'mu_w'; 'mu_p'; 'zeta'; 'covid_mu_w'; 'covid_mu_p'; 'covid_zeta'; 'covid_Gamma'};
    demand_shocks    = {'chi'; 'nx'; 'risk'; 'risk_bgg'; 'covid_chi'};
    fiscal_shocks    = {'G'; 'Tb'; 'covid_Gshock'; 'covid_Tb'};
    monetary_shocks  = {'mp'; 'Pi_tgt'; 'covid_mp'};

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

        % 3. fiscal shocks
        contrib_fiscal = zeros(size(initcond));
        for jj = 1:size(fiscal_shocks,1)
            currshock = strcat('ee_',fiscal_shocks{jj});
            exoindex  = find(strcmp(M_.exo_names, currshock));

            contrib_shock = oo_.shock_decomposition(endoindex, exoindex, :);
            contrib_shock = reshape(contrib_shock,[],1);

            contrib_fiscal = contrib_fiscal + contrib_shock;
        end

        % 4. monetary shocks
        contrib_monetary = zeros(size(initcond));
        for jj = 1:size(monetary_shocks,1)
            currshock = strcat('ee_',monetary_shocks{jj});
            exoindex  = find(strcmp(M_.exo_names, currshock));

            contrib_shock = oo_.shock_decomposition(endoindex, exoindex, :);
            contrib_shock = reshape(contrib_shock,[],1);

            contrib_monetary = contrib_monetary + contrib_shock;
        end

        % % 5. financial shocks
        % contrib_financial = zeros(size(initcond));
        % for jj = 1:size(financial_shocks,1)
        %     currshock = strcat('ee_',financial_shocks{jj});
        %     exoindex  = find(strcmp(M_.exo_names, currshock));
        % 
        %     contrib_shock = oo_.shock_decomposition(endoindex, exoindex, :);
        %     contrib_shock = reshape(contrib_shock,[],1);
        % 
        %     contrib_financial = contrib_financial + contrib_shock;
        % end
        % 
        % % 6. covid shocks
        % contrib_covid = zeros(size(initcond));
        % for jj = 1:size(covid_shocks,1)
        %     currshock = strcat('ee_',covid_shocks{jj});
        %     exoindex  = find(strcmp(M_.exo_names, currshock));
        % 
        %     contrib_shock = oo_.shock_decomposition(endoindex, exoindex, :);
        %     contrib_shock = reshape(contrib_shock,[],1);
        % 
        %     contrib_covid = contrib_covid + contrib_shock;
        % end
        % 
        % % 7. covid policy shocks
        % contrib_covid_policy = zeros(size(initcond));
        % for jj = 1:size(covid_policy_shocks,1)
        %     currshock = strcat('ee_',covid_policy_shocks{jj});
        %     exoindex  = find(strcmp(M_.exo_names, currshock));
        % 
        %     contrib_shock = oo_.shock_decomposition(endoindex, exoindex, :);
        %     contrib_shock = reshape(contrib_shock,[],1);
        % 
        %     contrib_covid_policy = contrib_covid_policy + contrib_shock;
        % end
        % contrib_other = contrib_other + initcond;

        % stack = [contrib_supply, contrib_demand, contrib_fiscal, contrib_monetary, contrib_financial, contrib_covid, initcond];
        stack = [contrib_supply, contrib_demand, contrib_monetary, contrib_fiscal, initcond];

        h = figure;
        bar(dates(start:end), stack(start:end,:), 'stacked'), hold on
        plot(dates(start:end), smoothvar(start:end), 'k', 'LineWidth', 1)
        set(gca, 'Xtick', dates(start:end))
        datetick('x','QQ-YY', 'keepticks', 'keeplimits')
        xtickangle(45)
        xlim([dates(start) dates(end)]) 
        % legend('Supply', 'Demand', 'Fiscal', 'Monetary', 'Financial', 'Covid', 'Other', 'Data', 'Location', 'eastoutside')
        legend('Supply', 'Demand', 'Monetary', 'Fiscal', 'Other', 'Data', 'Location', 'eastoutside')
        title(var_labels{ii})
        colororder("gem12")

        fig_name = strcat('figures/shock_decomp_simple_',num2str(start),'_',currvar,'.png');
        print(h,fig_name,'-dpng','-r400');
    end

end