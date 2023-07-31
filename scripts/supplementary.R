
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