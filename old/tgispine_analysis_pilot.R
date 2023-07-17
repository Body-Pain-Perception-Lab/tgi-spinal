## SPINAL TGI ANALYSIS SCRIPT ##
## Created by A.G. Mitchell on 06.04.2022 ##
# Last edited: 08.04.22

##### Loading libraries & data #####
library(dplyr)
library(ggplot2)
library(RColorBrewer)
library(ggpubr)
library(Rmisc)
library(ggpol)

# paths
datPath <- '/Users/au706616/Documents/Experiments/SPINALTGI/TestData/pilot'
# load in relevant csv from pilot data 
filenames <- 'sTGI_compiled-data.csv'
pilot_dat <- read.csv(file.path(datPath,filenames)) 

# summary data - one for each VAS
burn <- aggregate(VASburn~ID*manipulation*cold_probe*condition, median, data = pilot_dat)
cold <- aggregate(VAScold~ID*manipulation*cold_probe*condition, median, data = pilot_dat)
warm <- aggregate(VASwarm~ID*manipulation*cold_probe*condition, median, data = pilot_dat)
# reshape these data-frames
burn$quality <- 'BURN'
burn <- dplyr::rename(burn, VAS = VASburn)
cold$quality <- 'COLD'
cold <- dplyr::rename(cold, VAS = VAScold)
warm$quality <- 'WARM'
warm <- dplyr::rename(warm, VAS = VASwarm)

# then bind!
all_dat <- rbind(burn, warm, cold)
# recode levels for plotting
all_dat$quality <- factor(all_dat$quality)
all_dat$condition <- factor(all_dat$condition)
all_dat$manipulation <- factor(all_dat$manipulation)
all_dat$cold_probe <- factor(all_dat$cold_probe)

# extract medians for all
pilot_sum <- summarySEwithin(data = all_dat, measurevar = 'VAS', 
                             withinvars = c('quality', 'cold_probe', 'condition', 'manipulation'),
                             na.rm = TRUE)

##### PLOTTING ######

# Define colors
reds <- brewer.pal(8, "Reds")
redpu <- brewer.pal(8, "RdPu")
orans <- brewer.pal(8, "Oranges")
blues <- brewer.pal(8, "Blues")
purps <- brewer.pal(8, "Purples")
green <- brewer.pal(8, "YlGn")
blgrn <- brewer.pal(8, "BuGn")

##### Hypothesis 1: median values #####
# average so one value within and across

# reorganise all_dat levels
all_dat$quality <- factor(all_dat$quality, levels = c('COLD','WARM','BURN'))
all_dat$cold_probe <- factor(all_dat$cold_probe, 
                             levels = c('distal','proximal','rostral','caudal'))

ggplot(all_dat) +
  geom_boxplot(data = all_dat %>% filter(manipulation == 'CNT'),
    aes(cold_probe, VAS, colour = quality, fill = quality)) +
  facet_wrap(~quality) +
  scale_color_manual(values = c(blues[5],reds[5],purps[5])) +
  scale_fill_manual(values = c(blues[1],reds[1],purps[1])) +
  ylim(0,100) +
  labs(title = 'No TGI', y = 'VAS Rating', x= '') +
  theme_classic() +
  theme(legend.position = 'none',
        axis.text = element_text(size = 10),
        axis.title = element_text(size = 12),
        strip.text = element_text(size = 11),
        title = element_text(size = 12)) -> nTGIplot 

ggplot(all_dat) +
  geom_boxplot(data = all_dat %>% filter(manipulation == 'TGI'),
               aes(cold_probe, VAS, colour = quality, fill = quality)) +
  facet_wrap(~quality) +
  scale_color_manual(values = c(blues[8],reds[8],purps[8])) +
  scale_fill_manual(values = c(blues[2],reds[2],purps[2])) +
  ylim(0,100) +
  labs(title = 'TGI', y = 'VAS Rating', x= 'Location of Cold Probe') +
  theme_classic() +
  theme(legend.position = 'none',
        axis.text = element_text(size = 10),
        axis.title = element_text(size = 12),
        strip.text = element_text(size = 11),
        title = element_text(size = 12)) -> TGIplot 

H1plot <- ggarrange(nTGIplot, TGIplot,
                    ncol = 1, nrow = 2)

ggsave('PILOT_plot.png', H1plot, device = NULL, path = datPath,
       width = 8, height = 8, dpi = 600)

   
##### Hypothesis 2 plotting #####
# isolating across
VAS_H2 <- VASresponse[VASresponse$condition == 'within' ,]

# plotting - TGI
H2 <- ggplot(VAS_H2, aes(cold_probe, norm_rating, group = ID, colour = VAS)) +
  geom_point(data = VAS_H2 %>% 
               filter(manipulation == 'TGI'), size = 2.5, position = position_dodge(.3)) +
  geom_line(data = VAS_H2 %>% 
              filter(manipulation == 'TGI'), aes(group = ID), position = position_dodge(.3)) +
  geom_point(data = VAS_H2 %>% 
               filter(manipulation == 'CNT'), size = 2.5, position = position_dodge(.3),
             alpha = .5) +
  geom_line(data = VAS_H2 %>% 
              filter(manipulation == 'CNT'), aes(group = ID), position = position_dodge(.3),
            alpha = .5) +
  facet_wrap(~VAS) +
  scale_color_manual(values = c(blues[4],reds[4],purps[5])) +
  labs(title = 'Within Dermatome', x = '', y = 'VAS Rating') +
  #lims(y = c(-20,100)) +
  theme_classic() +
  theme(legend.position = 'none')

##### Hypothesis 3 plotting #####
# isolating across
VAS_H3 <- VASresponse[VASresponse$condition == 'across' ,]

# plotting - TGI
H3 <- ggplot(VAS_H3, aes(cold_probe, norm_rating, group = ID, colour = VAS)) +
  geom_point(data = VAS_H3 %>% 
               filter(manipulation == 'TGI'), size = 2.5, position = position_dodge(.3)) +
  geom_line(data = VAS_H3 %>% 
              filter(manipulation == 'TGI'), aes(group = ID), position = position_dodge(.3)) +
  geom_point(data = VAS_H3 %>% 
               filter(manipulation == 'CNT'), size = 2.5, position = position_dodge(.3),
             alpha = .5) +
  geom_line(data = VAS_H3 %>% 
              filter(manipulation == 'CNT'), aes(group = ID), position = position_dodge(.3),
            alpha = .5) +
  facet_wrap(~VAS) +
  scale_color_manual(values = c(blues[4],reds[4],purps[5])) +
  labs(title = 'Across Dermatome', x = '', y = 'VAS Rating') +
  #lims(y = c(-20,100)) +
  theme_classic() +
  theme(legend.position = 'none')


