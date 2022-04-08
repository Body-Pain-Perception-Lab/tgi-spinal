## SPINAL TGI ANALYSIS SCRIPT ##
## Created by A.G. Mitchell on 06.04.2022 ##
# Last edited: 08.04.22

##### Loading libraries & data #####
library(dplyr)
library(ggplot2)
library("RColorBrewer")

# paths
datPath <- '/Users/au706616/Documents/Experiments/SPINALTGI/Raw/'
setwd(datPath)
# load in all csv files
filenames <- dir(datPath, recursive = TRUE, full.names = FALSE, pattern = '.csv')
# empty dataframes for data
## with new data trials file will have changed to include temperature coding!
df_trials <- read.csv(text='procedure,trial_type,arm,condition,dermatome,cold_probe,trial_n,coolTemp,warmTempID,manipulation')
df_VAS <- read.csv(text='VASburning,VASwarm,VAScold,trial_n,ID,manipulation')
df_RT <- read.csv(text='RTburning,RTwarm,RTcold,trial_n,ID,manipulation')

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
    colnames(tmp) <- c('VASburning','VASwarm','VAScold','trial_n')
    tmp$ID <- substr(basename(file), 1, 4)
    tmp$manipulation <- substr(basename(file), 8, 10)
    df_VAS <- rbind(df_VAS, tmp)
  }
  # VAS RT files
  if (isTRUE(substr(basename(file), 22, 26)=="RespT")){
    tmp <- read.csv(file, header = FALSE)
    colnames(tmp) <- c('RTburning','RTwarm','RTcold','trial_n')
    tmp$ID <- substr(basename(file), 1, 4)
    tmp$manipulation <- substr(basename(file), 8, 10)
    df_RT <- rbind(df_RT, tmp)
  }
}

# merge all files
df_res <- merge(df_trials, df_VAS, by = c('ID','trial_n','manipulation'))
df_res <- merge(df_res, df_RT, by = c('ID','trial_n','manipulation'))
# recode conditions
df_res <- df_res %>%
  mutate(condition = recode(condition, '1' = 'within', '2' = 'across'),
         cold_probe = recode(cold_probe, 'C6' = 'rostral', 'T1' = 'caudal',
                             'dist' = 'distal', 'prox' = 'proximal'))

##### Individual participant plots ######
# just include valid trials < 33
df_res <- df_res[df_res$trial_n < 33 ,]
# change levels for plotting
df_res$cold_probe <- factor(df_res$cold_probe, 
                            levels = c("caudal", "rostral", "distal", "proximal"))

# isolate specific VAS types, then bind by column
# burning
df_burn <- df_res[, 1:12]
df_burn$VAS <- 'burn'
names(df_burn)[12] <- 'rating'
# warm
df_warm <- df_res[, c(1:11,13)]
df_warm$VAS <- 'warm'
names(df_warm)[12] <- 'rating'
#cold
df_cold <- df_res[, c(1:11,14)]
df_cold$VAS <- 'cold'
names(df_cold)[12] <- 'rating'
# combine
df_plot <- rbind(df_burn, df_warm, df_cold)
df_plot$VAS <- factor(df_plot$VAS, 
                             levels = c("cold", "warm", "burn"))

# Define colors
reds <- brewer.pal(6, "Reds")
blues <- brewer.pal(6, "Blues")
purps <- brewer.pal(6, "Purples")
green <- brewer.pal(6, "Greens")

caudal <- blues[6]
rostral <- blues[3]
distal <- green[6]
proximal <- green[3]
colours <- c(caudal, rostral, distal, proximal)

## plot individual participants
# isolate just my data (for now)
AGM <- df_plot[df_plot$ID == '0001' ,]
CEA <- df_plot[df_plot$ID == 'C001' ,]

# AGM - TGI
ggplot(AGM[AGM$manipulation=='TGI' ,], aes(group = trial_n, colour = cold_probe)) +
  geom_point(aes(condition, rating), position = position_dodge(.2)) +
  facet_wrap(~VAS) +
  scale_colour_manual(values = colours) +
  theme_classic() +
  labs(title = 'TGI') +
  theme(legend.position = 'bottom',
        legend.title = element_blank())
