function sep_forecasts(M_,options_,oo_,unemp,dates_forecast,dates_sep,p)
    
    % Simulate the model forward to generate SEP forecasts
    T_forecast = size(dates_forecast,1); % how many periods to forecast

    % Number of quarters since 2023Q4
    dates23q4 = calquarters(between(dates_sep(1),dateshift(dates_forecast(1)-100,'end','month')));

    ForecastVariables = struct;
    y0 = zeros(M_.endo_nbr,1);
    
    for jj=1:size(M_.endo_names,1)
        currvar = M_.endo_names{jj};
        y0(jj,1) = oo_.SmoothedVariables.(currvar)(end,1);
    end
    
    shocks = zeros(T_forecast, M_.exo_nbr); % set all shocks to zero
    
    y_ = simult_(M_,options_,y0,oo_.dr,shocks,1);
    
    for jj=1:size(M_.endo_names,1)
        currvar = M_.endo_names{jj};
        ForecastVariables.(currvar) = y_(jj,:);
    end
    
    % Unemployment is equal to the data until last point in the sample
    oo_.SmoothedVariables.unemp(1:end-1) = unemp(1:end-1);
    if ~isnan(unemp(end))
        oo_.SmoothedVariables.unemp(end) = unemp(end);
    end
    
    % Unemployment forecasts given by estimated function
    empgap_forecast = [oo_.SmoothedVariables.employment_gap(end); ForecastVariables.employment_gap(2:end)'];
    unemp_forecast = p.unemp_b0 + p.unemp_b1*empgap_forecast;
    ForecastVariables.unemp = unemp_forecast';

    sep_growth = {'y_growth'; 'inflation'};                 % growth rate variables
    sep_endofp  = {'FFR'; 'unemp'; 'output_gap'; 'r_star'}; % end of period variables

    f = struct;

    for ii = 1:size(sep_growth,1)
        curr_var   = sep_growth{ii};
        curr_index = find(strcmp(M_.endo_names, curr_var));
        series   = [oo_.SmoothedVariables.(curr_var)(end-dates23q4:end); ForecastVariables.(curr_var)(2:end)']; % note that smoothed variables start in 2023q4 so we can compute q4-q4 variables
        
        f.(curr_var) = zeros(8,1);
        f.(curr_var)(1) = 100*(((1+series(4)/100)^(1/4) * (1+series(5)/100)^(1/4))^2 - 1);
        f.(curr_var)(2) = 100*(((1+series(2)/100)^(1/4) * (1+series(3)/100)^(1/4) * (1+series(4)/100)^(1/4) * (1+series(5)/100)^(1/4)) - 1);
        f.(curr_var)(3) = 100*(((1+series(6)/100)^(1/4) * (1+series(7)/100)^(1/4) * (1+series(8)/100)^(1/4) * (1+series(9)/100)^(1/4)) - 1);
        f.(curr_var)(4) = 100*(((1+series(10)/100)^(1/4) * (1+series(11)/100)^(1/4) * (1+series(12)/100)^(1/4) * (1+series(13)/100)^(1/4)) - 1);
        f.(curr_var)(5) = 100*(((1+series(14)/100)^(1/4) * (1+series(15)/100)^(1/4) * (1+series(16)/100)^(1/4) * (1+series(17)/100)^(1/4)) - 1);
        f.(curr_var)(6) = 100*(((1+series(18)/100)^(1/4) * (1+series(19)/100)^(1/4) * (1+series(20)/100)^(1/4) * (1+series(21)/100)^(1/4)) - 1);
        f.(curr_var)(7) = 100*(((1+series(22)/100)^(1/4) * (1+series(23)/100)^(1/4) * (1+series(24)/100)^(1/4) * (1+series(25)/100)^(1/4)) - 1);
        f.(curr_var)(8) = 100*(((1+series(26)/100)^(1/4) * (1+series(27)/100)^(1/4) * (1+series(28)/100)^(1/4) * (1+series(29)/100)^(1/4)) - 1);
        f.(curr_var)(9) = oo_.steady_state(curr_index);
    end

    for ii = 1:size(sep_endofp,1)
        curr_var   = sep_endofp{ii};
        curr_index = find(strcmp(M_.endo_names, curr_var));
        series     = [oo_.SmoothedVariables.(curr_var)(end-dates23q4:end); ForecastVariables.(curr_var)(2:end)']; % note that smoothed variables start in 2023q4 so we can compute q4-q4 variables

        f.(curr_var) = zeros(8,1);
        f.(curr_var)(1) = NaN;
        f.(curr_var)(2) = series(5);
        f.(curr_var)(3) = series(9);
        f.(curr_var)(4) = series(13);
        f.(curr_var)(5) = series(17);
        f.(curr_var)(6) = series(21);
        f.(curr_var)(7) = series(25);
        f.(curr_var)(8) = series(29);
        f.(curr_var)(9) = oo_.steady_state(curr_index);
    end

    horizon = {'2024H2'; '2024'; '2025'; '2026'; '2027'; '2028'; '2029'; '2030'; 'Long run'};

    GDP_growth         = f.y_growth;
    Core_PCE_inflation = f.inflation;
    FFR                = f.FFR;
    unemployment       = f.unemp;
    r_star             = f.r_star;
    Output_gap         = f.output_gap;

    T = table(horizon,GDP_growth,unemployment,Core_PCE_inflation,FFR,r_star,Output_gap);
    T1 = rows2vars(T);

    filename = 'sep_forecasts.xlsx';
    writetable(T1,filename)
end