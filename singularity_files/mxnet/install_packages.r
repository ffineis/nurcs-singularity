packages <- c('MASS'
              , 'Rcpp'
              , 'data.table'
              , 'zoo'
              , 'xts'
              , 'httr'
              , 'devtools'
              , 'lubridate'
              , 'doMC'
              , 'foreach'
              , 'ggplot2'
              , 'dplyr'
              , 'plyr'
              , 'purrr'
              , 'tidyr'
              , 'stringr'
              , 'car'
              , 'lme4'
              , 'survival'
              , 'glmnet'
              , 'caret'
              , 'xtable')

curPackages <- names(installed.packages()[, 1])
for(p in packages){
    if(!(p %in% curPackages)){
        install.packages(p, repos='http://cran.us.r-project.org')
    }
}
