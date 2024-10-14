function forecast_estimates_model_uncertainty(M_,options_,oo_,date_start,dates_forecast,N_draws,vars_plot,titles_plot)
    % Simulate the model forward and plot the path of endogenous variables
    % as well as shock decompositions

    N_shock_draws = N_draws;
    N_par_draws   = N_draws;
    
    T_forecast   = size(dates_forecast,1); % how many periods to forecast
    N_shocks     = M_.exo_nbr;
    param_names  = fieldnames(oo_.posterior_density.parameters); 
    N_parameters = length(param_names);
    
    ForecastVariables = struct;
    y0 = zeros(M_.endo_nbr,1);
    
    for jj=1:size(M_.endo_names,1)
        currvar = M_.endo_names{jj};
        y0(jj,1) = oo_.SmoothedVariables.(currvar)(end,1);
    end
    
    % draw realizations for shocks and parameters
    shock_draws = randn(T_forecast, N_shocks, N_shock_draws);
    par_draws   = rand(N_parameters, N_par_draws);

    % create cdfs for posterior densities
    posterior_cdf = struct;
    for kk = 1:N_parameters
        curr_pdf = oo_.posterior_density.parameters.(param_names{kk});
        distr_support = curr_pdf(:,1);
        curr_pdf      = curr_pdf(:,2)/sum(curr_pdf(:,2));
        curr_cdf      = cumsum(curr_pdf);
        posterior_cdf.(param_names{kk}).support = distr_support;
        posterior_cdf.(param_names{kk}).cdf     = curr_cdf;
    end
        
    y_ = zeros(M_.endo_nbr, T_forecast+1, N_par_draws, N_shock_draws);
    
    for ii = 1:N_par_draws
        fprintf('Parameter draw %6.0f\n' , ii)
        fail = 0;
        % draw parameters from the respective marginal densities
        current_par_draw = par_draws(:,ii);

        % resolve the model for these parameter values
        M_temp  = M_;
        oo_temp = oo_;

        for kk = 1:N_parameters
            % draw parameter from posterior density
            par_support = posterior_cdf.(param_names{kk}).support; 
            par_cdf     = posterior_cdf.(param_names{kk}).cdf; 
            currind     = find(par_cdf >= current_par_draw(kk));

            if isnan(sum(par_cdf)) % sometimes posterior is degenerate, keep parameter at its value
                par_value = oo_.posterior_mean.parameters.(param_names{kk});
            elseif isempty(currind) % at the upper bound of the posterior
                par_value = par_support(end);
            else
                par_value = par_support(currind(1));
            end

            % set parameter
            par_index = find(strcmp(M_.param_names,param_names{kk}));
            M_temp.params(par_index) = par_value;
        end

        try
            [oo_temp.dr, info_temp, params_temp]= resol(0, M_temp, options_, oo_.dr, oo_.steady_state, oo_.exo_steady_state, oo_.exo_steady_state);
        catch
            fail = 1;
        end

        % Solve for different shock realizations
        if fail == 0
            for jj = 1:N_shock_draws
                y_(:,:,ii,jj) = simult_(M_temp,options_,y0,oo_temp.dr,shock_draws(:,:,jj),1);
            end
        else
            y_(:,:,ii,:) = NaN;
        end
    end

    
    for jj=1:size(M_.endo_names,1)
        currvar = M_.endo_names{jj};
        ForecastVariables.(currvar) = y_(jj,:,:,:);
    end

    % Plots
    dates_plot = (date_start:calmonths(3):dates_forecast(end))';
    T_data     = size(dates_plot,1) - T_forecast;

    h=figure;
    for ii = 1:size(vars_plot,1)
        currvar = vars_plot{ii};
        subplot(2,2,ii)

        p25 = zeros(T_forecast,1);
        p50 = zeros(T_forecast,1);
        p75 = zeros(T_forecast,1);
        avg = zeros(T_forecast,1);
        se  = zeros(T_forecast,1);

        for tt = 1:T_forecast
            p25(tt,1) = quantile(ForecastVariables.(currvar)(1,tt+1,:,:),.25,'all');
            p50(tt,1) = quantile(ForecastVariables.(currvar)(1,tt+1,:,:),.50,'all');
            p75(tt,1) = quantile(ForecastVariables.(currvar)(1,tt+1,:,:),.75,'all');
            % avg(tt,1) = mean(ForecastVariables.(currvar)(1,tt+1,:,:));
            % se(tt,1)  = std(ForecastVariables.(currvar)(1,tt+1,:,:));
        end
        
        p25 = [oo_.SmoothedVariables.(currvar)(end-T_data+1:end); p25];
        p50 = [oo_.SmoothedVariables.(currvar)(end-T_data+1:end); p50];
        p75 = [oo_.SmoothedVariables.(currvar)(end-T_data+1:end); p75];
        avg = [oo_.SmoothedVariables.(currvar)(end-T_data+1:end); avg];
        se  = [zeros(T_data,1); se];

        currindex = find(strcmp(M_.endo_names, currvar));
        ss_temp   = oo_.steady_state(currindex)*ones(size(dates_plot,1),1);
       
        plot(dates_plot, p50, 'LineWidth', 2), hold on
        plot(dates_plot, ss_temp, 'k--')
        xline(dates_forecast(1)-calmonths(3), 'k--')
        plot(dates_plot, p25, 'LineWidth', 1)
        plot(dates_plot, p75, 'LineWidth', 1)
        x2 = [dates_plot; flipud(dates_plot)];
        inBetween = [p25, p75];
        fill(x2, [p25; flipud(p75)], 'b', 'FaceAlpha',0.10);
        
        axis tight
        grid minor
        if strcmp(currvar, 'y_growth') || strcmp(currvar, 'r_star')
            ylim([-10 10])
        end
        title(titles_plot{ii})
    end
    fig_name = 'figures/forecasts_parameter_uncertainty.png';
    print(h,fig_name,'-dpng','-r400');

    % set(h, 'Position', [100,100,800,400])
    % fig_name = strcat('figures/irf_',curr_shock,'.png');
    % print(h,fig_name,'-dpng','-r400');
end