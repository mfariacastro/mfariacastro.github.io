// This file estimates the model, run only once
// Endogenous variables
var Cs Cb Pi w N tau tau_d Y C G Inv rk mc Qk Pi_w Ku nu nx ret_k lev nw omg BGG_Gamma BGG_G;
// Auxiliary variables
var ms mb R D Pi_index Pi_w_index GT mrs;
// Endogenous state variables
var Bg K Bw;
// Exogenous state variables
var Gamma mp mu_w chi mu_p Tb Gshock zeta Pi_tgt risk risk_bgg me_tp; 
var chi_eff mu_w_eff mu_p_eff zeta_eff Gshock_eff Tb_eff Gamma_eff;
// Variables for the flex price model
var Cb_flex tau_flex tau_d_flex w_flex N_flex ms_flex mb_flex Cs_flex Qk_flex rk_flex nu_flex Inv_flex Ku_flex Y_flex K_flex mrs_flex G_flex Bg_flex D_flex C_flex r_flex;
var Bw_flex ret_k_flex lev_flex nw_flex omg_flex BGG_Gamma_flex BGG_G_flex;
// Shocks to the exogenous state variables
varexo ee_Z ee_G ee_mp ee_mu_w ee_chi ee_mu_p ee_Tb ee_zeta ee_nx ee_Pi_tgt ee_risk ee_risk_bgg;
varexo ee_me_tfp ee_me_baa ee_me_tp ee_me_inflexp;

// Observables
var y_growth c_growth g_growth w_growth i_growth FFR inflation log_hours GT_Y inflation_exp10y tfp_model BgY treasury10y baa_spread;
var covid_chi covid_mu_w covid_mu_p covid_zeta covid_Gshock covid_Tb covid_Gamma covid_mp;

// Deep parameters
parameters pbetas plambda ptau_d pdelta palpha pmu_p pmu_w pvarphi ptau;
// Dynamic parameters (elasticities)
parameters peta_w peta_p ppsi_i pphi_pi pphi_y pphi_d prho_r pphi_tau prho_pi prho_w psig_util pcons_util ppsi_w;
parameters pgamma_e pomega_e plambda_d;
// Steady state values used as parameters
parameters pGamma pPi plogN pGY pGTY pBgY pBg pR pGshock pmp pxi pchi pTb pzeta pBg_flex prisk pBw pBwY pspread prisk_bgg pdefault;
// Shock parameters: persistence and conditional volatility
parameters prho_Z prho_G prho_mp prho_mu_w prho_chi prho_mu_p prho_Tb prho_zeta prho_nx prho_Pi_tgt prho_risk prho_risk_bgg;
parameters psig_Z psig_G psig_mp psig_mu_w psig_chi psig_mu_p psig_Tb psig_zeta psig_nx psig_Pi_tgt psig_risk psig_risk_bgg;
parameters pma_mu_p pma_mu_w;
parameters prho_me_tp;
parameters psig_me_tfp psig_me_baa psig_me_tp psig_me_inflexp;

// Load parameter file and assign some parameter values externally
load p
set_param_value('pbetas',p.betas);
set_param_value('plambda',p.lambda);
set_param_value('pvarphi',p.varphi);
set_param_value('pmu_p',p.mu_p);
set_param_value('pmu_w',p.mu_w);
set_param_value('prisk',p.risk);
set_param_value('peta_p',p.eta_p);
set_param_value('peta_w',p.eta_w);
set_param_value('pdelta',p.delta);
set_param_value('palpha',p.alpha);
set_param_value('ppsi_i',p.psi_i);
set_param_value('pphi_pi',p.phi_pi);
set_param_value('pphi_y',p.phi_y);
set_param_value('pphi_d',p.phi_d);
set_param_value('prho_r',p.rho_r);
set_param_value('pphi_tau',p.phi_tau);
set_param_value('ptau_d',p.tau_d);
set_param_value('prho_pi',p.rho_pi);
set_param_value('prho_w',p.rho_w);
set_param_value('psig_util',p.sig_util);
set_param_value('ppsi_w',p.psi_w);
set_param_value('pgamma_e',p.gamma_e);
set_param_value('pomega_e',p.omega_e);
set_param_value('plambda_d',p.lambda_d);

set_param_value('pGamma',p.Gamma);
set_param_value('pPi',p.Pi);
set_param_value('plogN',p.logN);
set_param_value('pGY',p.GY);
set_param_value('pGTY',p.GTY);
set_param_value('pBgY',p.BgY);
set_param_value('pBwY',p.BwY);
set_param_value('pspread',p.spread);
set_param_value('prisk_bgg',p.risk_bgg);
set_param_value('pdefault',p.default);

set_param_value('prho_Z',p.rho_Z);
set_param_value('prho_G',p.rho_G);
set_param_value('prho_mp',p.rho_mp);
set_param_value('prho_mu_w',p.rho_mu_w);
set_param_value('prho_chi',p.rho_chi);
set_param_value('prho_mu_p',p.rho_mu_p);
set_param_value('prho_Tb',p.rho_Tb);
set_param_value('prho_zeta',p.rho_zeta);
set_param_value('prho_nx',p.rho_nx);
set_param_value('prho_Pi_tgt',p.rho_Pi_tgt);
set_param_value('prho_risk',p.rho_risk);
set_param_value('prho_risk_bgg',p.rho_risk_bgg);

