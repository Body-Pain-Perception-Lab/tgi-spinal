## SPINAL TGI ANALYSIS SCRIPT ##
## Created by A.G. Mitchell on 06.04.2022 ##
# Last edited: 08.04.22

##### Loading libraries & data #####
library(dplyr)
library(ggplot2)
library(RColorBrewer)
library(ggpubr)

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
df_plot$condition <- factor(df_plot$condition, 
                      labels = c("ACR", "WIN"))

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
DE <- df_plot[df_plot$ID == 'D001' ,]

# AGM - TGI
P1TGI <- ggplot(AGM[AGM$manipulation=='TGI' ,], aes(group = trial_n, colour = cold_probe)) +
  geom_point(aes(condition, rating), size = 1.5, position = position_dodge(.2)) +
  facet_wrap(~VAS) +
  scale_colour_manual(values = colours) +
  lims(y = c(0, 100)) +
  theme_classic() +
  labs(title = 'TGI', x = 'Condition', y = '') +
  theme(legend.position = 'none',
        legend.title = element_blank())

# AGM - nonTGI
P1NTGI <- ggplot(AGM[AGM$manipulation=='CNT' ,], aes(group = trial_n, colour = cold_probe)) +
  geom_point(aes(condition, rating), size = 1.5, position = position_dodge(.2)) +
  facet_wrap(~VAS) +
  scale_colour_manual(values = colours) +
  theme_classic() +
  lims(y = c(0, 100)) +
  labs(title = 'Non TGI', x = 'Condition', y = 'VAS Rating') +
  theme(legend.position = 'bottom',
        legend.title = element_blank())

P1 <- ggarrange(P1NTGI, P1TGI,
                ncol = 1, nrow = 2,
                common.legend = TRUE,
                legend = 'bottom')
ggsave('P1plot.png', P1, device = NULL, path = datPath, width = 5, height = 8)

# CEA - TGI
P2TGI <- ggplot(CEA[CEA$manipulation=='TGI' ,], aes(group = trial_n, colour = cold_probe)) +
  geom_point(aes(condition, rating), size = 1.5, position = position_dodge(.2)) +
  facet_wrap(~VAS) +
  scale_colour_manual(values = colours) +
  lims(y = c(0, 100)) +
  theme_classic() +
  labs(title = 'TGI', x = 'Condition', y = '') +
  theme(legend.position = 'none',
        legend.title = element_blank())

# CEA - nonTGI
P2NTGI <- ggplot(CEA[CEA$manipulation=='CNT' ,], aes(group = trial_n, colour = cold_probe)) +
  geom_point(aes(condition, rating), size = 1.5, position = position_dodge(.2)) +
  facet_wrap(~VAS) +
  scale_colour_manual(values = colours) +
  theme_classic() +
  lims(y = c(0, 100)) +
  labs(title = 'Non TGI', x = 'Condition', y = 'VAS Rating') +
  theme(legend.position = 'bottom',
        legend.title = element_blank())

P2 <- ggarrange(P2NTGI, P2TGI,
                ncol = 1, nrow = 2,
                common.legend = TRUE,
                legend = 'bottom')
ggsave('P2plot.png', P2, device = NULL, path = datPath, width = 5, height = 8)

# DE - TGI
P3TGI <- ggplot(DE[DE$manipulation=='TGI' ,], aes(group = trial_n, colour = cold_probe)) +
  geom_point(aes(condition, rating), size = 1.5, position = position_dodge(.2)) +
  facet_wrap(~VAS) +
  scale_colour_manual(values = colours) +
  lims(y = c(0, 100)) +
  theme_classic() +
  labs(title = 'TGI', x = 'Condition', y = '') +
  theme(legend.position = 'none',
        legend.title = element_blank())

