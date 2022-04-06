## SPINAL TGI ANALYSIS SCRIPT ##
## Created by A.G. Mitchell on 06.04.2022 ##
# Last edited:

##### Loading libraries & data #####
datPath <- '/Users/au706616/Documents/Experiments/SPINALTGI/'
setwd(datPath)
# load in all csv files
filenames <- dir(datPath, recursive = TRUE, full.names = FALSE, pattern = '.csv')
# empty dataframes for data
df_trials <- read.csv(text='procedure,trial_type,arm,condition,dermatome,cold_probe,trial_tot,ID,manipulation')
df_VAS <- read.csv(text='VASburning,VASwarm,VAScold,trial_tot,ID,manipulation')
df_RT <- read.csv(text='RTburning,RTwarm,RTcold,trial_tot,ID,manipulation')

## need to find a way to index control and tgi files easily
# trial files
for (file in filenames){
  if (isTRUE(substr(basename(file), 22, 22)=="t")){
    tmp <- read.csv(file)
    tmp$ID <- substr(basename(file), 1, 4)
    tmp$manipulation <- substr(basename(file), 8, 10)
    df_trials <- rbind(df_trials, tmp)
  }
  if (isTRUE(substr(basename(file), 22, 29)=="Response")){
    tmp <- read.csv(file, header = FALSE)
    colnames(tmp) <- c('VASburning','VASwarm','VAScold','trial_tot')
    tmp$ID <- substr(basename(file), 1, 4)
    tmp$manipulation <- substr(basename(file), 8, 10)
    df_VAS <- rbind(df_VAS, tmp)
  }
  if (isTRUE(substr(basename(file), 22, 26)=="RespT")){
    tmp <- read.csv(file, header = FALSE)
    colnames(tmp) <- c('RTburning','RTwarm','RTcold','trial_tot')
    tmp$ID <- substr(basename(file), 1, 4)
    tmp$manipulation <- substr(basename(file), 8, 10)
    df_RT <- rbind(df_RT, tmp)
  }
}

# tgi files
# control files