set_param_value('psig_Z',p.sig_Z);
set_param_value('psig_G',p.sig_G);
set_param_value('psig_mp',p.sig_mp);
set_param_value('psig_mu_w',p.sig_mu_w);
set_param_value('psig_chi',p.sig_chi);
set_param_value('psig_mu_p',p.sig_mu_p);
set_param_value('psig_Tb',p.sig_Tb);
set_param_value('psig_zeta',p.sig_zeta);
set_param_value('psig_nx',p.sig_nx);
set_param_value('psig_Pi_tgt',p.sig_Pi_tgt);
set_param_value('psig_risk',p.sig_risk);
set_param_value('psig_risk_bgg',p.sig_risk_bgg);

set_param_value('pma_mu_p',p.ma_mu_p);
set_param_value('pma_mu_w',p.ma_mu_w);

set_param_value('prho_me_tp',p.rho_me_tp);

set_param_value('psig_me_tfp',p.sig_me_tfp);
set_param_value('psig_me_baa',p.sig_me_baa);
set_param_value('psig_me_tp',p.sig_me_tp);
set_param_value('psig_me_inflexp',p.sig_me_inflexp);

// Declare model equations
model; 
    // (1) Budget constraint for worker - no adjustment costs to offset wealth effects, 0.5*(ppsi_w)*(exp(Bw)-pBw)^2
    exp(Cb) + exp(Bw)/exp(R) = (1-exp(tau))*exp(w)*exp(N)/plambda + exp(Bw(-1))/exp(Pi)/exp(Gamma_eff) + exp(Tb_eff);

    // (2) Worker SDF
    exp(mb) = (pbetas/exp(Gamma_eff)) * (exp(chi_eff)/exp(Cb)) / (exp(chi_eff(-1))/exp(Cb(-1)));

    // (3) Worker Euler
    1 = exp(risk) * exp(mb(+1)) * (exp(R)/exp(Pi(+1))) * (1 /(1 + (ppsi_w)*(exp(Bw) - pBw)));
    
    // (4) Capitalist SDF
    exp(ms) = (pbetas/exp(Gamma_eff)) * (exp(chi_eff)/exp(Cs)) / (exp(chi_eff(-1))/exp(Cs(-1)));

    // (5) Capitalist Euler for bonds
    1 = exp(risk) * exp(ms(+1)) * (exp(R)/exp(Pi(+1)));

    // (6) Entrepreneur return on capital
    exp(ret_k)/exp(Pi) = ((1-exp(tau_d))*(exp(nu)*exp(rk) -  (pcons_util*(exp(nu)-1)+0.5*psig_util*(exp(nu)-1)^2)) + (1-pdelta)*exp(Qk))/exp(Qk(-1));

    // (7) Capitalist Euler for investment
    1 - exp(Qk)*exp(zeta_eff)*(1 - 0.5*ppsi_i*((exp(Gamma_eff))*exp(Inv)/exp(Inv(-1)) - pGamma)^2 - (exp(Gamma_eff))*exp(Inv)/exp(Inv(-1))*ppsi_i*((exp(Gamma_eff))*exp(Inv)/exp(Inv(-1)) - pGamma)) = exp(ms(+1)) * exp(Qk(+1)) * exp(zeta_eff(+1)) * ((exp(Gamma_eff(+1)))*exp(Inv(+1))/exp(Inv))^2 * ppsi_i*((exp(Gamma_eff(+1)))*exp(Inv(+1))/exp(Inv) - pGamma);

    // (8) Utilized vs physical capital
    exp(Ku) = exp(nu) * exp(K(-1))/exp(Gamma_eff);

    // (9) FOC for utilization
    exp(rk) = pcons_util + psig_util*(exp(nu)-1);

    // (10) Price indexation
    exp(Pi_index) = (exp(Pi)^prho_pi * (exp(Pi_tgt)^(1-prho_pi)));

    // (11) NKPC
    (exp(Pi)/exp(Pi_index(-1))) * (exp(Pi)/exp(Pi_index(-1))-1) = exp(ms(+1))*exp(Gamma_eff(+1))*(exp(Y(+1))/exp(Y))*(exp(Pi(+1))/exp(Pi_index)) * (exp(Pi(+1))/exp(Pi_index)-1) + (1/peta_p/(exp(mu_p_eff)-1))*(exp(mu_p_eff)*exp(mc) - 1);

    // (12) Marginal cost
    exp(mc) = (exp(rk)/palpha)^palpha * (exp(w)/(1-palpha))^(1-palpha);

    // (13) Production function
    exp(Y) = (exp(Ku))^palpha * exp(N)^(1-palpha);

    // (14) Optimal input mix
    exp(Ku) = (palpha/(1-palpha)) * exp(w) * exp(N) / exp(rk);

    // (15) MRS term for the wage NKPC
    exp(mrs) = exp(Cb) * pxi/(1-exp(tau));

    // (16) Wage NKPC
    peta_w*(exp(Pi_w)/exp(Pi_w_index(-1)))*(exp(Pi_w)/exp(Pi_w_index(-1))-1) =  pbetas*peta_w*(exp(N(+1))/exp(N))*(exp(Pi_w(+1))/exp(Pi_w_index))*((exp(Pi_w(+1))/exp(Pi_w_index))-1) + exp(w) + exp(mu_w_eff)/(exp(mu_w_eff)-1) * (exp(mrs)*((exp(N)/plambda)^pvarphi)*(1+pvarphi) - exp(w));

    // (17) Wage indexation term
    exp(Pi_w_index) = exp(Pi_w)^prho_w * (exp(Pi_tgt) * pGamma)^(1-prho_w);

    // (18) Wage inflation
    exp(Pi_w) = exp(w)/exp(w(-1)) * exp(Gamma_eff) * exp(Pi);

    // (19) Resource constraint
    exp(C) + exp(G) + exp(Inv) + ((pcons_util*(exp(nu)-1)+0.5*psig_util*(exp(nu)-1)^2))*exp(K(-1))/exp(Gamma_eff) + nx*exp(Y) = exp(Y)*(1-0.5*peta_p*(exp(Pi)/exp(Pi_index(-1))-1)^2);

    // (20) Investment and LoM for capital
    exp(K) =  (1-pdelta)*exp(K(-1))/exp(Gamma_eff) + exp(zeta_eff)*(1-0.5*ppsi_i*((exp(Gamma_eff))*exp(Inv)/exp(Inv(-1)) - pGamma)^2)*exp(Inv) ;

    // (21) Government budget constraint
    exp(G) + exp(Bg(-1))/exp(Pi)/exp(Gamma_eff) + plambda*exp(Tb_eff) = exp(tau)*exp(w)*exp(N) + exp(Bg)/exp(R) + exp(tau_d)*(exp(D) + exp(rk)*exp(Ku));

    // (22) Fiscal rule
    exp(tau) = ptau * (exp(Bg(-1))/pBg)^pphi_tau;

    // (23) Fiscal rule
    exp(tau_d) = ptau_d * (exp(Bg(-1))/pBg)^pphi_tau;

    // (24) Taylor rule
    exp(R) = (exp(R(-1))^prho_r) * ((pR * ((exp(Pi)/exp(Pi_tgt))^(pphi_pi)) * ((exp(Y)/exp(Y_flex))^pphi_y))^(1-prho_r)) * (( ((exp(Y)/exp(Y_flex))/(exp(Y(-1))/exp(Y_flex(-1)))) )^pphi_d) * exp(mp) * exp(covid_mp);

    // (25) Firm profits
    exp(D) = exp(Y) - exp(w)*exp(N) - exp(rk)*exp(Ku) - 0.5*peta_p*exp(Y)*(exp(Pi)/exp(Pi_index(-1))-1)^2;

    // (26) Aggregate consumption
    exp(C) = plambda * exp(Cb) + (1-plambda)*exp(Cs);

    // (27) Government consumption
    exp(G) = (1 - 1/exp(Gshock_eff))*exp(Y);

    // (28) Government spending
    exp(GT) = exp(G) +  plambda * exp(Tb_eff);

    // (29) Leverage
    exp(lev) = exp(Qk)*exp(K)/exp(nw);

    // (30) Financier default
    (exp(R(-1))/exp(ret_k)) * (exp(lev(-1))-1)/exp(lev(-1)) = exp(BGG_Gamma) - plambda_d*exp(BGG_G);

    // (31) Financier FOC
    0 = (exp(ret_k(+1))/exp(R))*(1-exp(BGG_Gamma(+1))) - (1-normcdf(omg(+1)/exp(risk_bgg) + 0.5*exp(risk_bgg)))/exp(lev)/(1-normcdf(omg(+1)/exp(risk_bgg) + 0.5*exp(risk_bgg)) - plambda_d*exp(omg(+1))*normpdf(omg(+1)/exp(risk_bgg) + 0.5*exp(risk_bgg)));

    // (32) Law of motion of financier net worth
    exp(nw)*exp(Pi) = pgamma_e * (1-exp(BGG_Gamma)) * exp(ret_k) * exp(Qk(-1)) * exp(K(-1))/exp(Gamma_eff) + pomega_e;  

    // (33) BGG G term
    exp(BGG_G) = 1 - normcdf(0.5*exp(risk_bgg(-1)) - omg/exp(risk_bgg(-1)));

    // (34) BGG Gamma term
    exp(BGG_Gamma) = (1-normcdf(omg/exp(risk_bgg(-1)) + 0.5*exp(risk_bgg(-1))))*exp(omg) + exp(BGG_G);

    // (35) TFP shock
    Gamma = (1-prho_Z)*log(pGamma) + prho_Z*Gamma(-1) + psig_Z*ee_Z;

    // (36) Govt spending shock
    Gshock = (1-prho_G)*log(pGshock) + prho_G*Gshock(-1) + psig_G*ee_G;

    // (37) Monetary policy shock
    mp = (1-prho_mp)*log(pmp) + prho_mp*mp(-1) + psig_mp*ee_mp;

    // (38) Labor market shock
    mu_w = (1-prho_mu_w)*log(pmu_w) + prho_mu_w*mu_w(-1) + psig_mu_w*ee_mu_w - pma_mu_w*psig_mu_w*ee_mu_w(-1);

    // (39) Marginal utility shock
    chi = (1-prho_chi)*log(pchi) + prho_chi*chi(-1) + psig_chi*ee_chi;

    // (40) Markup shock
    mu_p = (1-prho_mu_p)*log(pmu_p) + prho_mu_p*mu_p(-1) + psig_mu_p*ee_mu_p - pma_mu_p*psig_mu_p*ee_mu_p(-1);

    // (41) Fiscal transfers shock
    Tb = (1-prho_Tb)*log(pTb) + prho_Tb*Tb(-1) + psig_Tb*ee_Tb;

    // (42) MEI shock
    zeta = (1-prho_zeta)*log(pzeta) + prho_zeta*zeta(-1) + psig_zeta*ee_zeta;

    // (43) Trade balance shock
    nx = prho_nx*nx(-1) + psig_nx*ee_nx;

    // (44) Inflation target
    Pi_tgt = (1-prho_Pi_tgt)*log(pPi) + prho_Pi_tgt*Pi_tgt(-1) + psig_Pi_tgt*ee_Pi_tgt;

    // (45) Risk shock
    risk = (1-prho_risk)*log(prisk) + prho_risk*risk(-1) + psig_risk*ee_risk;

    // (46) BGG risk shock
    risk_bgg = (1-prho_risk_bgg)*log(prisk_bgg) + prho_risk_bgg*risk_bgg(-1) + psig_risk_bgg*ee_risk_bgg;

    // (47) Effective marginal utility
    chi_eff = chi + covid_chi;

    // (48) Effective mu_w
    mu_w_eff = mu_w + covid_mu_w;

    // (49) Effective mu_p
    mu_p_eff = mu_p + covid_mu_p;

    // (50) Effective zeta
    zeta_eff = zeta + covid_zeta;

    // (51) Effective govt spending shock
    Gshock_eff = Gshock + covid_Gshock;

    // (52) Effective transfers
    Tb_eff = Tb + covid_Tb;

    // (53) Effective productivity
    Gamma_eff = Gamma + covid_Gamma;

    // (1*) Budget constraint for worker, no adjustment costs to offset wealth effects + 0.5*(ppsi_w)*(exp(Bw_flex)-pBw)^2 
    exp(Cb_flex) + exp(Bw_flex)/exp(r_flex)/exp(Pi_tgt(+1)) = (1-exp(tau_flex))*exp(w_flex)*exp(N_flex)/plambda + exp(Bw_flex(-1))/exp(Pi_tgt)/exp(Gamma_eff) + exp(Tb_eff);

    // (2*) Worker SDF
    exp(mb_flex) = (pbetas/exp(Gamma_eff)) * (exp(chi_eff)/exp(Cb_flex)) / (exp(chi_eff(-1))/exp(Cb_flex(-1)));

    // (3*) Worker Euler
    1 = exp(risk) * exp(mb_flex(+1)) * exp(r_flex) * (1 /(1 + (ppsi_w)*(exp(Bw_flex) - pBw)));

    // (4*) Capitalist SDF
    exp(ms_flex) = (pbetas/exp(Gamma_eff)) * (exp(chi_eff)/exp(Cs_flex)) / (exp(chi_eff(-1))/exp(Cs_flex(-1)));
    
    // (5*) Capitalist Euler for bonds
    1 = exp(risk) * exp(ms_flex(+1)) * exp(r_flex);

    // (6*) Entrepreneur return on capital
    exp(ret_k_flex)/exp(Pi_tgt) = ((1-exp(tau_d_flex))*(exp(nu_flex)*exp(rk_flex) -  (pcons_util*(exp(nu_flex)-1)+0.5*psig_util*(exp(nu_flex)-1)^2)) + (1-pdelta)*exp(Qk_flex))/exp(Qk_flex(-1));

    // (7*) Saver Euler for investment
    1 - exp(Qk_flex)*exp(zeta_eff)*(1 - 0.5*ppsi_i*((exp(Gamma_eff))*exp(Inv_flex)/exp(Inv_flex(-1)) - pGamma)^2 - (exp(Gamma_eff))*exp(Inv_flex)/exp(Inv_flex(-1))*ppsi_i*((exp(Gamma_eff))*exp(Inv_flex)/exp(Inv_flex(-1)) - pGamma)) = exp(ms_flex(+1)) * exp(Qk_flex(+1)) * exp(zeta_eff(+1)) * ((exp(Gamma_eff(+1)))*exp(Inv_flex(+1))/exp(Inv_flex))^2 * ppsi_i*((exp(Gamma_eff(+1)))*exp(Inv_flex(+1))/exp(Inv_flex) - pGamma);

    // (8*) Utilized vs physical capital
    exp(Ku_flex) = exp(nu_flex) * exp(K_flex(-1))/exp(Gamma_eff);

    // (9*) FOC for utilization
    exp(rk_flex) = pcons_util + psig_util*(exp(nu_flex)-1);

    // (10*) Marginal costs
    (exp(rk_flex)/palpha)^palpha * (exp(w_flex)/(1-palpha))^(1-palpha) = 1/pmu_p;

    // (11*) Production function
    exp(Y_flex) = (exp(Ku_flex))^palpha * exp(N_flex)^(1-palpha);

    // (12*) Optimal input mix
    exp(Ku_flex) = (palpha/(1-palpha)) * exp(w_flex) * exp(N_flex) / exp(rk_flex);

    // (13*) MRS term for the wage NKPC
    exp(mrs_flex) = exp(Cb_flex) * pxi /(1-exp(tau_flex));

    // (14*) Wage NKPC
    exp(mrs_flex)*((exp(N_flex)/plambda)^pvarphi)*(1+pvarphi) = exp(w_flex)/pmu_w;

    // (15*) Resource constraint
    exp(C_flex) + exp(G_flex) + exp(Inv_flex) + (pcons_util*(exp(nu_flex)-1)+0.5*psig_util*(exp(nu_flex)-1)^2)*exp(K_flex(-1))/exp(Gamma_eff) + nx*exp(Y_flex) = exp(Y_flex);

    // (16*) Investment and LoM for capital
    exp(K_flex) =  (1-pdelta)*exp(K_flex(-1))/exp(Gamma_eff) + exp(zeta_eff)*(1-0.5*ppsi_i*((exp(Gamma_eff))*exp(Inv_flex)/exp(Inv_flex(-1)) - pGamma)^2)*exp(Inv_flex) ;

    // (17*) Government budget constraint
    exp(G_flex) + exp(Bg_flex(-1))/exp(Gamma_eff)/exp(Pi_tgt) + plambda*exp(Tb_eff) = exp(tau_flex)*exp(w_flex)*exp(N_flex) + exp(Bg_flex)/exp(r_flex)/exp(Pi_tgt(+1)) + exp(tau_d_flex)*(exp(D_flex) + exp(rk_flex)*exp(Ku_flex));

    // (18*) Fiscal rule
    exp(tau_flex) = ptau * (exp(Bg_flex(-1))/pBg_flex)^pphi_tau;

    // (19*) Fiscal rule
    exp(tau_d_flex) = ptau_d * (exp(Bg_flex(-1))/pBg_flex)^pphi_tau;

    // (20*) Firm profits
    exp(D_flex) = exp(Y_flex) - exp(w_flex)*exp(N_flex) - exp(rk_flex)*exp(Ku_flex);

    // (21*) Aggregate consumption
    exp(C_flex) = plambda * exp(Cb_flex) + (1-plambda)*exp(Cs_flex);

    // (22*) Government consumption
    exp(G_flex) = (1 - 1/exp(Gshock_eff))*exp(Y_flex);

    // (23*) Leverage
    exp(lev_flex) = exp(Qk_flex)*exp(K_flex)/exp(nw_flex);

    // (24*) Financier default
    exp(r_flex(-1))*exp(Pi_tgt)/exp(ret_k_flex) * (exp(lev_flex(-1))-1)/exp(lev_flex(-1)) = exp(BGG_Gamma_flex) - plambda_d*exp(BGG_G_flex);

    // (25*) Financier FOC
    0 = exp(ret_k_flex(+1))/exp(r_flex)/exp(Pi_tgt(+1))*(1-exp(BGG_Gamma_flex(+1))) - (1-normcdf(omg_flex(+1)/exp(risk_bgg) + 0.5*exp(risk_bgg)))/exp(lev_flex)/(1-normcdf(omg_flex(+1)/exp(risk_bgg) + 0.5*exp(risk_bgg)) - plambda_d*exp(omg_flex(+1))*normpdf(omg_flex(+1)/exp(risk_bgg) + 0.5*exp(risk_bgg)));

    // (26*) Law of motion of financier net worth
    exp(nw_flex)*exp(Pi_tgt) = pgamma_e * (1-exp(BGG_Gamma_flex)) * exp(ret_k_flex) * exp(Qk_flex(-1)) * exp(K_flex(-1))/exp(Gamma_eff) + pomega_e;  

    // (27*) BGG G term
    exp(BGG_G_flex) = 1 - normcdf(0.5*exp(risk_bgg(-1)) - omg_flex/exp(risk_bgg(-1)));

    // (28*) BGG Gamma term
    exp(BGG_Gamma_flex) = (1-normcdf(omg_flex/exp(risk_bgg(-1)) + 0.5*exp(risk_bgg(-1))))*exp(omg_flex) + exp(BGG_G_flex);

    // (1o) Observable - output growth
    y_growth = 400*(Y - Y(-1) + Gamma_eff);

    // (2o) Observable - consumption growth
    c_growth = 400*(C - C(-1) + Gamma_eff);

    // (3o) Observable - govt spending growth
    g_growth = 400*(G - G(-1) + Gamma_eff);

    // (4o) Observable - ann. Fed funds rate
    FFR = 100*(exp(R)^4-1);

    // (5o) Observable - qoq inflation
    inflation = 400*Pi;

    // (6o) Observable - govt expenditures/output
    GT_Y = exp(GT)/exp(Y);

    // (7o) Observable - hours
    log_hours = N;

    // (8o) Observable - wage growth
    w_growth = 400*(w - w(-1) + Gamma_eff);

    // (9o) Observable - investment growth
    i_growth = 400*(Inv - Inv(-1) + Gamma_eff);

    // (10o) Observable - inflation target
    inflation_exp10y = 100*(exp((1/10)*(Pi(+1) + Pi(+2) + Pi(+3) + Pi(+4) + Pi(+5) + Pi(+6) + Pi(+7) + Pi(+8) + Pi(+9) + Pi(+10) + Pi(+11) + Pi(+12) + Pi(+13) + Pi(+14) + Pi(+15) + Pi(+16) + Pi(+17) + Pi(+18) + Pi(+19) + Pi(+20) + Pi(+21) + Pi(+22) + Pi(+23) + Pi(+24) + Pi(+25) + Pi(+26) + Pi(+27) + Pi(+28) + Pi(+29) + Pi(+30) + Pi(+31) + Pi(+32) + Pi(+33) + Pi(+34) + Pi(+35) + Pi(+36) + Pi(+37) + Pi(+38) + Pi(+39) + Pi(+40))) - 1 + psig_me_inflexp*ee_me_inflexp);

    // (11o) Observable - public debt
    BgY = exp(Bg)/exp(Y);

    // (12o) Observable - model tfp 
    tfp_model = (1-palpha)*100*(exp(Gamma_eff)^4 - pGamma^4 + psig_me_tfp*ee_me_tfp);

    // (13o) Observable - covid chi
    covid_chi = 0;

    // (14o) Observable - covid mu_w
    covid_mu_w = 0;

    // (15o) Observable - covid mu_p
    covid_mu_p = 0;

    // (16o) Observable - covid zeta
    covid_zeta = 0;

    // (17o) Observable - covid Gshock
    covid_Gshock = 0;

    // (18o) Observable - covid Tb
    covid_Tb = 0;

    // (19o) Observable - covid Gamma
    covid_Gamma = 0;

    // (20o) Observable - covid mp
    covid_mp = 0;

    // (21o) Observable - 10y Treasury rate
    treasury10y = 100*(exp((1/10)*(R(+1) + R(+2) + R(+3) + R(+4) + R(+5) + R(+6) + R(+7) + R(+8) + R(+9) + R(+10) + R(+11) + R(+12) + R(+13) + R(+14) + R(+15) + R(+16) + R(+17) + R(+18) + R(+19) + R(+20) + R(+21) + R(+22) + R(+23) + R(+24) + R(+25) + R(+26) + R(+27) + R(+28) + R(+29) + R(+30) + R(+31) + R(+32) + R(+33) + R(+34) + R(+35) + R(+36) + R(+37) + R(+38) + R(+39) + R(+40))) - 1  + me_tp);

    // (21p) ME for Term Premium
    me_tp = prho_me_tp*me_tp(-1) + psig_me_tp*ee_me_tp;

    // (22o) Observable - BAA spread
    baa_spread = 100*(exp((1/10)*(ret_k(+1) + ret_k(+2) + ret_k(+3) + ret_k(+4) + ret_k(+5) + ret_k(+6) + ret_k(+7) + ret_k(+8) + ret_k(+9) + ret_k(+10) + ret_k(+11) + ret_k(+12) + ret_k(+13) + ret_k(+14) + ret_k(+15) + ret_k(+16) + ret_k(+17) + ret_k(+18) + ret_k(+19) + ret_k(+20) + ret_k(+21) + ret_k(+22) + ret_k(+23) + ret_k(+24) + ret_k(+25) + ret_k(+26) + ret_k(+27) + ret_k(+28) + ret_k(+29) + ret_k(+30) + ret_k(+31) + ret_k(+32) + ret_k(+33) + ret_k(+34) + ret_k(+35) + ret_k(+36) + ret_k(+37) + ret_k(+38) + ret_k(+39) + ret_k(+40))) - exp((1/10)*(R + R(+1) + R(+2) + R(+3) + R(+4) + R(+5) + R(+6) + R(+7) + R(+8) + R(+9) + R(+10) + R(+11) + R(+12) + R(+13) + R(+14) + R(+15) + R(+16) + R(+17) + R(+18) + R(+19) + R(+20) + R(+21) + R(+22) + R(+23) + R(+24) + R(+25) + R(+26) + R(+27) + R(+28) + R(+29) + R(+30) + R(+31) + R(+32) + R(+33) + R(+34) + R(+35) + R(+36) + R(+37) + R(+38) + R(+39)))+ psig_me_baa*ee_me_baa) ;
