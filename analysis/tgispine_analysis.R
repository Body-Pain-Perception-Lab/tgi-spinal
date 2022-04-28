## SPINAL TGI ANALYSIS SCRIPT ##
## Created by A.G. Mitchell on 06.04.2022 ##
# Last edited: 08.04.22

##### Loading libraries & data #####
library(dplyr)
library(ggplot2)
library(RColorBrewer)
library(ggpubr)
library(Rmisc)

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
# change levels 
df_res$cold_probe <- factor(df_res$cold_probe, 
                            levels = c("caudal", "rostral", "distal", "proximal"))
df_res$ID <- factor(df_res$ID, 
                    labels = c("1", "2", "3"))

## normalise VAS ratings for each participant
# just include valid trials < 33
df_res <- df_res[df_res$trial_n < 33 ,]
# create frame for new dataframe
df_norm <- data.frame(matrix(ncol = 20, nrow = 0))
for (id_idx in 1:3) {
  tmp <- df_res[df_res$ID == id_idx ,]
  # find the max value for each VAS ratings
  max_burn <- max(tmp$VASburning, na.rm = TRUE)
  max_warm <- max(tmp$VASwarm, na.rm = TRUE)
  max_cold <- max(tmp$VAScold, na.rm = TRUE)
  # then normalise all
  tmp$norm_VASburn <- tmp$VASburning/max_burn
  tmp$norm_VASwarm <- tmp$VASwarm/max_warm
  tmp$norm_VAScold <- tmp$VAScold/max_cold
    
  # compile all into one data-frame
  df_norm <- rbind(df_norm, tmp)
}

# save new data-frame
write.csv(df_norm, 'STGI_compiled-data.csv', row.names = FALSE)

##### Individual participant plots ######
# first need to make app data frame, isolate specific VAS types then bind by column
# burning
df_burn <- df_norm[, c(1:12,18)]
df_burn$VAS <- 'burn'
names(df_burn)[12] <- 'rating'
names(df_burn)[13] <- 'norm_rating'
# warm
df_warm <- df_norm[, c(1:11,13,19)]
df_warm$VAS <- 'warm'
names(df_warm)[12] <- 'rating'
names(df_warm)[13] <- 'norm_rating'
#cold
df_cold <- df_norm[, c(1:11,14,20)]
df_cold$VAS <- 'cold'
names(df_cold)[12] <- 'rating'
names(df_cold)[13] <- 'norm_rating'
# combine
df_plot <- rbind(df_burn, df_warm, df_cold)
# recode levels for plotting
df_plot$VAS <- factor(df_plot$VAS, 
                             levels = c("cold", "warm", "burn"))
df_plot$condition <- factor(df_plot$condition, 
                      labels = c("across", "within"))

# Define colors
reds <- brewer.pal(8, "Reds")
redpu <- brewer.pal(8, "RdPu")
orans <- brewer.pal(8, "Oranges")
blues <- brewer.pal(8, "Blues")
purps <- brewer.pal(8, "Purples")
green <- brewer.pal(8, "YlGn")
blgrn <- brewer.pal(8, "BuGn")

# caudal, rostral, distal, proximal colours
col_burn <- c(purps[4], purps[7], redpu[3], redpu[6])
col_warm <- c(reds[3], reds[6], orans[3], orans[6])
col_cold <- c(blues[3], blues[6], blgrn[4], blgrn[7])

## plot individual participants
# isolate just my data (for now)
P1 <- df_plot[df_plot$ID == '1' ,]
P2 <- df_plot[df_plot$ID == '2' ,]
P3 <- df_plot[df_plot$ID == '3' ,]

# BURN - TGI
BTGI <- ggplot(df_plot[df_plot$VAS=='burn' & df_plot$manipulation == 'TGI' ,], 
                aes(group = trial_n, colour = cold_probe))  +
  geom_point(aes(condition, norm_rating), size = 1.7, position = position_dodge(.2)) +
  facet_wrap(~ID) +
  scale_colour_manual(values = col_burn) +
  lims(y = c(0, 1)) +
  theme_classic() +
  labs(title = 'TGI', x = 'Condition', y = '') +
  theme(legend.position = 'none',
        legend.title = element_blank())

# BURN - nonTGI
BNTGI <- ggplot(df_plot[df_plot$VAS=='burn' & df_plot$manipulation == 'CNT' ,], 
                 aes(group = trial_n, colour = cold_probe)) +
  geom_point(aes(condition, norm_rating), size = 1.7, position = position_dodge(.2)) +
  facet_wrap(~ID) +
  scale_colour_manual(values = col_burn) +
  theme_classic() +
  lims(y = c(0, 1)) +
  labs(title = 'Non TGI', x = 'Condition', y = 'VAS Rating') +
  theme(legend.position = 'bottom',
        legend.title = element_blank())

