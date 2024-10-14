% Main file for DSGE model
% Estimate pGamma as well
addpath C:\dynare\6.2\matlab
addpath functions
clear
clc
close all
rng(0);

options_mfc = struct;

options_mfc.clean       = false;       % erase all files. Do this only if starting from scratch
options_mfc.data        = false;        % rebuild data file
options_mfc.estimate    = true;       % estimate the model
options_mfc.irf         = false;       % compute IRFs
options_mfc.plot_shocks = true;       % plot smoothed observables and shocks
options_mfc.historical_decomp = true; % plot historical decompositions
options_mfc.export_stata      = true; % export r-star to Stata
options_mfc.forecasts         = true; % conduct simple forecasts using model
options_mfc.nowcasts          = true; % use nowcasts for Core PCE and GDP in place of latest observations

date_first = datetime(1959,03,31);
date_last  = datetime(2024,06,30);

dates = (date_first:calmonths(3):date_last)';

if options_mfc.nowcasts
    dates = [dates; date_last+calmonths(3)]; % add an extra quarter if using nowcasts
end

dates   = dateshift(dates,'end','month');
T_estim = 244; % 2019q4, last date of estimation
T_covid = 245; % 2020q1, beginning of Covid shocks

covid_horizon = 6; % duration of Covid shocks

%% 0. Clean if needed
if options_mfc.clean
    clean_old_results();
end

%% 1. Prepare data for estimation
if options_mfc.data
    
    data = xlsread('../data/dsge_data.xls');
    
    T_data  = size(dates,1);

    credit_spreads = data(1:T_data,1) - nanmean(data(1:T_data,1));
    treasury10y    = data(1:T_data,2);
    log_hours      = data(1:T_data,3);
    G_Y            = data(1:T_data,4);
    GT_Y           = data(1:T_data,5);
    inflation_core = data(1:T_data,6);
    unemp          = data(1:T_data,7);
   
    y_growth = data(1:T_data,8);
    c_growth = data(1:T_data,9);
    i_growth = data(1:T_data,10);
    g_growth = data(1:T_data,11);
    w_growth = data(1:T_data,12);

    inflation_spf = data(1:T_data,13);
    BgY           = data(1:T_data,14);
    tfp_model     = data(1:T_data,15) - nanmean(data(1:T_estim,15));
    shadow_rate   = data(1:T_data,16);

    y_growth_nowcast  = data(:,17);
    c_growth_nowcast  = data(:,18);
    i_growth_nowcast  = data(:,19);
    inflation_nowcast = data(:,20);
    baa_spread        = data(:,21);
    
    % definitions that get changed
    inflation        = inflation_core; % measure of inflation: core PCE
    inflation_exp10y = inflation_spf;  % same as NY Fed 
    FFR              = shadow_rate;    % use shadow rate instead due to ZLB

    % create covid shocks, 2020q1-2021q3
    covid_chi    = zeros(T_data,1);
    covid_mu_w   = zeros(T_data,1);
    covid_mu_p   = zeros(T_data,1);
    covid_zeta   = zeros(T_data,1);
    covid_Gshock = zeros(T_data,1);
    covid_Tb     = zeros(T_data,1);
    covid_Gamma  = zeros(T_data,1);
    covid_mp     = zeros(T_data,1);
    
    covid_chi(T_covid:T_covid+covid_horizon,1)    = NaN;
    covid_mu_w(T_covid:T_covid+covid_horizon,1)   = NaN;
    covid_mu_p(T_covid:T_covid+covid_horizon,1)   = NaN;
    covid_zeta(T_covid:T_covid+covid_horizon,1)   = NaN;
    covid_Gshock(T_covid:T_covid+covid_horizon,1) = NaN;
    covid_Tb(T_covid:T_covid+covid_horizon,1)     = NaN;
    covid_Gamma(T_covid:T_covid+covid_horizon,1)  = NaN;
    covid_mp(T_covid:T_covid+covid_horizon,1)     = NaN;

    % incorporate nowcasts as last observations
    if options_mfc.nowcasts
        y_growth(end) = y_growth_nowcast(end);
        inflation(end) = inflation_nowcast(end);
    end

    var_obs = struct;
    var_obs.y_growth  = y_growth;
    var_obs.c_growth  = c_growth;
    var_obs.i_growth  = i_growth;
    var_obs.w_growth  = w_growth;
    var_obs.g_growth  = g_growth;
    var_obs.GT_Y      = GT_Y;
    var_obs.log_hours = log_hours;
    var_obs.FFR       = FFR;
    var_obs.inflation = inflation;
    var_obs.inflation_exp10y = inflation_exp10y;
    var_obs.tfp_model   = tfp_model;
    var_obs.treasury10y = treasury10y;
    var_obs.baa_spread  = baa_spread;
    var_obs.unemp       = unemp;
    
    save('data_estimation.mat', 'FFR', 'y_growth', 'c_growth', 'i_growth',...
        'g_growth', 'w_growth', 'GT_Y', 'inflation', 'unemp', 'log_hours',...
        'inflation_exp10y', 'tfp_model', 'treasury10y', 'baa_spread',...
        'covid_chi', 'covid_mu_w', 'covid_mu_p', 'covid_zeta', 'covid_Gshock',...
        'covid_Tb', 'covid_Gamma', 'covid_mp');
