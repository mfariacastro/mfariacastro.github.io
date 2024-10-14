function clean_old_results()
    if exist('+dsge_estimate', 'dir')
        rmdir('+dsge_estimate', 's')
    end
    if exist('+dsge_smooth', 'dir')
        rmdir('+dsge_smooth', 's')
    end
    if exist('dsge_estimate', 'dir')
        rmdir('dsge_estimate', 's')
    end
    if exist('dsge_smooth', 'dir')
        rmdir('dsge_smooth', 's')
    end
    if exist('dynareParallelLogFiles', 'dir')
        rmdir('dynareParallelLogFiles', 's')
    end

    rmdir('estimation_results', 's')
    mkdir('estimation_results')

    rmdir('figures', 's')
    mkdir('figures')

    delete *.mat
    delete *.log
    delete *.asv
    delete *.xlsx
end