BURN <- ggarrange(BNTGI, BTGI,
                ncol = 2, nrow = 1,
                common.legend = TRUE,
                legend = 'bottom')
ggsave('BURNplot.png', BURN, device = NULL, path = datPath, width = 8, height = 5)

# WARM - TGI
WTGI <- ggplot(df_plot[df_plot$VAS=='warm' & df_plot$manipulation == 'TGI' ,], 
               aes(group = trial_n, colour = cold_probe))  +
  geom_point(aes(condition, norm_rating), size = 1.7, position = position_dodge(.2)) +
  facet_wrap(~ID) +
  scale_colour_manual(values = col_warm) +
  lims(y = c(0, 1)) +
  theme_classic() +
  labs(title = 'TGI', x = 'Condition', y = '') +
  theme(legend.position = 'none',
        legend.title = element_blank())

# WARM - nonTGI
WNTGI <- ggplot(df_plot[df_plot$VAS=='warm' & df_plot$manipulation == 'CNT' ,], 
                aes(group = trial_n, colour = cold_probe)) +
  geom_point(aes(condition, norm_rating), size = 1.7, position = position_dodge(.2)) +
  facet_wrap(~ID) +
  scale_colour_manual(values = col_warm) +
  theme_classic() +
  lims(y = c(0, 1)) +
  labs(title = 'Non TGI', x = 'Condition', y = 'VAS Rating') +
  theme(legend.position = 'bottom',
        legend.title = element_blank())

WARM <- ggarrange(WNTGI, WTGI,
                  ncol = 2, nrow = 1,
                  common.legend = TRUE,
                  legend = 'bottom')
ggsave('WARMplot.png', WARM, device = NULL, path = datPath, width = 8, height = 5)

# COLD - TGI
CTGI <- ggplot(df_plot[df_plot$VAS=='cold' & df_plot$manipulation == 'TGI' ,], 
               aes(group = trial_n, colour = cold_probe))  +
  geom_point(aes(condition, norm_rating), size = 1.7, position = position_dodge(.2)) +
  facet_wrap(~ID) +
  scale_colour_manual(values = col_cold) +
  lims(y = c(0, 1)) +
  theme_classic() +
  labs(title = 'TGI', x = 'Condition', y = '') +
  theme(legend.position = 'none',
        legend.title = element_blank())

# COLD - nonTGI
CNTGI <- ggplot(df_plot[df_plot$VAS=='cold' & df_plot$manipulation == 'CNT' ,], 
                aes(group = trial_n, colour = cold_probe)) +
  geom_point(aes(condition, norm_rating), size = 1.7, position = position_dodge(.2)) +
  facet_wrap(~ID) +
  scale_colour_manual(values = col_cold) +
  theme_classic() +
  lims(y = c(0, 1)) +
  labs(title = 'Non TGI', x = 'Condition', y = 'VAS Rating') +
  theme(legend.position = 'bottom',
        legend.title = element_blank())

COLD <- ggarrange(CNTGI, CTGI,
                  ncol = 2, nrow = 1,
                  common.legend = TRUE,
                  legend = 'bottom')
ggsave('COLDplot.png', COLD, device = NULL, path = datPath, width = 8, height = 5)


##### Summary stats #####
# get mean VAS responses for each condition
VASresponse <- aggregate(norm_rating~ID*VAS*manipulation*condition*cold_probe, 
                         mean, data = df_plot)
VASSD <- aggregate(norm_rating~ID*VAS*manipulation*condition*cold_probe, 
                   sd, data = df_plot)
names(VASSD)[6] <- 'std'

VASresponse <- merge(VASresponse,VASSD)

# identifying labelling conditions
VASresponse$conditionN[VASresponse$condition == "within" & 
                         VASresponse$cold_probe == "distal"] <- 1
VASresponse$conditionN[VASresponse$condition == "within" & 
                         VASresponse$cold_probe == "proximal"] <- 2
VASresponse$conditionN[VASresponse$condition == "across" & 
                         VASresponse$cold_probe == "caudal"] <- 3
VASresponse$conditionN[VASresponse$condition == "across" & 
                         VASresponse$cold_probe == "rostral"] <- 4

# H1: the effect of dermatome
VAS_H1 <- aggregate(norm_rating~ID*VAS*manipulation*condition, 
                    mean, data = VASresponse)
VAS_H1_SD <- aggregate(norm_rating~ID*VAS*manipulation*condition, 
                       sd, data = VASresponse)