end

%% 2. Estimate or load previous estimates
if options_mfc.estimate
    p  = struct; % This structure stores model parameters

    p.Gamma       = (1+nanmean(y_growth(1:T_estim))/100)^(1/4); % average gross growth rate of GDP
    p.Pi          = (1+0.02)^(1/4); % inflation target/trend inflation
    p.betas       = 0.9996;
    p.lambda      = 0.70;   % Cantore and Freund
    p.varphi      = 2.00;   % Frisch elasticity
    p.risk        = (p.Gamma*p.Pi/p.betas/(1.026)^(1/4)); % steady state liq premium, target long-term 2.6% FFR
    p.psi_w       = 0.16; % Cantore and Freund
    
    p.mu_p     = 1.20;   % price markup of 20%
    p.mu_w     = 1.20;   % wage markup of 20%
    calvo      = 0.75;   % Calvo parameter
    p.eta_p    = (p.mu_p/(p.mu_p-1)-1)*calvo/((1-calvo)*(1-p.betas*calvo));  % Equivalent Rotemberg parameter
    p.eta_w    = (p.mu_w/(p.mu_w-1)-1)*calvo/((1-calvo)*(1-p.betas*calvo));  % Equivalent Rotemberg parameter
    p.alpha    = 0.33;   % capital share
    p.delta    = 0.025;  % depreciation rate
    p.psi_i    = 4.00;   % adjustment costs of investment
    p.sig_util = 0.50;   % elasticity of capital utilization costs

    p.gamma_e  = 0.99; % same as NY Fed
    p.omega_e  = 0.01; % to estimate
    p.lambda_d = 0.3;  % to estimate
    
    p.rho_pi  = 0.50;  % degree of price indexation
    p.rho_w   = 0.50;  % degree of wage indexation
    p.ma_mu_p = 0.50;  % ARMA term
    p.ma_mu_w = 0.50;  % ARMA term
    
    p.phi_pi  = 1.50;  % standard 
    p.phi_y   = 0.12;  % standard
    p.phi_d   = 0.12;  % SW/FRBNY
    p.rho_r   = 0.75; 
    p.phi_tau = 0.02; % to estimate
    p.tau_d   = 0.20; % average profit income tax
    
    % other targets
    p.GY       = nanmean(G_Y(1:T_estim));  % govt consumption to GDP
    p.GTY      = nanmean(GT_Y(1:T_estim)); % govt spending to GDP
    p.BfY      = 0*4*0.70;   % corporate debt to GDP, kappa is not identified
    p.BgY      = 4*nanmean(BgY(1:T_estim))/100; % government debt to GDP
    p.logN     = nanmean(log_hours(1:T_estim));
    p.BwY      = p.BgY * 0.75; 
    p.tp       = (nanmean(treasury10y(1:T_estim)) - nanmean(FFR(1:T_estim)))/100;
    p.spread   = nanmean(baa_spread(1:T_estim));
    p.default  = 0.03; % quarterly default rate, check DRALACBN
    p.risk_bgg = 0.50; % CMR use 0.26

    % Shock parameters
    p.rho_Z      = 0.50;
    p.rho_G      = 0.50;
    p.rho_mu_w   = 0.50;
    p.rho_chi    = 0.50;
    p.rho_mu_p   = 0.50;
    p.rho_Tb     = 0.50;
    p.rho_psi    = 0.50;
    p.rho_zeta   = 0.50;
    p.rho_nx     = 0.50;
    p.rho_mp     = 0.00;
    p.rho_risk   = 0.99;
    p.rho_Pi_tgt = 0.99;
    p.rho_risk_bgg = 0.50;
    p.rho_me_tp     = 0.50;
    
    p.sig_Z      = 0.01;
    p.sig_G      = 0.01;
    p.sig_mp     = 0.01;
    p.sig_mu_w   = 0.01;
    p.sig_chi    = 0.01;
    p.sig_mu_p   = 0.01;
    p.sig_Tb     = 0.01;
    p.sig_psi    = 0.01;
    p.sig_zeta   = 0.01;
    p.sig_nx     = 0.01;
    p.sig_risk   = 0.01;
    p.sig_Pi_tgt = 0.01;
    p.sig_risk_bgg = 0.01;
    p.sig_tp      = 0.01;

    p.sig_me_tfp     = 0.01;
    p.sig_me_inflexp = 0.01;
    p.sig_me_baa     = 0.01;
    p.sig_me_tp      = 0.01;
    
    save p.mat p
    
    % Estimate the model
    dynare dsge_estimate.mod noclearall parallel;
    
    % Safe copy of estimation results
    copyfile 'dsge_estimate/Output/dsge_estimate_results.mat' 'estimation_results/dsge_estimate_results.mat'

    % For observables with missing values, paint using filtered data
    var_smooth = var_obs;
    var_names  = fieldnames(var_obs);
    for ii = 1:length(var_names)
        currvar = var_names{ii};
        for tt = 1:T_estim
            if isnan(var_smooth.(currvar)(tt))
                var_smooth.(currvar)(tt) = oo_.SmoothedVariables.(currvar)(tt);
            end
        end
    end

    % Create file with smoothed data
    FFR       = var_smooth.FFR ;
    y_growth  = var_smooth.y_growth ;
    c_growth  = var_smooth.c_growth ;
    i_growth  = var_smooth.i_growth ;
    g_growth  = var_smooth.g_growth ;
    w_growth  = var_smooth.w_growth ;
    GT_Y      = var_smooth.GT_Y ;
    inflation = var_smooth.inflation ;
    unemp     = var_smooth.unemp ;
    log_hours = var_smooth.log_hours ;
    inflation_exp10y = var_smooth.inflation_exp10y ;
    tfp_model        = var_smooth.tfp_model ;
    treasury10y      = var_smooth.treasury10y ;
    baa_spread       = var_smooth.baa_spread ;

    save('data_smoothed.mat', 'FFR', 'y_growth', 'c_growth', 'i_growth',...
        'g_growth', 'w_growth', 'GT_Y', 'inflation', 'unemp', 'log_hours',...
        'inflation_exp10y', 'tfp_model', 'treasury10y', 'baa_spread',...
        'covid_chi', 'covid_mu_w', 'covid_mu_p', 'covid_zeta', 'covid_Gshock',...
        'covid_Tb', 'covid_Gamma', 'covid_mp');

    % Solve model over full sample
    dynare dsge_smooth.mod noclearall;
