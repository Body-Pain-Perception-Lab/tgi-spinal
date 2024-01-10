
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


# make supplementary figures for experiment 1 and experiment 2
# plot ratings in seperate panels
# plot experiments seperately (numerical input 1 or 2)


sPlot1 = function(include_zero = T){
  ## figures with thresholds and TGI temperatures
  exp1_temps <- read.csv(file.path("data", 'STGI_exp1_temperatures.csv'))
  exp2_temps <- read.csv(file.path("data", 'STGI_exp2_temperatures.csv'))
  # modify data
  exp1_temps <- exp1_temps %>% 
    mutate(EXP = 'exp1') 
  exp2_temps <- exp2_temps %>% 
    mutate(EXP = 'exp2')
  # combine both
  temps <- rbind(exp1_temps, exp2_temps)
  
  thresh <- temps %>% 
    pivot_longer(cols = c(CPT,HPT), names_to = 'TEMP', values_to = 'THRESH') %>% 
    select(-c(CTGI, WTGI))
  
  tgi <- temps %>%   
    pivot_longer(cols = c(CTGI, WTGI), names_to = 'TEMP', values_to = 'TGI') %>% 
    mutate(TEMP = fct_recode(TEMP, 'cold' = 'CTGI', 'warm' = 'WTGI')) %>% 
    select(-c(CPT,HPT))
  
  thr_plot <- ggplot(data = thresh, aes(color = TEMP, fill = TEMP)) +
    geom_point(aes(TEMP, THRESH, group = ID), position = position_dodge(.2),
               shape = 20, alpha = .8, size = 2) +
    #geom_line(aes(TEMP, THRESH, group = ID), position = position_dodge(.2),
    #          alpha = .2) +
    scale_color_manual(values = c(blue[8], oran[8])) +
    labs(x = NULL, y = 'Temperature (ºC)', title = 'Pain thresholds') +
    ylim(0,50) +
    facet_wrap(~EXP) +
    theme_classic() +
    theme(legend.position = 'none',
          axis.text = element_text(size = 9),
          axis.title = element_text(size = 11),
          strip.text = element_text(size = 10),
          title = element_text(size = 10))
  
  tgi_plot <- ggplot(data = tgi, aes(color = TEMP, fill = TEMP)) +
    geom_line(aes(TEMP, TGI, group = ID), position = position_dodge(.2),
              alpha = .2, colour = 'grey75', size = .7) +
    geom_point(aes(TEMP, TGI, group = ID), position = position_dodge(.2),
               shape = 20, alpha = .8, size = 2) +
    scale_color_manual(values = c(blue[5], oran[5])) +
    labs(x = NULL, y = '', title = 'TGI temperatures') +
    ylim(0,50) +
    facet_wrap(~EXP) +
    theme_classic() +
    theme(legend.position = 'none',
          axis.text = element_text(size = 9),
          axis.title = element_text(size = 11),
          strip.text = element_text(size = 10),
          title = element_text(size = 10))
  
  out_plot <- ggarrange(thr_plot, tgi_plot)
  ggsave(file.path("figures", "FigureS1.png"), plot = out_plot, device = NULL, 
         width = 7.2, height = 5, dpi = 600)

  return(out_plot)
}
