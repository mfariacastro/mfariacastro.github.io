function save_variables_stata(M_,oo_,dates,vars_extract)
    % Save some variables in a CSV file to plot in stata
    table_save = array2table(dates);

    for ii = 1:size(vars_extract,1)
        currvar   = vars_extract{ii};
        endoindex = find(strcmp(M_.endo_names, currvar));

        % smoothed variable
        smoothvar = oo_.steady_state(endoindex) + oo_.shock_decomposition(endoindex, M_.exo_nbr+2, :);
        smoothvar = reshape(smoothvar,[],1);

        table_save = addvars(table_save, smoothvar, 'NewVariableNames', vars_extract{ii});
    end

    writetable(table_save, '../data/rstar_model.csv');
end