names(VAS_H1_SD)[5] <- 'SD'
VAS_H1 <- merge(VAS_H1, VAS_H1_SD)
# summary stats for participants
# this is the data we will use to inform the simulation - save
SUMstats <- summarySEwithin(data = VASresponse, measurevar = 'norm_rating', 
                            withinvars = c('manipulation','VAS','condition','cold_probe'), 
                            na.rm = TRUE, conf.interval = .95)
# get min and max median values
VASrange <- aggregate(norm_rating~manipulation*VAS*condition*cold_probe, range,
                   data = VASresponse)
names(VASrange)[5] <- 'norm_range'

# merge & save
SUMstats <- merge(SUMstats, VASrange)
write.csv(SUMstats, 'pilotSummary_norms.csv', row.names = FALSE)

##### Plotting #####
# recode conditions
VASresponse <- VASresponse %>%
  mutate(conditionN = recode(conditionN, '1' = 'distal', '2' = 'proximal',
                             '3' = 'caudal', '4' = 'rostral'))
VASresponse$conditionN <- factor(VASresponse$conditionN, 
                                 levels = c("distal", "proximal", "rostral","caudal"))

COLD <- ggplot(VASresponse[VASresponse$VAS == 'cold' ,], 
               aes(conditionN, norm_rating, group = ID, colour = manipulation)) +
  geom_point(size = 2.5, position = position_dodge(.3)) +
  geom_errorbar(aes(ymin=norm_rating-std, ymax=norm_rating+std), width=.2, size = .7,
                position=position_dodge(.3)) +
  scale_color_manual(values = c(blues[3],blues[6])) +
  labs(title = 'Cold perception', x = '', y = 'Cold ratings') +
  theme_classic() + 
  theme(legend.position = 'none')


WARM <- ggplot(VASresponse[VASresponse$VAS == 'warm' ,], 
               aes(conditionN, norm_rating, group = ID, colour = manipulation)) +
  geom_point(size = 2.5, position = position_dodge(.3)) +
  geom_errorbar(aes(ymin=norm_rating-std, ymax=norm_rating+std), width=.2, size = .7,
                position=position_dodge(.3)) +
  scale_color_manual(values = c(orans[3],orans[6])) +
  labs(title = 'Warm perception', x = '', y = 'Warm ratings') +
  theme_classic() + 
  theme(legend.position = 'none')

BURN <- ggplot(VASresponse[VASresponse$VAS == 'burn' ,], 
               aes(conditionN, norm_rating, group = ID, colour = manipulation)) +
  geom_point(size = 2.5, position = position_dodge(.3)) +
  geom_errorbar(aes(ymin=norm_rating-std, ymax=norm_rating+std), width=.2, size = .7,
                position=position_dodge(.3)) +
  scale_color_manual(values = c(purps[4],purps[7])) +
  labs(title = 'Burn perception', x = '', y = 'Burn ratings') +
  theme_classic() + 
  theme(legend.position = 'none')

H1 <- ggarrange(COLD, WARM, BURN,
                ncol = 3, nrow = 1,
                common.legend = TRUE,
                legend = 'bottom')

ggsave('H1plot.png', H1, device = NULL, path = datPath, width = 9, height = 4.5)
   
##### Hypothesis 2 plotting #####
# isolating across
VAS_H2 <- VASresponse[VASresponse$condition == 'across' ,]

# plotting - TGI
ggplot(VAS_H2[VAS_H2$manipulation=='TGI' ,], 
       aes(cold_probe, norm_rating, group = ID, colour = VAS)) +
  geom_point(position = position_dodge(.3)) +
  geom_errorbar(aes(ymin=norm_rating-std, ymax=norm_rating+std), width=.2,
                position=position_dodge(.3)) +
  facet_wrap(~VAS) +
  scale_color_manual(values = c(blues[4],reds[4],purps[5])) +
  labs(title = 'TGI', x = '', y = 'VAS Rating') +
  #lims(y = c(-20,100)) +
  theme_classic() +
  theme(legend.position = 'none')

# non TGI
ggplot(VAS_H2[VAS_H2$manipulation=='CNT' ,], 
       aes(cold_probe, rating, group = ID, colour = VAS)) +
  geom_point(position = position_dodge(.3)) +
  facet_wrap(~VAS) +
  scale_color_manual(values = c(blues[4],reds[4],purps[5])) +
  labs(title = 'Non TGI') +
  theme_classic() +
  theme(legend.position = 'none')

##### Hypothesis 3 plotting #####
VAS_H3 <- VASresponse[VASresponse$condition == 'within' ,]
# plotting - TGI
ggplot(VAS_H3[VAS_H3$manipulation=='TGI' ,], 
       aes(cold_probe, norm_rating, group = ID, colour = ID)) +
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


