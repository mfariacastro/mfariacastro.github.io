function plot_historical_decomp(M_,oo_,dates,vars,var_labels,start)
    
    % Plot historical shock decompositions for select variables and export
    % table with contributions for the last period

    shocks     = {'Z'; 'mu_p'; 'mu_w'; 'zeta'; 'chi'; 'nx'; 'risk'; 'risk_bgg'; 'G'; 'Tb';  'mp'; 'Pi_tgt'};

    group_titles = {'\emph{Supply}'; ''; ''; ''; '\emph{Demand}'; ''; ''; ''; '\emph{Fiscal}'; ''; '\emph{Monetary}'; ''};
    shock_titles = {'TFP'; 'Price markup'; 'Wage markup'; 'Mg. Eff. Inv.'; 'Mg. Util.'; 'Net exports'; 'Risk'; 'Risk BGG'; 'Govt. cons.'; 'Transfers'; 'Taylor rule'; 'Infl. target'};
    tabexport = table(group_titles,shock_titles);
    
    for ii = 1:size(vars,1)
        currvar = vars{ii};
        endoindex  = find(strcmp(M_.endo_names, currvar));

        % smoothed variable
        smoothvar = oo_.shock_decomposition(endoindex, M_.exo_nbr+2, :);
        smoothvar = reshape(smoothvar,[],1);

        % initial conditions
        initcond = oo_.shock_decomposition(endoindex, M_.exo_nbr+1, :);
        initcond = reshape(initcond,[],1);

        stack = [initcond];
        for jj = 1:size(shocks,1)
            currshock = strcat('ee_',shocks{jj});
            exoindex  = find(strcmp(M_.exo_names, currshock));

            contrib_shock = oo_.shock_decomposition(endoindex, exoindex, :);
            contrib_shock = reshape(contrib_shock,[],1);

            if strcmp(shocks{jj},'Z') 
                currshock = 'ee_covid_Gamma';
                exoindex  = find(strcmp(M_.exo_names, currshock));
    
                contrib_shock2 = oo_.shock_decomposition(endoindex, exoindex, :);
                contrib_shock2 = reshape(contrib_shock2,[],1);

                contrib_shock = contrib_shock + contrib_shock2;
            elseif strcmp(shocks{jj},'G') 
                currshock = 'ee_covid_Gshock';
                exoindex  = find(strcmp(M_.exo_names, currshock));
    
                contrib_shock2 = oo_.shock_decomposition(endoindex, exoindex, :);
                contrib_shock2 = reshape(contrib_shock2,[],1);

                contrib_shock = contrib_shock + contrib_shock2;
            elseif strcmp(shocks{jj},'mp') || strcmp(shocks{jj},'mu_w') || strcmp(shocks{jj},'chi') || strcmp(shocks{jj},'mu_p') || strcmp(shocks{jj},'Tb') || strcmp(shocks{jj},'zeta')
                currshock = strcat('ee_covid_',shocks{jj});
                exoindex  = find(strcmp(M_.exo_names, currshock));
    
                contrib_shock2 = oo_.shock_decomposition(endoindex, exoindex, :);
                contrib_shock2 = reshape(contrib_shock2,[],1);

                contrib_shock = contrib_shock + contrib_shock2;
            end

            stack = [stack, contrib_shock];
            
        end

        h = figure;
        bar(dates(start:end), stack(start:end,:), 'stacked'), hold on
        plot(dates(start:end), smoothvar(start:end,:), 'k', 'LineWidth', 1)
        if start > 1
            set(gca, 'Xtick', dates(start:end))
        end
        datetick('x','QQ-YY', 'keepticks', 'keeplimits')
        xtickangle(45)
        xlim([dates(start) dates(end)]) 
        legend('Init cond', 'TFP', 'P markup', 'W markup', 'MEI', 'Mg. Util.',...
            'NX', 'Risk', 'Risk BGG', 'Govt. Cons.', 'Transfers', 'Mon. pol.',...
            'Infl. target', 'Data', 'Location', 'eastoutside')
        title(var_labels{ii})
        colororder("gem12")
        
        fig_name = strcat('figures/shock_decomp_',num2str(start),'_',currvar,'.png');
        print(h,fig_name,'-dpng','-r400');

        tabexport.(currvar) = stack(end,2:end)';
        % tabexport.(strcat(currvar,'_2024')) = mean(stack(end-2:end,2:end))';
    end

    filename = 'historical_decomp.xlsx';
    writetable(tabexport,filename)

end