end;


// Steady state and some internal calibration
steady_state_model;
	Pi        = log(pPi);
    Pi_tgt    = log(pPi);
	Gamma     = log(pGamma);
	Pi_w      = log(pGamma*pPi);
	ms        = log(pbetas / pGamma);
    mb        = log(pbetas / pGamma);
    R         = log(pPi/exp(ms)/prisk);
	Z         = log(1);
	mp        = log(1);
	chi       = log(1);
	zeta      = log(1);
    risk      = log(prisk);
    risk_bgg  = log(prisk_bgg);
    nx        = 0;
	mu_p      = log(pmu_p);
    mu_w      = log(pmu_w);
    mc        = log(1/pmu_p);

	N          = plogN;
	Qk         = log(1);
    ret_k      = log((exp(R)^4 + pspread/100)^(1/4));
	rk         = log((exp(ret_k)/pPi + pdelta - 1)/(1-ptau_d));
    nu         = log(1);
    pcons_util = exp(rk);
	w          = log((1-palpha)*(exp(mc) * (palpha/exp(rk))^(palpha))^(1/(1-palpha)));
	K          = log(pGamma * (palpha/(1-palpha)) * exp(w)/exp(rk) * exp(N));
    Ku         = log(exp(K)/pGamma);
	Y          = log((exp(K)/pGamma)^palpha * (exp(N)^(1-palpha)));
	Inv        = log(exp(K)*(1 - (1-pdelta)/pGamma));
	G          = log(pGY * exp(Y));
	C          = log(exp(Y) - exp(G) - exp(Inv));
	D          = log(exp(Y) - exp(w)*exp(N) - exp(rk)*exp(K)/pGamma);
	Bg         = log(pBgY * exp(Y));
	Tb         = log((pGTY * exp(Y) - exp(G))/plambda);
	ptau       = (exp(G) + plambda*exp(Tb) + exp(Bg)/pPi/pGamma - exp(Bg)/exp(R) - ptau_d*(exp(D) + exp(rk)*exp(K)/pGamma))/exp(w)/exp(N);
	tau        = log(ptau);
    tau_d      = log(ptau_d);
    omg        = prisk_bgg * norminv(pdefault) - 0.5 * prisk_bgg^2;
    BGG_G      = log(1 - normcdf(0.5*prisk_bgg - omg/prisk_bgg));
    BGG_Gamma  = log((1-normcdf(omg/prisk_bgg + 0.5*prisk_bgg))*exp(omg) + exp(BGG_G));
    plambda_d  = (exp(ret_k)/exp(R) - 1) * (1 - normcdf(omg/prisk_bgg + 0.5*prisk_bgg)) / (exp(ret_k)/exp(R)) / ((1-exp(BGG_Gamma))*exp(omg)*normpdf(omg/prisk_bgg + 0.5*prisk_bgg) + (1-normcdf(omg/prisk_bgg + 0.5*prisk_bgg))*exp(BGG_G));
    lev        = log(1/(1 - (exp(ret_k)/exp(R))* (exp(BGG_Gamma)-plambda_d*exp(BGG_G))) );
    nw         = log(exp(Qk)*exp(K)/exp(lev));
    pomega_e   = exp(nw)*pPi - pgamma_e * (1-exp(BGG_Gamma)) * exp(ret_k) * exp(K) / pGamma;
    
    Bw         = log(pBwY * exp(Y) / plambda);
	Cb         = log((1-ptau)*exp(w)*exp(N)/plambda + exp(Tb) + exp(Bw)*(1/pPi/pGamma - 1/exp(R)));
	Cs         = log((exp(C) - plambda*exp(Cb))/(1-plambda));
	mgutil     = log(exp(chi)/exp(Cs));
	Gshock     = log(1/(1-exp(G)/exp(Y)));
	xi         = log((exp(w)/pmu_w) * ((1-ptau)/exp(Cb)) * (1/(1+pvarphi))*(plambda/exp(N))^pvarphi); 
	mrs        = log(exp(Cb)*exp(xi)/(1-ptau));

	Pi_index   = log(pPi);
	Pi_w_index = log(exp(Pi_w));
	GT   	   = log(exp(G) + plambda*exp(Tb));

    % Steady state values used as parameters
    pBw     = exp(Bw);
    pBg     = exp(Bg);
    pR      = exp(R);
    pGshock = exp(Gshock);
    pmp     = exp(mp);
    pxi     = exp(xi);
    pchi    = exp(chi);
    pTb     = exp(Tb);
    pzeta   = exp(zeta);

	% Observables
	y_growth          = 400*log(pGamma);
	c_growth          = 400*log(pGamma);
	g_growth  	      = 400*log(pGamma);
	w_growth  	      = 400*log(pGamma);
	i_growth  	      = 400*log(pGamma);
	FFR               = 100*(exp(R)^4-1);
	inflation         = 400*Pi;
    log_hours         = N;
    GT_Y              = exp(GT)/exp(Y);
    inflation_exp10y  = 100*(pPi^4-1);
    tp                = 0.0;
    treasury10y       = FFR;
    tfp_model         = 0;
    baa_spread        = pspread;
    covid_chi    = 0;
    covid_mu_w   = 0;
    covid_mu_p   = 0;
    covid_zeta   = 0;
    covid_Gshock = 0;
    covid_Tb     = 0;
    covid_Gamma  = 0;
    covid_mp     = 0;

    % Flex price model
    Cb_flex  = Cb;
    tau_flex = tau;
    tau_d_flex = tau_d;
    w_flex   = w;
    N_flex   = N;
    ms_flex  = ms;
    mb_flex  = mb;
    Cs_flex  = Cs;
    Qk_flex  = Qk;
    rk_flex  = rk;
    nu_flex  = nu;
    Inv_flex = Inv;
    Ku_flex  = Ku;
    Y_flex   = Y;
    K_flex   = K;
    mrs_flex = mrs;
    G_flex   = G;
    D_flex   = D;
    C_flex   = C;
    Bw_flex  = Bw;
    r_flex   = log(1/exp(ms_flex)/prisk);
    Bg_flex  = log((exp(G_flex) + plambda*exp(Tb) - exp(tau_flex)*exp(w_flex)*exp(N_flex) - ptau_d*(exp(D_flex) + exp(rk_flex)*exp(Ku_flex)))/(1/exp(r_flex)/pPi - 1/pGamma/pPi));
    pBg_flex = exp(Bg_flex);
    ret_k_flex = ret_k;
    lev_flex   = lev;
    nw_flex    = nw;
    omg_flex   = omg;
    BGG_G_flex = BGG_G;
    BGG_Gamma_flex = BGG_Gamma;

    BgY = exp(Bg)/exp(Y);
    Gamma_eff = Gamma;
    chi_eff   = chi;
    mu_w_eff  = mu_w;
    mu_p_eff  = mu_p;
    zeta_eff  = zeta;
    Gshock_eff = Gshock;
    Tb_eff  = Tb;

    me_tp = 0;