else
    % Load previous estimation results
    estoutput = load('estimation_results/dsge_estimate_results.mat');
    M_              = estoutput.M_;
    oo_             = estoutput.oo_;
    options_        = estoutput.options_;
    estim_params_   = estoutput.estim_params_;
    bayestopt_      = estoutput.bayestopt_;
    dataset_        = estoutput.dataset_;
    estimation_info = estoutput.estimation_info;
    dataset_info    = estoutput.dataset_info;
    oo_recursive_   = estoutput.oo_recursive_;

    % Solve model over full sample
    dynare dsge_smooth.mod noclearall;
end

%% 3. Plot IRFs
if options_mfc.irf 
    plot_irfs(M_,oo_);
    % plot_irfs4(M_,oo_);
end

%% 4. Plot observables and smoothed shocks
if options_mfc.plot_shocks
    plot_smoothed_observables(oo_,dates);
    plot_smoothed_shocks(oo_,dates);
    plot_covid_shocks(oo_,dates,T_covid,covid_horizon);
    plot_inflation_target(oo_,dates);
end

%% 5. Historical decompositions
if options_mfc.historical_decomp
    % Full sample
    vars       = {'y_growth'; 'FFR'; 'inflation_yoy'; 'log_hours'; 'r_star_f10y'; 'output_gap'};
    var_labels = {'Output Growth'; 'Policy Rate'; 'Core PCE Inflation YoY'; 'log Hours'; 'R-star F10Y'; 'Output gap'};
    plot_historical_decomp(M_,oo_,dates,vars,var_labels,1);
    
    % Shorter sample
    vars       = {'inflation_yoy'; 'inflation'; 'output_gap'; 'r_star'};
    var_labels = {'Core PCE Inflation YoY'; 'Core PCE Inflation QoQ'; 'Output Gap'; 'R star'};
    plot_historical_decomp(M_,oo_,dates,vars,var_labels,244);
    plot_historical_decomp_simple(M_,oo_,dates,vars,var_labels,244);
    plot_historical_decomp_alberto(M_,oo_,dates,vars,var_labels,244);
    plot_historical_decomp_alberto_alt(M_,oo_,dates,vars,var_labels,244);