# CEA - nonTGI
P3NTGI <- ggplot(DE[DE$manipulation=='CNT' ,], aes(group = trial_n, colour = cold_probe)) +
  geom_point(aes(condition, rating), size = 1.5, position = position_dodge(.2)) +
  facet_wrap(~VAS) +
  scale_colour_manual(values = colours) +
  theme_classic() +
  lims(y = c(0, 100)) +
  labs(title = 'Non TGI', x = 'Condition', y = 'VAS Rating') +
  theme(legend.position = 'bottom',
        legend.title = element_blank())

P3 <- ggarrange(P3NTGI, P3TGI,
                ncol = 1, nrow = 2,
                common.legend = TRUE,
                legend = 'bottom')
ggsave('P3plot.png', P3, device = NULL, path = datPath, width = 5, height = 8)


##### Summary statistics & plots #####
# get mean VAS responses for each condition
VASresponse <- aggregate(rating~ID*VAS*manipulation*condition*cold_probe*dermatome, 
                         median, data = df_plot)

# H1: the effect of dermatome
VAS_H1 <- aggregate(rating~ID*VAS*manipulation*condition, 
                    mean, data = VASresponse)
VAS_H1_SD <- aggregate(rating~ID*VAS*manipulation*condition, 
                       sd, data = VASresponse)
names(VAS_H1_SD)[5] <- 'SD'
VAS_H1 <- merge(VAS_H1, VAS_H1_SD)

# plotting - TGI
H1TGI <- ggplot(VAS_H1[VAS_H1$manipulation=='TGI' ,], 
       aes(condition, rating, group = ID, colour = VAS)) +
  geom_point(size = 2, position = position_dodge(.3)) +
  geom_errorbar(aes(ymin=rating-SD, ymax=rating+SD), width=.2,
                position=position_dodge(.3)) +
  facet_wrap(~VAS) +
  scale_color_manual(values = c(blues[4],reds[4],purps[5])) +
  labs(title = 'TGI', x = 'Condition', y = 'VAS Rating') +
  lims(y = c(-5,75)) +
  theme_classic() + 
  theme(legend.position = 'none')


# non TGI
H1NTGI <- ggplot(VAS_H1[VAS_H1$manipulation=='CNT' ,], 
       aes(condition, rating, group = ID, colour = VAS)) +
  geom_point(size = 2, position = position_dodge(.3)) +
  facet_wrap(~VAS) +
  geom_errorbar(aes(ymin=rating-SD, ymax=rating+SD), width=.2,
                  position=position_dodge(.3)) +
  scale_color_manual(values = c(blues[4],reds[4],purps[5])) +
  labs(title = 'Non TGI', x = '', y = 'VAS Rating') +
  lims(y = c(-5,75)) +
  theme_classic() + 
  theme(legend.position = 'none')

H1 <- ggarrange(H1NTGI, H1TGI,
                ncol = 1, nrow = 2)

ggsave('H1plot.png', H1, device = NULL, path = datPath, width = 5, height = 8)
   
# H2: across dermatome
VASSD <- aggregate(rating~ID*VAS*manipulation*condition*cold_probe*dermatome, 
                         sd, data = df_plot)
names(VASSD)[7] <- 'SD'
VASresponse <- merge(VASresponse, VASSD)
# isolating across
VAS_H2 <- VASresponse[VASresponse$condition == 'ACR' ,]

# plotting - TGI
ggplot(VAS_H2[VAS_H2$manipulation=='TGI' ,], 
       aes(cold_probe, rating, group = ID, colour = VAS)) +
  geom_point(position = position_dodge(.3)) +
  geom_errorbar(aes(ymin=rating-SD, ymax=rating+SD), width=.2,
                position=position_dodge(.3)) +
  facet_wrap(~VAS) +
  scale_color_manual(values = c(blues[4],reds[4],purps[5])) +
  labs(title = 'TGI', x = '', y = 'VAS Rating') +
  lims(y = c(-20,100)) +
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

# H3: within dermatome
VAS_H3 <- VASresponse[VASresponse$condition == 'WIN' ,]
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


