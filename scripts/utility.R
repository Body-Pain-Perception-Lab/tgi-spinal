#convinient function to make p-values to desired format
make_pvalue = function(p_value){
  if (p_value > 0.05){
    p_value = round(p_value,2)
    p = paste("p = ",p_value)
  }
  if (p_value < 0.05){
    p = "p < .05 "
  }
  if(p_value < 0.01){
    p = "p < .01"
  }
  if(p_value < 0.001){
    p = "p < .001"
  }
  if(p_value < 0.0001){
    p = "p < .0001"
  }
  return(p)
}


#get summary statistics from a generalized linear mixed effects model.
#Arguments: model is the model to get statistics on. Coefficients is the index of the coefficients when using summary(model) (that is excluding the intercept and until the coefficients arguemnt),
#round is the rounding of the statistics.
summary_stat = function(model, coefficients, round){
  a = summary(model)
  coef = array(NA, coefficients)
  std = array(NA, coefficients)
  stat = array(NA, coefficients)
  p = array(NA, coefficients)
  
  for (i in 1:coefficients){
    coef[i] = a$coefficients$cond[1+i,1]
    std[i] = a$coefficients$cond[1+i,2]
    stat[i] = a$coefficients$cond[1+i,3]
    p[i] = a$coefficients$cond[1+i,4]
  }
  return(list(beta = round(coef,round),std = round(std,round),stat = round(stat,round),p = p))
  
}











# first colours
blue <- brewer.pal(8, "Blues")
grey <- brewer.pal(8, "Greys")
purp <- brewer.pal(8, "Purples")
oran <- brewer.pal(8, "Oranges")
gren <- brewer.pal(8, "Greens")