end;


// Declare shocks
shocks;
    var ee_Z;
    stderr 1;
    var ee_G;
    stderr 1;
    var ee_mp;
    stderr 1;
    var ee_mu_w;
    stderr 1;
    var ee_chi;
    stderr 1;
    var ee_mu_p;
    stderr 1;
    var ee_Tb;
    stderr 1;
    var ee_zeta;
    stderr 1;
    var ee_nx;
    stderr 1;
    var ee_Pi_tgt;
    stderr 1;
    var ee_risk;
    stderr 1;
    var ee_risk_bgg;
    stderr 1;
    var ee_me_tfp;
    stderr 1;
    var ee_me_baa;
    stderr 1;
    var ee_me_tp;
    stderr 1;
    var ee_me_inflexp;
    stderr 1;
end;


// Run a series of diagnostics on the model
resid;
check;
model_diagnostics;
steady;

// Estimate the model
estimated_params;
    pvarphi,   gamma_pdf,     2.0000, 0.7500; 
    peta_p,    gamma_pdf,     60.000, 20.000;
    peta_w,    gamma_pdf,     60.000, 20.000;
    ppsi_i,    inv_gamma_pdf, 5.0000, 1.0000;
    prho_pi,   beta_pdf,      0.5000, 0.1500;
    prho_w,    beta_pdf,      0.5000, 0.1500;
    psig_util, inv_gamma_pdf, 0.5000, 0.1000;
    palpha,    normal_pdf,    0.3000, 0.0500;
    plogN,     normal_pdf,   -1.5616, 0.2500;
    ppsi_w,    inv_gamma_pdf, 0.5000, 0.5000; 
    plambda,   beta_pdf,      0.7000, 0.1000; 
    prisk,     normal_pdf,    1.0031, 0.0005;
    pspread,   normal_pdf,    2.0422, 0.0500;
    prisk_bgg, inv_gamma_pdf, 0.5000, 0.5000;

    pphi_pi,   normal_pdf,    1.5000, 0.2500; 
    pphi_y,    normal_pdf,    0.1200, 0.0500;
    pphi_d,    normal_pdf,    0.1200, 0.0500;
    prho_r,    beta_pdf,      0.7500, 0.1000;
    pGTY,      normal_pdf,    0.3328, 0.0100;
    pBwY,      normal_pdf,    0.7500, 0.2500; 
    pphi_tau,  inv_gamma_pdf, 0.0200, 0.0500;

    pma_mu_p, beta_pdf, 0.5000, 0.2000;
    pma_mu_w, beta_pdf, 0.5000, 0.2000;

    prho_Z,        beta_pdf, 0.5000, 0.200;
    prho_mu_p,     beta_pdf, 0.5000, 0.200;
    prho_mu_w,     beta_pdf, 0.5000, 0.200;
    prho_zeta,     beta_pdf, 0.5000, 0.200;
    prho_chi,      beta_pdf, 0.5000, 0.200;
    prho_nx,       beta_pdf, 0.5000, 0.200;
