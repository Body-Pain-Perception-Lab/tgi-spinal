
get_main_tables = function(model, round = 2, title){
  
  if(is.gamlss(model)){
    fixedeffecs = parameters::model_parameters(model) %>% 
      mutate(CI = NULL, CI_low = NULL, CI_high = NULL,df_error = NULL) %>% 
      dplyr::rename(parameter = Component) %>% 
      dplyr::select(parameter, everything()) %>% 
      mutate(parameter = ifelse(str_detect(parameter, "conditional"),"μ (location)",ifelse(str_detect(parameter, "sigma"),"σ (scale)",ifelse(str_detect(parameter, "tau"),"τ (one-inflation)","ν (zero-inflation)"))))
    
    names(fixedeffecs) = c("parameter","contrast","β","SE","t","p")
    formular = as.character(formula(model))
    
    
    fixedeffecs[, 3:6] <- apply(fixedeffecs[, 3:6], 2, function(x) format(x, trim = F, digits = round))
    fixedeffecs
    
    ft = flextable(fixedeffecs) %>% 
      add_header_row(values = paste0(formular[2],formular[1],formular[3]," family = ZOIB, link = logit"), colwidths = c(ncol(fixedeffecs))) %>% 
      add_header_lines(values = title) %>% 
      align(i = 1:2, j = NULL, align = "center", part = "header") %>% width(width = 1)
    
    ft
    
    return(ft)
    
    
  }else{
    m1 = summary(model)
    fixedeffecs = data.frame(m1$coefficients$cond)
    
    fixedeffecs[,1:4] <- apply(fixedeffecs[,1:4], 2, function(x) formatC(x, format = "g", digits = round))
    
    
    names(fixedeffecs) = c("β","SE","Z","p")
    
    formular = as.character(formula(model))
    family = model$modelInfo$family[[2]]
    
    row.names(fixedeffecs) = c("Intercept","TGI-CNT",
                               "Within-Across",
                               "Caudal-Rostral",
                               "Proximal-Distal","Trial",
                               "TGI-CNT * Within-CNT",
                               "TGI-CNT * Caudal-Rostral",
                               "TGI-CNT * Proximal-Distal")
    
    
    flextable(fixedeffecs %>% rownames_to_column(var = "  ")) %>% 
      add_header_row(values = paste0(formular[2],formular[1],formular[3],", family = ", m1$family,"(link = ", m1$link, ")"), colwidths = c(5)) %>% 
      add_header_lines(values = title) %>% 
      align(i = 1:2, j = NULL, align = "center", part = "header")
  }
  
}


FitFlextableToPage <- function(ft, pgwidth = 6){
  
  ft_out <- ft %>% autofit()
  
  ft_out <- width(ft_out, width = dim(ft_out)$widths*pgwidth /(flextable_dim(ft_out)$widths))
  return(ft_out)
}

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

# make supplementary figures for experiment 1 and experiment 2
# plot ratings in seperate panels
# plot experiments seperately (numerical input 1 or 2)

sPlot = function(include_zero = T){
  # first experiment 1
  experiment1 = prep_data(file.path("data", 'STGI_exp1_compiled-data.csv'), include_zero = include_zero)
  vas_meds = experiment1$vas_meds
  h2_sum = experiment1$h2_sum
  main_title = 'Experiment 1: Cold thermode'
    
  
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
  main_title = 'Experiment 2: warm thermode'
  
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
                         widths = c(1,1.5))
  
  s_plot_out
  
  return(s_plot_out)
  
}

