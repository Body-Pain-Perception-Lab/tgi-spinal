## SPINAL TGI ANALYSIS SCRIPT ##
## Created by A.G. Mitchell on 06.04.2022 ##
# Last edited:

##### Loading libraries & data #####
library(dplyr)
library(ggplot2)

# paths
datPath <- '/Users/au706616/Documents/Experiments/SPINALTGI/'
setwd(datPath)
# load in all csv files
filenames <- dir(datPath, recursive = TRUE, full.names = FALSE, pattern = '.csv')
# empty dataframes for data
## with new data trials file will have changed to include temperature coding!
df_trials <- read.csv(text='procedure,trial_type,arm,condition,dermatome,cold_probe,trial_tot,ID,manipulation')
df_VAS <- read.csv(text='VASburning,VASwarm,VAScold,trial_tot,ID,manipulation')
df_RT <- read.csv(text='RTburning,RTwarm,RTcold,trial_tot,ID,manipulation')

##### Data compiling #####
# trial files
for (file in filenames){
  # trial files
  if (isTRUE(substr(basename(file), 22, 22)=="t")){
    tmp <- read.csv(file)
    tmp$ID <- substr(basename(file), 1, 4)
    tmp$manipulation <- substr(basename(file), 8, 10)
    df_trials <- rbind(df_trials, tmp)
  }
  # VAS response files
  if (isTRUE(substr(basename(file), 22, 29)=="Response")){
    tmp <- read.csv(file, header = FALSE)
    colnames(tmp) <- c('VASburning','VASwarm','VAScold','trial_tot')
    tmp$ID <- substr(basename(file), 1, 4)
    tmp$manipulation <- substr(basename(file), 8, 10)
    df_VAS <- rbind(df_VAS, tmp)
  }
  # VAS RT files
  if (isTRUE(substr(basename(file), 22, 26)=="RespT")){
    tmp <- read.csv(file, header = FALSE)
    colnames(tmp) <- c('RTburning','RTwarm','RTcold','trial_tot')
    tmp$ID <- substr(basename(file), 1, 4)
    tmp$manipulation <- substr(basename(file), 8, 10)
    df_RT <- rbind(df_RT, tmp)
  }
}

# merge all files
df_res <- merge(df_trials, df_VAS, by = c('ID','trial_tot','manipulation'))
df_res <- merge(df_res, df_RT, by = c('ID','trial_tot','manipulation'))
# recode condition
df_res <- df_res %>%
  mutate(condition = recode(condition, '1' = 'within', '2' = 'across'))

# isolate just my data (for now)
AGM <- df_res[df_res$ID == '0001' ,]
# just include valid trials < 33
AGM <- AGM[AGM$trial_tot < 33 ,]

# plot all data
# burning
ggplot(AGM, aes(group = trial_tot, colour = cold_probe)) +
  geom_point(aes(condition, VASburning), position = position_dodge(.2)) +
  facet_wrap(~manipulation) +
  theme_classic()
# warm
ggplot(AGM, aes(group = trial_tot, colour = cold_probe)) +
  geom_point(aes(condition, VASwarm), position = position_dodge(.2)) +
  facet_wrap(~manipulation) +
  theme_classic()
# cold
ggplot(AGM, aes(group = trial_tot, colour = cold_probe)) +
  geom_point(aes(condition, VAScold), position = position_dodge(.2)) +
  facet_wrap(~manipulation) +
  theme_classic()


# get mean VAS responses for each condition
VASburn <- aggregate(VASburning~manipulation*condition*cold_probe*dermatome*ID, mean, data = AGM)
VASwarm <- aggregate(VASwarm~manipulation*condition*cold_probe*dermatome*ID, mean, data = AGM)
VAScold <- aggregate(VAScold~manipulation*condition*cold_probe*dermatome*ID, mean, data = AGM)
# standard deviations
SDburn <- aggregate(VASburning~manipulation*condition*cold_probe*dermatome*ID, sd, data = AGM)
SDwarm <- aggregate(VASwarm~manipulation*condition*cold_probe*dermatome*ID, sd, data = AGM)
SDcold <- aggregate(VAScold~manipulation*condition*cold_probe*dermatome*ID, sd, data = AGM)