//    prho_risk,     beta_pdf, 0.9900, 0.005;
    prho_risk_bgg, beta_pdf, 0.5000, 0.200;
    prho_G,        beta_pdf, 0.5000, 0.200;
    prho_Tb,       beta_pdf, 0.5000, 0.200;
//    prho_Pi_tgt,   beta_pdf, 0.9900, 0.005;
    prho_mp,       beta_pdf, 0.5000, 0.200;

    psig_Z,        inv_gamma_pdf, 0.010,  0.050;
    psig_mu_p,     inv_gamma_pdf, 0.010,  0.050;
    psig_mu_w,     inv_gamma_pdf, 0.010,  0.050;
    psig_zeta,     inv_gamma_pdf, 0.010,  0.050;
    psig_chi,      inv_gamma_pdf, 0.010,  0.050;
    psig_nx,       inv_gamma_pdf, 0.010,  0.050;
    psig_risk,     inv_gamma_pdf, 0.005,  0.050;
    psig_risk_bgg, inv_gamma_pdf, 0.010,  0.050;
    psig_G,        inv_gamma_pdf, 0.010,  0.050;
    psig_Tb,       inv_gamma_pdf, 0.010,  0.050;
    psig_Pi_tgt,   inv_gamma_pdf, 0.001,  0.050;
    psig_mp,       inv_gamma_pdf, 0.010,  0.050;

    prho_me_tp,    beta_pdf, 0.500, 0.200;

    psig_me_tfp,     inv_gamma_pdf, 0.010, 0.050;
    psig_me_baa,     inv_gamma_pdf, 0.010, 0.050;
    psig_me_tp,      inv_gamma_pdf, 0.010, 0.050;
    psig_me_inflexp,      inv_gamma_pdf, 0.010, 0.050;
end;

varobs y_growth c_growth i_growth w_growth g_growth GT_Y log_hours FFR inflation inflation_exp10y tfp_model treasury10y baa_spread;
%identification;
estimation(order=1, datafile=data_estimation, nobs=244, plot_priors=0, mode_compute=5, optim=('Hessian',2), mode_check, prefilter=0, mh_replic=20000, mh_nblocks=4, mh_jscale=0.20);
%estimation(order=1, datafile=data_estimation, nobs=244, plot_priors=0, mode_compute=0, mode_file='dsge_estimate/Output/dsge_estimate_mode.mat', mode_check, prefilter=0, mh_replic=100000, mh_nblocks=4, mh_jscale=0.20);
%estimation(order=1, datafile=data_estimation, nobs=244, plot_priors=0, mode_compute=0, mode_file='dsge_estimate/Output/dsge_estimate_mh_mode.mat', prefilter=0, mh_replic=50000, mh_nblocks=4, mh_jscale=0.20, load_mh_file);
steady;
stoch_simul(order=1, nograph);  