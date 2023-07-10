
statistics = function(rerun){
  
if(rerun){
  ######### Exp 1
  
  experiment1 = prep_data(file.path("data", 'STGI_exp1_compiled-data.csv'))
  experiment2 = prep_data(file.path("data", 'STGI_exp2_compiled-data.csv'))
  
  df_long_exp1 = experiment1$df_long
  df_long_exp2 = experiment2$df_long
  ## hypothsis 1
  # Cold
  model_cold_exp1 = glmmTMB::glmmTMB(beta ~ manipulation * condition * cold_cond + trial_n +
                                  (1|ID) + (1|order),
                                family = glmmTMB::beta_family(),
                                ziformula = ~1+manipulation,
                                data = df_long_exp1 %>% filter(quality == 'cold'),
                                na.action = na.omit) 
  
  stats_model_cold_exp1 = summary_stat(model_cold_exp1, 2,2)
  
  # Warm
  model_warm_exp1 = glmmTMB::glmmTMB(beta ~ manipulation * condition * cold_cond +
                                  trial_n + (1|ID) + (1|order),
                                family = glmmTMB::beta_family(),
                                ziformula = ~1+manipulation,
                                data = df_long_exp1 %>% filter(quality == 'warm'),
                                na.action = na.omit) 
  
  
  stats_model_warm_exp1 = summary_stat(model_warm_exp1, 2,2)
  
  # Burn
  #The burning hypothesis is only for participants that experience burning TGI 
  #(aka are responders)
  # First, remove non-responders
  df_resp_exp1 <- df_long_exp1 %>% 
    filter(responder == 1)
  # check n
  length(unique(df_resp_exp1$ID))
  
  model_burn_exp1 = glmmTMB::glmmTMB(beta ~ manipulation * condition * cold_cond + 
                                  trial_n + (1|ID) + (1|order),
                                family = glmmTMB::beta_family(),
                                ziformula = ~1+manipulation,
                                data = df_resp_exp1 %>% filter(quality == 'burn'),
                                na.action = na.omit) 
  
  stats_model_burn_exp1 = summary_stat(model_burn_exp1, 2,2)
  
  
  
  
  
  ## hypothsis 2 (within)
  ######### Exp 2

  # Cold
  model_cold_exp2 = glmmTMB::glmmTMB(beta ~ manipulation * condition * cold_cond + trial_n +
                                       (1|ID) + (1|order),
                                     family = glmmTMB::beta_family(),
                                     ziformula = ~1+manipulation,
                                     data = df_long_exp2 %>% filter(quality == 'cold'),
                                     na.action = na.omit) 
  
  stats_model_cold_exp2 = summary_stat(model_cold_exp2, 2,2)
  
  # Warm
  model_warm_exp2 = glmmTMB::glmmTMB(beta ~ manipulation * condition * cold_cond +
                                       trial_n + (1|ID) + (1|order),
                                     family = glmmTMB::beta_family(),
                                     ziformula = ~1+manipulation,
                                     data = df_long_exp2 %>% filter(quality == 'warm'),
                                     na.action = na.omit) 
  
  
  stats_model_warm_exp2 = summary_stat(model_warm_exp2, 2,2)
  
  # Burn
  #The burning hypothesis is only for participants that experience burning TGI 
  #(aka are responders)
  # First, remove non-responders
  df_resp_exp2 <- df_long_exp2 %>% 
    filter(responder == 1)
  # check n
  length(unique(df_resp_exp2$ID))
  
  model_burn_exp2 = glmmTMB::glmmTMB(beta ~ manipulation * condition * cold_cond + 
                                       trial_n + (1|ID) + (1|order),
                                     family = glmmTMB::beta_family(),
                                     ziformula = ~1+manipulation,
                                     data = df_resp_exp2 %>% filter(quality == 'burn'),
                                     na.action = na.omit) 
  
  stats_model_burn_exp2 = summary_stat(model_burn_exp2, 2,2)
  
  statistics_to_save = ls()[grepl("stats", ls())]
  
  
  foo = function(name){
    variable = get(name, envir=environment())
    return(list(variable))
  }
  
  statistics = sapply(statistics_to_save, foo)
  
  
  #list2env(statistics, envir = sys.frame(sys.parent(0)))
  
  #save(list = vars_to_save, file = here::here("Analysis","Workspace","Plotting_workspace.RData"))
  return(statistics)
}else{
  
  load(here::here("Workspace","stats.RData"))
  
  return(stats)
}
}