# AGM - nonTGI
ggplot(AGM[AGM$manipulation=='CNT' ,], aes(group = trial_n, colour = cold_probe)) +
  geom_point(aes(condition, rating), position = position_dodge(.2)) +
  facet_wrap(~VAS) +
  scale_colour_manual(values = colours) +
  theme_classic() +
  labs(title = 'Non TGI') +
  theme(legend.position = 'bottom',
        legend.title = element_blank())

# CEA - TGI
ggplot(CEA[CEA$manipulation=='TGI' ,], aes(group = trial_n, colour = cold_probe)) +
  geom_point(aes(condition, rating), position = position_dodge(.2)) +
  facet_wrap(~VAS) +
  scale_colour_manual(values = colours) +
  theme_classic() +
  labs(title = 'TGI') +
  theme(legend.position = 'bottom',
        legend.title = element_blank())
# CEA - nonTGI
ggplot(CEA[CEA$manipulation=='CNT' ,], aes(group = trial_n, colour = cold_probe)) +
  geom_point(aes(condition, rating), position = position_dodge(.2)) +
  facet_wrap(~VAS) +
  scale_colour_manual(values = colours) +
  theme_classic() +
  labs(title = 'Non TGI') +
  theme(legend.position = 'bottom',
        legend.title = element_blank())


##### Summary statistics & plots #####
# get mean VAS responses for each condition
VASresponse <- aggregate(rating~ID*VAS*manipulation*condition*cold_probe*dermatome, 
                         median, data = df_plot)

# H1: the effect of dermatome
VAS_H1 <- aggregate(rating~ID*VAS*manipulation*condition, 
                    mean, data = VASresponse)
# plotting - TGI
ggplot(VAS_H1[VAS_H1$manipulation=='TGI' ,], 
       aes(condition, rating, group = ID, colour = ID)) +
  geom_point(position = position_dodge(.3)) +
  facet_wrap(~VAS) +
  labs(title = 'TGI') +
  theme_classic()
# non TGI
ggplot(VAS_H1[VAS_H1$manipulation=='CNT' ,], 
       aes(condition, rating, group = ID, colour = ID)) +
  geom_point(position = position_dodge(.3)) +
  facet_wrap(~VAS) +
  labs(title = 'Non TGI') +
  theme_classic()
   
# H2: across dermatome
VAS_H2 <- VASresponse[VASresponse$condition == 'across' ,]
# plotting - TGI
ggplot(VAS_H2[VAS_H2$manipulation=='TGI' ,], 
       aes(cold_probe, rating, group = ID, colour = ID)) +
  geom_point(position = position_dodge(.3)) +
  facet_wrap(~VAS) +
  labs(title = 'TGI') +
  theme_classic()
# non TGI
ggplot(VAS_H2[VAS_H2$manipulation=='CNT' ,], 
       aes(cold_probe, rating, group = ID, colour = ID)) +
  geom_point(position = position_dodge(.3)) +
  facet_wrap(~VAS) +
  labs(title = 'Non TGI') +
  theme_classic()

# H3: within dermatome
VAS_H3 <- VASresponse[VASresponse$condition == 'within' ,]
# plotting - TGI
ggplot(VAS_H3[VAS_H3$manipulation=='TGI' ,], 
       aes(cold_probe, rating, group = ID, colour = ID)) +
  geom_point(position = position_dodge(.3)) +
  facet_wrap(~VAS) +
  labs(title = 'TGI') +
  theme_classic()
# non TGI
ggplot(VAS_H3[VAS_H3$manipulation=='CNT' ,], 
       aes(cold_probe, rating, group = ID, colour = ID)) +
  geom_point(position = position_dodge(.3)) +
  facet_wrap(~VAS) +
  labs(title = 'Non TGI') +
  theme_classic()


