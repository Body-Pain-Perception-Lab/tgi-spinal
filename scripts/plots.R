
make_plot1 = function(vas_h1_diff,h1_diff_sum, title){
  
  # now plot the difference
  plot = data = vas_h1_diff %>% ggplot(aes(colour = quality)) +
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
    labs(title = paste0(title),
         y = 'Within - Across VAS Ratings', x = NULL) +
    theme_classic() +
    theme(legend.position = 'none')+coord_cartesian(ylim = c(-30,30))+scale_y_continuous(breaks = scales::pretty_breaks(n = 5)) 
  
  plot
  return(plot)
  
}


plot1 = function(include_zero = T){
  
  # experiment 1 file
  
  experiment1 = prep_data(file.path("data", 'STGI_exp1_compiled-data.csv'), include_zero = include_zero)
  vas_h1_diff_exp1 = experiment1$vas_h1_diff
  h1_diff_sum_exp1 = experiment1$h1_diff_sum
  
  
  h1_diff_plot_exp1 = make_plot1(vas_h1_diff = vas_h1_diff_exp1,
                                 h1_diff_sum = h1_diff_sum_exp1,
                                 title = "Reference: Cold Thermode")
  
  
  # experiment 2 file
  
  experiment2 = prep_data(file.path("data", 'STGI_exp2_compiled-data.csv'), include_zero = include_zero)
  vas_h1_diff_exp2 = experiment2$vas_h1_diff
  h1_diff_sum_exp2 = experiment2$h1_diff_sum
  
  h1_diff_plot_exp2 = make_plot1(vas_h1_diff = vas_h1_diff_exp2,
                                 h1_diff_sum = h1_diff_sum_exp2,
                                 title = "Reference: Warm Thermode")+
                                theme(axis.text.y=element_blank(),axis.ticks.y=element_blank(),axis.title.y=element_blank())
  
  plot1 = h1_diff_plot_exp1+h1_diff_plot_exp2+plot_annotation(tag_levels = "A")
  
  plot1
  return(plot1)
}

make_plot2 = function(vas_h2_diff,h2_diff_sum,title){
  
  
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
    labs(title = title,
         y = 'Proximal - Distal VAS Ratings', x = NULL) +
    facet_wrap(~quality) +
    theme_classic() +
    theme(legend.position = 'none')+coord_cartesian(ylim = c(-60,60))+scale_y_continuous(breaks = scales::pretty_breaks(n = 5)) 
  
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
    labs(title = title,
         y = 'Caudal - Rostral VAS Ratings', x = NULL) +
    facet_wrap(~quality) +
    theme_classic() +
    theme(legend.position = 'none')+coord_cartesian(ylim = c(-60,60))+scale_y_continuous(breaks = scales::pretty_breaks(n = 5)) 
  
  experiment1_h2 = h2_diff_within / h2_diff_across
  return(list(experiment1_h2,h2_diff_within,h2_diff_across))
}

plot2 = function(include_zero = T){
  
  # experiment 1 file
  experiment1 = prep_data(file.path("data", 'STGI_exp1_compiled-data.csv'), include_zero = include_zero)
  vas_h2_diff_exp1 = experiment1$vas_h2_diff
  h2_diff_sum_exp1 = experiment1$h2_diff_sum
  
  
  experiment1_h2 = make_plot2(vas_h2_diff_exp1,h2_diff_sum_exp1, title = "Reference: Cold Thermode")[[1]]+plot_annotation(tag_levels = list("A","B"))
  
  
  # experiment 2 file
  experiment1 = prep_data(file.path("data", 'STGI_exp2_compiled-data.csv'), include_zero = include_zero)
  vas_h2_diff_exp2 = experiment1$vas_h2_diff
  h2_diff_sum_exp2 = experiment1$h2_diff_sum
  
  experiment2_h2 = make_plot2(vas_h2_diff_exp2,h2_diff_sum_exp2, title = "Reference: Warm Thermode")[[1]]+plot_annotation(tag_levels = list(c("C","D")))
  
  
  #combine plots
  plot2 = wrap_elements(wrap_elements(experiment1_h2) | wrap_elements(experiment2_h2))
  
  plot2
  
  return(plot2)
}


plot2_3 = function(include_zero = T){
  
  # experiment 1 file
  experiment1 = prep_data(file.path("data", 'STGI_exp1_compiled-data.csv'), include_zero = include_zero)
  vas_h2_diff_exp1 = experiment1$vas_h2_diff
  h2_diff_sum_exp1 = experiment1$h2_diff_sum
  
  
  experiment1_h2 = make_plot2(vas_h2_diff_exp1,h2_diff_sum_exp1, title = "Reference: Cold Thermode")
  
  
  # experiment 2 file
  experiment1 = prep_data(file.path("data", 'STGI_exp2_compiled-data.csv'), include_zero = include_zero)
  vas_h2_diff_exp2 = experiment1$vas_h2_diff
  h2_diff_sum_exp2 = experiment1$h2_diff_sum
  
  experiment2_h2_warm = make_plot2(vas_h2_diff_exp2,h2_diff_sum_exp2, title = "Reference: Warm Thermode")
  
  plot2 = experiment1_h2[[2]]+(experiment2_h2_warm[[2]]+theme(axis.text.y=element_blank(),axis.ticks.y=element_blank(),axis.title.y=element_blank()))+plot_annotation(tag_levels = list("A","B"))
  plot3 = experiment1_h2[[3]]+(experiment2_h2_warm[[3]]+theme(axis.text.y=element_blank(),axis.ticks.y=element_blank(),axis.title.y=element_blank()))+plot_annotation(tag_levels = list("A","B"))
  
  
  return(list(plot2,plot3))
}

