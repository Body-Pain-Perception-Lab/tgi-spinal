## SPINAL TGI ANALYSIS SCRIPT ##
## Created by A.G. Mitchell on 06.04.2022 ##
# Last edited:

##### Loading libraries & data #####
datPath <- '/Users/au706616/Documents/Experiments/SPINALTGI/'
setwd(datPath)
# load in all csv files
filenames <- dir(datPath, recursive = TRUE, full.names = FALSE, pattern = '.csv')
# empty dataframes for data
df_trials <- read.csv(text='procedure,trial_type,arm,condition,dermatome,cold_probe,trial_tot')
df_VAS <- read.csv(text='VASburning,VASwarm,VAScold,trial_tot')
df_RT <- read.csv(text='RTburning,RTwarm,RTcold,trial_tot')

## need to find a way to index control and tgi files easily
# trial files
for (file in filenames){
  if (isTRUE(substr(basename(file), 8, 8)=="p")){
  #tmp <- 
}

# tgi files
# control files