prep_data = function(file){
  
  if (file.exists(file)){
    df_res <- read.csv(file)
  } else {
    print('Data file does not exist, check data is in current directory. 
          If not, run tgi-compiler.Rmd')
  }
  # Calculate median burning rating for all participants
  # TGI trials only
  # Then flag how many are not sig > 0
  df_med <- aggregate(VASburn~ID*manipulation*cold_probe*trial_type, median, data = df_res)
  tgi <-  df_med %>% 
    filter(manipulation == 'TGI')
  cnt <-  df_med %>% 
    filter(manipulation == 'CNT')
  
  # identify test results where pvalue is < .05
  tgi$ID <- as.factor(tgi$ID)
  i = 0
  test = data.frame(matrix(nrow = 40, ncol = 3))
  colnames(test) <- c('ID','pval','responder')
  
  for (id in levels(tgi$ID)){
    i = i+1
    tmp1 <- tgi[tgi$ID == id ,]
    test$ID[i] <- id
    test$pval[i] <- (t.test(tmp1$VASburn, mu = 0, alternative = 'greater'))$p.value
    test$responder[i] <- isTRUE(test$pval[i] < .05)
  }
  
  # combine responder logic with main data-frame
  test$responder <- ifelse(test$responder == TRUE, 1, 0)
  test <- test[, c(1,3)]
  df_res <- merge(df_res, test, by = 'ID')
  
  # count the number of false responses
  nNONRESP <- sum(test$responder == FALSE)
  # print
  print(paste0('Non responders: ', nNONRESP, '/', length(test$ID)))
  
  # Reorganise data-frame 
  # pivot longer the VAS response by each quality of sensation
  # do this for both RT and VAS
  df_long <- df_res %>% 
    pivot_longer(cols = c(VASinit, VASburn, VASwarm, VAScold),
                 names_to = 'quality',
                 values_to = 'VAS')
  df_long2 <- df_res %>% 
    pivot_longer(cols = c(RTinit, RTburn, RTwarm, RTcold),
                 names_to = 'quality',
                 values_to = 'RT')
  
  # remove the VAS & RT from quality column
  df_long$quality <- substr(df_long$quality, 4, 7)
  df_long2$quality <- substr(df_long2$quality, 3, 6)
  
  # remove columns from both then merge
  df_long <- df_long %>% 
    select(-c(coolTemp, warmTemp, Order, Manipulation.first))
  df_long2 <- df_long2 %>% 
    select(-c(coolTemp, warmTemp, Order, Manipulation.first))
  
  df_long <- merge(df_long, df_long2)
  
  # then remove NaNs
  df_long <- df_long %>% filter(!is.na(VAS))
  # remove the initial trials - not important for now
  init_burn <- filter(df_long, quality == 'init')
  all_vas <- filter(df_long, quality != 'init')
  
  # calculate means
  vas_meds <- aggregate(VAS ~ quality*manipulation*condition*cold_probe*ID, 
                        median, data = all_vas)
  vas_h1 <- aggregate(VAS ~ quality*manipulation*condition*ID, mean, data = vas_meds)
  # change name of manipulation
  vas_h1$manipulation <- factor(vas_h1$manipulation,
                                labels = c('Non-TGI', 'TGI'))
  # summary means for h1
  h1_sum <- summarySEwithin(data = vas_h1, measurevar = 'VAS',
                            withinvars = c('manipulation', 'quality', 'condition'))
  
  vas_h1_diff <- vas_h1 %>% 
    pivot_wider(names_from = condition, values_from = VAS) %>% 
    mutate(difference = within - across)
  # recode quality
  vas_h1_diff$quality <- factor(vas_h1_diff$quality,
                                levels = c('cold', 'warm', 'burn'))
  
  # summary statistics
  h1_diff_sum <- summarySEwithin(data = vas_h1_diff, measurevar = 'difference',
                                 withinvars = c('manipulation', 'quality'))
  
  
  
  #Hypothesis 2 a & b: relative location of warm and cold
  
  # Change name of manipulation
  vas_meds$manipulation <- factor(vas_meds$manipulation, labels = c('Non-TGI', 'TGI'))
  h2_sum <- aggregate(VAS~quality*manipulation*cold_probe, median, data = vas_meds)
  
  # organise data for plotting
  vas_meds$cold_probe <- factor(vas_meds$cold_probe, levels = 
                                  c('proximal', 'distal', 'rostral', 'caudal'))
  h2_sum$cold_probe <- factor(h2_sum$cold_probe, levels = 
                                c('proximal', 'distal', 'rostral', 'caudal'))
  # recoding cold probe location so can jitter
  vas_meds$cold_code <- factor(vas_meds$cold_probe, labels = 
                                 c(1,2,3,4))
  h2_sum$cold_code <- factor(h2_sum$cold_probe, labels = 
                               c(1,2,3,4))
  # creating jitter
  vas_meds$xj <- jitter(as.numeric(vas_meds$cold_code), amount = .05)
  
  # recode cold_location and condition to reduce levels in regression
  vas_meds$cold_cond[vas_meds$cold_probe == 'distal'] <- 'dist_rost' 
  vas_meds$cold_cond[vas_meds$cold_probe == 'rostral'] <- 'dist_rost' 
  vas_meds$cold_cond[vas_meds$cold_probe == 'proximal'] <- 'prox_caud' 
  vas_meds$cold_cond[vas_meds$cold_probe == 'caudal'] <- 'prox_caud'
  
  # then pivot wider and calculate difference
  vas_h2_diff <- vas_meds %>% 
    select(-c(cold_code, xj, cold_probe)) %>% 
    pivot_wider(id_cols = c(ID, quality, manipulation, condition), 
                names_from = cold_cond, values_from = VAS) %>% 
    mutate(difference = prox_caud - dist_rost)
  # recode quality
  vas_h2_diff$quality <- factor(vas_h2_diff$quality,
                                levels = c('cold', 'warm', 'burn'))
  # summary statistics
  h2_diff_sum <- summarySEwithin(data = vas_h2_diff, measurevar = 'difference',
                                 withinvars = c('manipulation', 'quality', 'condition'))
  
  
  # recode cold_location and condition to reduce levels in regression
  df_long$cold_cond[df_long$cold_probe == 'distal'] <- 'dist_rostr' 
  df_long$cold_cond[df_long$cold_probe == 'rostral'] <- 'dist_rostr' 
  df_long$cold_cond[df_long$cold_probe == 'proximal'] <- 'prox_caud' 
  df_long$cold_cond[df_long$cold_probe == 'caudal'] <- 'prox_caud' 
  
  # to run zero inflated regressions need to make sure no values = 100, 
  # as cannot model them, so simply minus a very small fraction from those values
  df_long$beta <- ifelse(df_long$VAS==100, df_long$beta-0.0001, df_long$beta <- df_long$VAS)
  df_long$beta <- df_long$beta/100
  
  # transform variables into proportions (aka divide by 100), this makes the effect size estimates more logical
  #df_long$VAS <- df_long$VAS/100
  df_long$ID <- factor(df_long$ID)
  
  
  return(list(all_vas = all_vas,
              init_burn = init_burn,
              vas_h1_diff = vas_h1_diff,
              h1_diff_sum = h1_diff_sum,
              vas_h2_diff = vas_h2_diff,
              h2_diff_sum = h2_diff_sum,
              df_long = df_long))
}


make_plot1 = function(vas_h1_diff,h1_diff_sum, exp){
  
  # now plot the difference
  plot = ggplot(data = vas_h1_diff, aes(colour = quality)) +
    geom_hline(yintercept = 0, colour = 'grey50') +
    geom_point(aes(manipulation, difference, group = ID), position = position_dodge(.2),
               alpha = .5) +
    geom_point(data = h1_diff_sum, aes(manipulation, difference), colour = 'grey15',
               fill = 'grey15',
               shape = 21, size = 3) +
    geom_errorbar(data = h1_diff_sum, aes(manipulation, ymin = difference-ci,
                                          ymax = difference+ci), 
                  width = .1, size = .7, colour = 'grey15') +
    facet_wrap(~quality) +
    scale_colour_manual(values = c(blue[5], oran[5], purp[5])) +
    labs(title = paste0('Experiment ',exp),
         y = 'Within - Across VAS Ratings', x = NULL) +
    theme_classic() +
    theme(legend.position = 'none')+coord_cartesian(ylim = c(-30,30)) 
  
  return(plot)
  
}


plot1 = function(){
  
  # experiment 1 file
  
  experiment1 = prep_data(file.path("data", 'STGI_exp1_compiled-data.csv'))
  vas_h1_diff_exp1 = experiment1$vas_h1_diff
  h1_diff_sum_exp1 = experiment1$h1_diff_sum
  
  
  h1_diff_plot_exp1 = make_plot1(vas_h1_diff = vas_h1_diff_exp1,
                                 h1_diff_sum = h1_diff_sum_exp1,
                                 exp = "1")
  
  
  # experiment 2 file
  
  experiment2 = prep_data(file.path("data", 'STGI_exp2_compiled-data.csv'))
  vas_h1_diff_exp2 = experiment2$vas_h1_diff
  h1_diff_sum_exp2 = experiment2$h1_diff_sum
  
  h1_diff_plot_exp2 = make_plot1(vas_h1_diff = vas_h1_diff_exp2,
                                 h1_diff_sum = h1_diff_sum_exp2,
                                 exp = "2")
  
  plot1 = h1_diff_plot_exp1+h1_diff_plot_exp2+plot_annotation('Hypothesis 1: Segmental Distance',theme=theme(plot.title=element_text(hjust=0.5)), tag_levels = "A")
  return(plot1)
}

make_plot2 = function(vas_h2_diff,h2_diff_sum){
  h2_diff_within = ggplot(data = vas_h2_diff %>% 
                            filter(condition == 'within'), 
                          aes(manipulation, difference, colour = quality)) +
    geom_hline(yintercept = 0) +
    geom_point(aes(group = ID), position = position_dodge(.2), alpha = .5) +
    geom_point(data = h2_diff_sum %>% 
                 filter(condition == 'within'), 
               aes(manipulation, difference), colour = 'grey15',
               fill = 'grey15',
               shape = 21, size = 3) +
    geom_errorbar(data = h2_diff_sum %>% 
                    filter(condition == 'within'), 
                  aes(manipulation, ymin = difference-ci, ymax = difference+ci),
                  width = .1, size = .7, colour = 'grey15') +
    scale_colour_manual(values = c(blue[5], oran[5], purp[5])) +
    labs(title = 'Within: Proximal vs. Distal',
         y = 'Proximal - Distal VAS Ratings', x = NULL) +
    facet_wrap(~quality) +
    theme_classic() +
    theme(legend.position = 'none')+coord_cartesian(ylim = c(-60,60))
  
  # plot the differences - across
  h2_diff_across = ggplot(data = vas_h2_diff %>% 
                            filter(condition == 'across'), 
                          aes(manipulation, difference, colour = quality)) +
    geom_hline(yintercept = 0) +
    geom_point(aes(group = ID), position = position_dodge(.2), alpha = .5) +
    geom_point(data = h2_diff_sum %>% 
                 filter(condition == 'across'), 
               aes(manipulation, difference), colour = 'grey15',
               fill = 'grey15',
               shape = 21, size = 3) +
    geom_errorbar(data = h2_diff_sum %>% 
                    filter(condition == 'across'), 
                  aes(manipulation, ymin = difference-ci, ymax = difference+ci),
                  width = .1, size = .7, colour = 'grey15') +
    scale_colour_manual(values = c(blue[5], oran[5], purp[5])) +
    labs(title = 'Across: Rostral vs. Caudal',
         y = 'Caudal - Rostral VAS Ratings', x = NULL) +
    facet_wrap(~quality) +
    theme_classic() +
    theme(legend.position = 'none')+coord_cartesian(ylim = c(-60,60))
  return(experiment1_h2 = h2_diff_within / h2_diff_across)
}

plot2 = function(){
  
  # experiment 1 file
  experiment1 = prep_data(file.path("data", 'STGI_exp1_compiled-data.csv'))
  vas_h2_diff_exp1 = experiment1$vas_h2_diff
  h2_diff_sum_exp1 = experiment1$h2_diff_sum
  
  
  experiment1_h2 = make_plot2(vas_h2_diff_exp1,h2_diff_sum_exp1)+plot_annotation('Experiment 1',theme=theme(plot.title=element_text(hjust=0.5)), tag_levels = list("A","B"))
  
  
  
  
  
  # experiment 2 file
  experiment1 = prep_data(file.path("data", 'STGI_exp2_compiled-data.csv'))
  vas_h2_diff_exp2 = experiment1$vas_h2_diff
  h2_diff_sum_exp2 = experiment1$h2_diff_sum
  
  experiment2_h2 = make_plot2(vas_h2_diff_exp2,h2_diff_sum_exp2)+plot_annotation('Experiment 2',theme=theme(plot.title=element_text(hjust=0.5)), tag_levels = list(c("C","D")))
  
  
  
  #combine plots
  plot2 = wrap_elements(wrap_elements(experiment1_h2) | wrap_elements(experiment2_h2))+ plot_annotation('Hypothesis 2: XXXXXXXXXX',theme=theme(plot.title=element_text(hjust=0.5)))
  
  
  return(plot2)
}



