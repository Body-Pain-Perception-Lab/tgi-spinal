make_sPlot = function(vas_meds, h2_sum, VAS_type, title, l_pos){
  
  # plot all data, with 0s
  plot = ggplot(data = vas_meds %>% 
                  filter(quality == VAS_type),
                mapping = aes(x = xj, y = VAS, colour = manipulation, fill = manipulation)) +
    geom_boxjitter(data = vas_meds %>% 
                     filter(quality == VAS_type, cold_probe == 'proximal', manipulation == 'Non-TGI'),
                   position = position_nudge(x = -.1), width = .2,
                   errorbar.length = .2, jitter.shape = 21, jitter.size = 1.5,
                   outlier.shape = NA, errorbar.draw = TRUE, lwd = 0.7) +
    geom_boxjitter(data = vas_meds %>% 
                     filter(quality == VAS_type, cold_probe == 'proximal', manipulation == 'TGI'),
                   position = position_nudge(x = .1), width = .2,
                   errorbar.length = .2, jitter.shape = 21, jitter.size = 1.5,
                   outlier.shape = NA, errorbar.draw = TRUE, lwd = 0.7) +
    geom_boxjitter(data = vas_meds %>% 
                     filter(quality == VAS_type, cold_probe == 'distal', manipulation == 'Non-TGI'),
                   position = position_nudge(x = -.1), width = .2,
                   errorbar.length = .2, jitter.shape = 21, jitter.size = 1.5,
                   outlier.shape = NA, errorbar.draw = TRUE, lwd = 0.7) +
    geom_boxjitter(data = vas_meds %>% 
                     filter(quality == VAS_type, cold_probe == 'distal', manipulation == 'TGI'),
                   position = position_nudge(x = .1), width = .2,
                   errorbar.length = .2, jitter.shape = 21, jitter.size = 1.5,
                   outlier.shape = NA, errorbar.draw = TRUE, lwd = 0.7) +
    geom_boxjitter(data = vas_meds %>% 
                     filter(quality == VAS_type, cold_probe == 'rostral', manipulation == 'Non-TGI'),
                   position = position_nudge(x = -.1), width = .2,
                   errorbar.length = .2, jitter.shape = 21, jitter.size = 1.5,
                   outlier.shape = NA, errorbar.draw = TRUE, lwd = 0.7) +
    geom_boxjitter(data = vas_meds %>% 
                     filter(quality == VAS_type, cold_probe == 'rostral', manipulation == 'TGI'),
                   position = position_nudge(x = .1), width = .2,
                   errorbar.length = .2, jitter.shape = 21, jitter.size = 1.5,
                   outlier.shape = NA, errorbar.draw = TRUE, lwd = 0.7) +
    geom_boxjitter(data = vas_meds %>% 
                     filter(quality == VAS_type, cold_probe == 'caudal', manipulation == 'Non-TGI'),
                   position = position_nudge(x = -.1), width = .2,
                   errorbar.length = .2, jitter.shape = 21, jitter.size = 1.5,
                   outlier.shape = NA, errorbar.draw = TRUE, lwd = 0.7) +
    geom_boxjitter(data = vas_meds %>% 
                     filter(quality == VAS_type, cold_probe == 'caudal', manipulation == 'TGI'),
                   position = position_nudge(x = .1), width = .2,
                   errorbar.length = .2, jitter.shape = 21, jitter.size = 1.5,
                   outlier.shape = NA, errorbar.draw = TRUE, lwd = 0.7) +
    geom_line(data = h2_sum %>% 
                filter(quality == VAS_type, manipulation == 'Non-TGI'),
              aes(as.numeric(cold_code), VAS), 
              position = position_nudge(x = -.1)) + 
    geom_line(data = h2_sum %>% 
                filter(quality == VAS_type, manipulation == 'TGI'),
              aes(as.numeric(cold_code), VAS), 
              position = position_nudge(x = .1)) +
    scale_x_continuous(breaks = c(1,2,3,4), labels = c('proximal','distal','rostral','caudal')) +
    labs(title = title, x = NULL, 
         y = 'VAS Rating (0-100)') +
    ylim(-0.5,100) +
    theme_classic() +
    theme(legend.position = l_pos,
          legend.title = element_blank(),
          axis.text = element_text(size = 11),
          axis.title = element_text(size = 12))
  
  
  plot
  return(plot)
  
}



