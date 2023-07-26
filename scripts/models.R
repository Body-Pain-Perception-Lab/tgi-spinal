
statistics = function(rerun){
  #roudning
  r = 2
  
  
if(rerun){
  
  
  experiment1 = prep_data(file.path("data", 'STGI_exp1_compiled-data.csv'))
  experiment2 = prep_data(file.path("data", 'STGI_exp2_compiled-data.csv'))
  
  df_long_exp1 = experiment1$df_long %>% mutate(cold_probe = as.factor(cold_probe), manipulation = as.factor(manipulation))
  df_long_exp2 = experiment2$df_long %>% mutate(cold_probe = as.factor(cold_probe), manipulation = as.factor(manipulation))
  
  
  ## Define constrats such that we both get within / across (i.e. distal & proximal vs rostral & caudual)
  levels(df_long_exp1$cold_probe)
  # "caudal"   "distal"   "proximal" "rostral" 
  
  #within - across
  within_across = c(-1/2,1/2,1/2,-1/2)
  #caudal - rostral
  caudal_rostral = c(1,0,0,-1)
  #distral - proximal
  proximal_distal = c(0,-1,1,0)
  
  #define the matrix
  cold = rbind(1/4,within_across,caudal_rostral,proximal_distal)
  
  #solve it 
  cold = solve(cold)
  
  #remove the constant
  cold = cold[,-1]
  
  
  ######### Exp 1 (Hypothesis 1)
  
  ## hypothsis 1  
  # Cold.

  model_cold_exp1 = glmmTMB::glmmTMB(beta ~ manipulation * cold_probe + 
                                trial_n + (1|ID) + (1|order),
                                family = glmmTMB::beta_family(),
                                ziformula = ~1+manipulation,
                                data = df_long_exp1 %>% filter(quality == 'cold'),
                                na.action = na.omit,
                                contrasts=list(cold_probe = cold) 
                                ) 
  stats_model_cold_exp1 = summary_stat(model_cold_exp1, 8,r)
  
  # Warm
  model_warm_exp1 = glmmTMB::glmmTMB(beta ~ manipulation * cold_probe +
                                  trial_n + (1|ID) + (1|order),
                                family = glmmTMB::beta_family(),
                                ziformula = ~1+manipulation,
                                data = df_long_exp1 %>% filter(quality == 'warm'),
                                na.action = na.omit,
                                contrasts=list(cold_probe = cold)
                                ) 
  
  stats_model_warm_exp1 = summary_stat(model_warm_exp1, 8,r)
  
  # Burn
  #The burning hypothesis is only for participants that experience burning TGI 
  #(aka are responders)
  # First, remove non-responders
  df_resp_exp1 <- df_long_exp1 %>% 
    filter(responder == 1)
  # check n
  length(unique(df_resp_exp1$ID))
  
  model_burn_exp1 = glmmTMB::glmmTMB(beta ~ manipulation * cold_probe + 
                                  trial_n + (1|ID) + (1|order),
                                family = glmmTMB::beta_family(),
                                ziformula = ~1+manipulation,
                                data = df_resp_exp1 %>% filter(quality == 'burn'),
                                na.action = na.omit,
                                contrasts=list(cold_probe = cold)
                                ) 
  
  stats_model_burn_exp1 = summary_stat(model_burn_exp1, 8,r)
  

  ######### Exp 2 (Hypothesis 1)

  
  
  # Cold
  model_cold_exp2 = glmmTMB::glmmTMB(beta ~ manipulation*cold_probe  + trial_n +
                                       (1|ID) + (1|order),
                                     family = glmmTMB::beta_family(),
                                     ziformula = ~1+manipulation,
                                     data = df_long_exp2 %>% filter(quality == 'cold'),
                                     na.action = na.omit,
                                     contrasts=list(cold_probe = cold) 
                                     ) 
  
  stats_model_cold_exp2 = summary_stat(model_cold_exp2, 8,r)
  
  # Warm
  model_warm_exp2 = glmmTMB::glmmTMB(beta ~ manipulation * cold_probe +
                                       trial_n + (1|ID) + (1|order),
                                     family = glmmTMB::beta_family(),
                                     ziformula = ~1+manipulation,
                                     data = df_long_exp2 %>% filter(quality == 'warm'),
                                     na.action = na.omit,
                                     contrasts=list(cold_probe = cold)) 
  
  
  stats_model_warm_exp2 = summary_stat(model_warm_exp2, 8,r)
  
  # Burn
  #The burning hypothesis is only for participants that experience burning TGI 
  #(aka are responders)
  # First, remove non-responders
  df_resp_exp2 <- df_long_exp2 %>% 
    filter(responder == 1)
  # check n
  length(unique(df_resp_exp2$ID))
  
  model_burn_exp2 = glmmTMB::glmmTMB(beta ~ manipulation * cold_probe + 
                                       trial_n + (1|ID) + (1|order),
                                     family = glmmTMB::beta_family(),
                                     ziformula = ~1+manipulation,
                                     data = df_resp_exp2 %>% filter(quality == 'burn'),
                                     na.action = na.omit,
                                     contrasts=list(cold_probe = cold)
                                     ) 
  
  stats_model_burn_exp2 = summary_stat(model_burn_exp2, 8,r)

  
  ## participant information (all)
  #remove columns in exp2 that isnt in exp1
  names = names(df_long_exp2)[!names(df_long_exp2) %in% names(df_long_exp1)]
  df_long_exp2 = df_long_exp2 %>% select(-all_of(names))
  
  #both
  df = rbind(df_long_exp1,df_long_exp2)
  whole_gender = df %>% mutate(Gender = as.factor(Gender)) %>% group_by(Gender,ID) %>% slice(1) %>% ungroup(ID) %>% summarize(number = n())
  whole_age = df %>% group_by(ID) %>% slice(1) %>% ungroup(ID)  %>% summarize(mean_age = mean(Age, na.rm = T), sd_age = sd(Age, na.rm = T),max_age = max(Age), min_age = min(Age))
  
  
  ##exp 1
  descript_exp1_gender = df_long_exp1 %>% mutate(Gender = as.factor(Gender)) %>% group_by(Gender,ID) %>% slice(1) %>% ungroup(ID) %>% summarize(number = n())
  descript_exp1_age = df_long_exp1 %>% group_by(ID) %>% slice(1) %>% ungroup(ID)  %>% summarize(mean_age = mean(Age, na.rm = T), sd_age = sd(Age, na.rm = T),max_age = max(Age), min_age = min(Age))
  descript_exp1_age = round(descript_exp1_age,r)
  ##exp 2
  descript_exp2_gender = df_long_exp2 %>% mutate(Gender = as.factor(Gender)) %>% group_by(Gender,ID) %>% slice(1) %>% ungroup(ID) %>% summarize(number = n())
  descript_exp2_age = df_long_exp2 %>% group_by(ID) %>% slice(1) %>% ungroup(ID)  %>% summarize(mean_age = mean(Age, na.rm = T), sd_age = sd(Age, na.rm = T),max_age = max(Age), min_age = min(Age))
  descript_exp2_age = round(descript_exp2_age,r)
  
  
  
  
  statistics_to_save = ls()[grepl("stats", ls())]
  data_to_save = ls()[grepl("descript_", ls())]
  
  saving = c(statistics_to_save,data_to_save)
  
  foo = function(name){
    variable = get(name, envir=environment())
    return(list(variable))
  }
  
  savings = sapply(saving, foo)
  

  #list2env(statistics, envir = sys.frame(sys.parent(0)))
  
  #save(list = vars_to_save, file = here::here("Analysis","Workspace","Plotting_workspace.RData"))
  return(savings)
}else{
  
  load(here::here("Workspace","stats.RData"))
  
  return(stats)
}
}