end

%% 6. Extract some variables to plot in Stata
if options_mfc.export_stata
    vars_extract = {'real_rate'; 'real_rate_f1y'; 'real_rate_f5y'; 'real_rate_f10y'; 'r_star'; 'r_star_f1y'; 'r_star_f5y'; 'r_star_f10y'; 'real_rate_10y'};
    save_variables_stata(M_,oo_,dates,vars_extract);
end

%% 7. Forecasts and projections
if options_mfc.forecasts
    % Employment gap and unemployment estimates
    [unemp_b0, unemp_b1] = employment_gap(oo_,dates,unemp);
    p.unemp_b0 = unemp_b0;
    p.unemp_b1 = unemp_b1;

    % First set of forecasts
    dates_forecast = (dateshift(dates(end)+90,'end','month'):calmonths(3):datetime(2027,12,31))';
    dates_forecast = dateshift(dates_forecast,'end','month');
    date_start     = datetime(2018,03,31);
    vars_plot      = {'y_growth'; 'inflation_yoy'; 'FFR'; 'output_gap'};
    titles_plot    = {'Output growth'; 'Core PCE inflation YoY'; 'Federal funds rate'; 'Output gap'};

    forecast_estimates(M_,options_,oo_,unemp,date_start,dates_forecast,vars_plot,titles_plot,p,'main');
    forecast_estimates_shock_uncertainty(M_,options_,oo_,unemp,date_start,dates_forecast,10000,vars_plot,titles_plot,p,'main');
    
    conditional_forecast_exercise(M_,options_,oo_,cf_nocut,cf_25bpscut,cf_50bpscut,date_start,dates_forecast,vars_plot,titles_plot);

    % Second set of forecasts
    vars_plot      = {'tfp_model'; 'w_growth'; 'labor_prod';  'unemp'};
    titles_plot    = {'TFP growth'; 'Wage growth'; 'Labor productivity'; 'Unemployment'};
    forecast_estimates(M_,options_,oo_,unemp,date_start,dates_forecast,vars_plot,titles_plot,p,'productivity');
    forecast_estimates_shock_uncertainty(M_,options_,oo_,unemp,date_start,dates_forecast,10000,vars_plot,titles_plot,p,'productivity');

    % SEP forecasts
    dates_sep = (datetime(2023,12,31):calmonths(3):datetime(2030,12,31))';
    dates_sep = dateshift(dates_sep,'end','month');
    dates_forecast = (dateshift(dates(end)+90,'end','month'):calmonths(3):datetime(2030,12,31))';
    dates_forecast = dateshift(dates_forecast,'end','month');
    sep_forecasts(M_,options_,oo_,unemp,dates_forecast,dates_sep,p)
end