# make figure 2
f2_plot = function(include_zero = T){
  # first experiment 1
  experiment1 = prep_data(file.path("data", 'STGI_exp1_compiled-data.csv'), include_zero = include_zero)
  vas_meds = experiment1$vas_meds
  h2_sum = experiment1$h2_sum
  main_title = 'Reference: Cold Thermode'
  
  
  s_plotA = make_sPlot(vas_meds = vas_meds, h2_sum = h2_sum, 
                       VAS_type = 'cold', title = 'Cold ratings', l_pos = 'none') +
    scale_colour_manual(values = c(blue[5], blue[7])) +
    scale_fill_manual(values = c(blue[2], blue[4])) +
    theme(title = element_text(size = 10))
  
  s_plotB = make_sPlot(vas_meds = vas_meds, h2_sum = h2_sum, 
                       VAS_type = 'warm', title = 'Warm ratings', l_pos = 'none') +
    scale_colour_manual(values = c(oran[5], oran[7])) +
    scale_fill_manual(values = c(oran[2], oran[4])) +
    theme(title = element_text(size = 10))
  
  s_plotC = make_sPlot(vas_meds = vas_meds, h2_sum = h2_sum, 
                       VAS_type = 'burn', title = 'Burning ratings', l_pos = 'none') +
    scale_colour_manual(values = c(purp[5], purp[7])) +
    scale_fill_manual(values = c(purp[2], purp[4])) +
    theme(title = element_text(size = 10))
  
  s_plot_1 = ggarrange(s_plotA, s_plotB, s_plotC,
                       nrow = 3, ncol = 1,
                       labels = c('A','B','C')) +
    plot_annotation(title = main_title)
  
  # then experiment 2
  experiment2 = prep_data(file.path("data", 'STGI_exp2_compiled-data.csv'), include_zero = include_zero)
  vas_meds = experiment2$vas_meds
  h2_sum = experiment2$h2_sum
  main_title = 'Reference: Warm Thermode'
  
  s_plotD = make_sPlot(vas_meds = vas_meds, h2_sum = h2_sum, 
                       VAS_type = 'cold', title = 'Cold ratings', l_pos = 'right') +
    scale_colour_manual(values = c(blue[5], blue[7])) +
    scale_fill_manual(values = c(blue[2], blue[4])) +
    theme(title = element_text(size = 10))
  
  s_plotE = make_sPlot(vas_meds = vas_meds, h2_sum = h2_sum, 
                       VAS_type = 'warm', title = 'Warm ratings', l_pos = 'right') +
    scale_colour_manual(values = c(oran[5], oran[7])) +
    scale_fill_manual(values = c(oran[2], oran[4])) +
    theme(title = element_text(size = 10))
  
  s_plotF = make_sPlot(vas_meds = vas_meds, h2_sum = h2_sum, 
                       VAS_type = 'burn', title = 'Burning ratings', l_pos = 'right') +
    scale_colour_manual(values = c(purp[5], purp[7])) +
    scale_fill_manual(values = c(purp[2], purp[4])) +
    theme(title = element_text(size = 10))
  
  s_plot_2 = ggarrange(s_plotD, s_plotE, s_plotF,
                       nrow = 3, ncol = 1,
                       labels = c('D','E','F')) +
    plot_annotation(title = main_title)
  
  #compile the two experiments
  s_plot_out = ggarrange(s_plot_1, s_plot_2,
                         nrow = 1, ncol = 2,
                         widths = c(1,1.4))
  
  s_plot_out
  
  return(s_plot_out)
  
}

# plots for hypothesis 1
make_plot1 = function(vas_h1_diff,h1_diff_sum, title){
  
  # now plot the difference
  plot = data = vas_h1_diff %>% ggplot(aes(colour = quality)) +
    geom_hline(yintercept = 0, colour = 'grey50') +
    geom_point(aes(manipulation, difference, group = ID), position = position_dodge(.2),
               alpha = .5, size = 1.7) +
    geom_line(aes(manipulation, difference, group = ID), position = position_dodge(.2),
              alpha = .3) +
    geom_point(data = h1_diff_sum, aes(manipulation, difference), colour = 'grey15',
               fill = 'grey15',
               shape = 21, size = 3) +
    geom_errorbar(data = h1_diff_sum, aes(manipulation, ymin = difference-ci,
                                          ymax = difference+ci), 
                  width = .15, size = .75, colour = 'grey15') +
    facet_wrap(~quality) +
    scale_colour_manual(values = c(blue[5], oran[5], purp[5])) +
    labs(title = paste0(title),
         y = 'Within - Across VAS Ratings', x = NULL) +
    theme_classic() +
    theme(legend.position = 'none',
          axis.text = element_text(size = 9),
          axis.title = element_text(size = 11),
          strip.text = element_text(size = 10),
          title = element_text(size=10)) +
    coord_cartesian(ylim = c(-60,60))+
    scale_y_continuous(breaks = scales::pretty_breaks(n = 5)) 
  
  plot
  return(plot)
  
}

