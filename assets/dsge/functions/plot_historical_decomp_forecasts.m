function plot_historical_decomp_forecasts(M_,oo_,dates,vars,var_labels)
    % Plot historical shock decompositions for select variables

    shocks     = {'Z'; 'G'; 'mp'; 'mu_w'; 'chi'; 'mu_p';  'Tb'; 'zeta'; 'nx'; 'Pi_tgt'; 'risk'};
    
    for ii = 1:size(vars,1)
        currvar = vars{ii};
        endoindex  = find(strcmp(M_.endo_names, currvar));

        % smoothed variable
        smoothvar = oo_.shock_decomposition(endoindex, M_.exo_nbr+2, :);
        smoothvar = reshape(smoothvar,[],1);

        % initial conditions
        initcond = oo_.shock_decomposition(endoindex, M_.exo_nbr+1, :);
        initcond = reshape(initcond,[],1);

        % stack = [initcond];
        stack = [];
        for jj = 1:size(shocks,1)
            currshock = strcat('ee_',shocks{jj});
            exoindex  = find(strcmp(M_.exo_names, currshock));

            contrib_shock = oo_.shock_decomposition(endoindex, exoindex, :);
            contrib_shock = reshape(contrib_shock,[],1);

            stack = [stack, contrib_shock];
            
        end

        h = figure;
        bar(dates(157:end), stack(157:end,:), 'stacked'), hold on
        plot(dates(157:end), smoothvar(157:end), 'k', 'LineWidth', 1)
        legend('TFP', 'Govt spending', 'Mon pol', 'Labor mkt', 'Mg. Util.', 'P Markup', 'Transfers', 'MEI', 'NX', 'Infl. Target', 'Risk', 'Data', 'Location', 'eastoutside')
        title(var_labels{ii})
        colororder("gem12")
        fig_name = strcat('figures/shock_decomp_',currvar,'_forecasts.png');
        print(h,fig_name,'-dpng','-r400');
    end


    % Simplified figure
    supply_shocks    = {'Z'; 'mu_w'; 'mu_p'; 'zeta'};
    demand_shocks    = {'chi'; 'nx'};
    fiscal_shocks    = {'G'; 'Tb'};
    monetary_shocks  = {'mp'; 'Pi_tgt'};
    financial_shocks = {'risk'};

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

        % 5. financial shocks
        contrib_financial = zeros(size(initcond));
        for jj = 1:size(financial_shocks,1)
            currshock = strcat('ee_',financial_shocks{jj});
            exoindex  = find(strcmp(M_.exo_names, currshock));

            contrib_shock = oo_.shock_decomposition(endoindex, exoindex, :);
            contrib_shock = reshape(contrib_shock,[],1);

            contrib_financial = contrib_financial + contrib_shock;
        end

        stack = [contrib_supply, contrib_demand, contrib_fiscal, contrib_monetary, contrib_financial];

        h = figure;
        bar(dates(157:end), stack(157:end,:), 'stacked'), hold on
        plot(dates(157:end), smoothvar(157:end), 'k', 'LineWidth', 1)
        legend('Supply', 'Demand', 'Fiscal', 'Monetary', 'Financial', 'Data', 'Location', 'eastoutside')
        title(var_labels{ii})
        colororder("gem12")
        fig_name = strcat('figures/shock_decomp_',currvar,'_forecasts_simplified.png');
        print(h,fig_name,'-dpng','-r400');
    end

end