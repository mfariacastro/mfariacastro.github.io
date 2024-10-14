function plot_irfs4(M_,oo_)
    % Plot IRFs to different shocks after 4 periods
    shocks       = {'Z'; 'zeta'; 'mu_p'; 'mu_w'; 'chi'; 'risk'; 'nx'; 'G'; 'Tb'; 'mp'; 'Pi_tgt'; 'covid_chi'; 'covid_mu_w'; ...
        'covid_mu_p'; 'covid_zeta'; 'covid_Gshock'; 'covid_Tb'; 'covid_Gamma'; 'covid_mp'};
    shock_labels = {'Productivity'; 'Marginal efficiency of investment'; 'Price markup'; 'Wage markup'; 'Marginal utility'; ...
        'Risk premium'; 'Net exports'; 'Government consumption'; 'Transfers'; 'Monetary policy'; 'Inflation target'; ...
        'Covid mg. util.'; 'Covid wage markup'; 'Covid product markup'; 'Covid mg. eff. inv.'; 'Covid govt. spending'; ...
        'Covid transfers'; 'Covid TFP'; 'Covid monetary policy'};
    % shocks     = {'G'; 'Tb'; 'mp'};
    vars       = {'y_growth'; 'inflation'; 'c_growth'; 'FFR'};
    var_labels = {'GDP growth'; 'Inflation'; 'Consumption growth'; 'FFR'};

    Tirf = 20;

    for jj = 1:size(shocks,1)
        curr_shock = shocks{jj};
        h=figure;
        for ii = 1:size(vars,1)
            curr_var  = vars{ii};
            endoindex = find(strcmp(M_.endo_names, curr_var));
            subplot(2,2,ii)
            var_shock = strcat(curr_var,'_ee_',curr_shock);
            % if strcmp(curr_var,'Pi') || strcmp(curr_var,'R')
            %     irf_temp    = 400*(exp(oo_.steady_state(endoindex))*exp(oo_.irfs.(var_shock))-1);
            %     ylabel_temp = 'Ann. Rate';
            %     ss_temp     = 400*(exp(oo_.steady_state(endoindex))-1) * ones(Tirf,1);
            % elseif strcmp(curr_var,'u')
            %     irf_temp    = 100*(exp(oo_.steady_state(endoindex))*exp(oo_.irfs.(var_shock)));
            %     ylabel_temp = 'Rate';
            %     ss_temp     = 100*(exp(oo_.steady_state(endoindex))) * ones(Tirf,1);
            % else
            %     irf_temp    = oo_.steady_state(endoindex) + oo_.irfs.(var_shock);
                ylabel_temp = 'pp';
            %     ss_temp     = oo_.steady_state(endoindex)*ones(Tirf,1);
            % end

            irf_temp = oo_.irfs.(var_shock);

            irf_temp = cumsum(irf_temp);
            plot((4:Tirf), irf_temp(4:Tirf), 'LineWidth', 2), hold on
            % plot((4:Tirf), ss_temp(4:Tirf), 'k--')
            axis tight
            grid minor
            title(var_labels{ii})
            ylabel(ylabel_temp)
        end
        fig_title = strcat(shock_labels{jj},' shock');
        suptitle(fig_title)
        % % set(h, 'Position', [100,100,400,400]) 
        % fig_name = strcat('figures/irf_',curr_shock,'.png');
        % print(h,fig_name,'-dpng','-r400');
    end
end