f3_plot = function(include_zero = T){
  
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
                                 title = "Reference: Warm Thermode") +
                                 theme(axis.text.y=element_blank(),
                                       axis.ticks.y=element_blank(),
                                       axis.title.y=element_blank())
  
  plot1 = h1_diff_plot_exp1+h1_diff_plot_exp2 +
          plot_annotation(tag_levels = list(c("A","B")))
  
  plot1
  
  # save plot
  ggsave(file.path("figures", "Figure3.png"), plot = plot1, device = NULL, 
         width = 7.2, height = 5, dpi = 600)
  
  return(plot1)
}

# plots for hypothesis 2
make_plot2 = function(vas_h2_diff,h2_diff_sum,title){
  
  
  h2_diff_within = ggplot(data = vas_h2_diff %>% 
                            filter(condition == 'within'), 
                          aes(manipulation, difference, colour = quality)) +
    geom_hline(yintercept = 0) +
    geom_point(aes(group = ID), position = position_dodge(.2), alpha = .5,
               size = 1.7) +
    geom_line(aes(manipulation, difference, group = ID), position = position_dodge(.2),
              alpha = .3) +
    geom_point(data = h2_diff_sum %>% 
                 filter(condition == 'within'), 
               aes(manipulation, difference), colour = 'grey15',
               fill = 'grey15',
               shape = 21, size = 3) +
    geom_errorbar(data = h2_diff_sum %>% 
                    filter(condition == 'within'), 
                  aes(manipulation, ymin = difference-ci, ymax = difference+ci),
                  width = .15, size = .75, colour = 'grey15') +
    scale_colour_manual(values = c(blue[5], oran[5], purp[5])) +
    labs(title = title,
         y = 'Proximal - Distal VAS Ratings', x = NULL) +
    facet_wrap(~quality) +
    theme_classic() +
    theme(legend.position = 'none',
          axis.text = element_text(size = 9),
          axis.title = element_text(size = 11),
          strip.text = element_text(size = 10),
          title = element_text(size = 10))+
    coord_cartesian(ylim = c(-60,60))+
    scale_y_continuous(breaks = scales::pretty_breaks(n = 5)) 
  
  # plot the differences - across
  h2_diff_across = ggplot(data = vas_h2_diff %>% 
                            filter(condition == 'across'), 
                          aes(manipulation, difference, colour = quality)) +
    geom_hline(yintercept = 0) +
    geom_point(aes(group = ID), position = position_dodge(.2), alpha = .5, size = 1.7) +
    geom_line(aes(manipulation, difference, group = ID), position = position_dodge(.2),
              alpha = .3) +
    geom_point(data = h2_diff_sum %>% 
                 filter(condition == 'across'), 
               aes(manipulation, difference), colour = 'grey15',
               fill = 'grey15',
               shape = 21, size = 3) +
    geom_errorbar(data = h2_diff_sum %>% 
                    filter(condition == 'across'), 
                  aes(manipulation, ymin = difference-ci, ymax = difference+ci),
                  width = .15, size = .75, colour = 'grey15') +
    scale_colour_manual(values = c(blue[5], oran[5], purp[5])) +
    labs(title = title,
         y = 'Caudal - Rostral VAS Ratings', x = NULL) +
    facet_wrap(~quality) +
    theme_classic() +
    theme(legend.position = 'none',
          axis.text = element_text(size = 9),
          axis.title = element_text(size = 11),
          strip.text = element_text(size = 10),
          title = element_text(size = 10))+
    coord_cartesian(ylim = c(-60,60))+
    scale_y_continuous(breaks = scales::pretty_breaks(n = 5)) 
  
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
  
  experiment2_h2 = make_plot2(vas_h2_diff_exp2,h2_diff_sum_exp2, 
                              title = "Reference: Warm Thermode")[[1]]+
    plot_annotation(tag_levels = list(c("C","D")))
  
  
  #combine plots
  plot2 = wrap_elements(wrap_elements(experiment1_h2) | wrap_elements(experiment2_h2))
  
  plot2
  
  return(plot2)
}


f45_plot = function(include_zero = T){
  
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
  
  plot2 = experiment1_h2[[2]]+
    (experiment2_h2_warm[[2]]+
       theme(axis.text.y=element_blank(),
             axis.ticks.y=element_blank(),
             axis.title.y=element_blank()))+
    plot_annotation(tag_levels = list("A","B"))
  
  plot3 = experiment1_h2[[3]]+
    (experiment2_h2_warm[[3]]+
       theme(axis.text.y=element_blank(),
             axis.ticks.y=element_blank(),
             axis.title.y=element_blank()))+
    plot_annotation(tag_levels = list("A","B"))
  
  # save plots
  ggsave(file.path("figures", "Figure4.png"), plot = plot2, device = NULL, 
         width = 7.2, height = 5, dpi = 600)
  ggsave(file.path("figures", "Figure5.png"), plot = plot3, device = NULL, 
         width = 7.2, height = 5, dpi = 600)
  
  return(list(plot2,plot3))

}

