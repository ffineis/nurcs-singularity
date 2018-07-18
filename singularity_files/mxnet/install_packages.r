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
              , 'purr'
              , 'tidyr'
              , 'stringr'
              , 'car'
              , 'lme4'
              , 'survival'
              , 'glmnet'
              , 'caret'
              , 'xtable')

for(p in packages){
    if(!(p %in% names(installed.packages()[, 1]))){
        install.packages(p, repos='http://cran.us.r-project.org')
    }
}