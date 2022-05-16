## Beta Regression Power Analysis
## Simulations to assess statistical power given alpha, n, effect size
## Tyson S. Barrett

library(tidyverse)
library(betareg)

set.seed(84322)

## Population Model
pop <- 100000              ## provides the population size (arbitrary) - just want it big
n <- 400                   ## change this to what sample size we want to test
vars <- paste0("x", 1:10)
preds <- map(vars, ~data.frame(rnorm(pop, sd = 1)) %>% set_names(.x)) %>% 
  do.call("cbind", .)
data <- preds %>% 
  mutate(outcome = .04*preds$x1 + .04*preds$x2 + .04*preds$x1*preds$x2 + rbeta(pop, 2.1, 3.5)) %>% 
  mutate(outcome = case_when(outcome < 0 ~ 0,
                             TRUE ~ outcome)) %>% 
  mutate(outcome = outcome/max(outcome)) %>% 
  mutate(outcome = (outcome * (pop - 1) + .5) / pop) %>% 
  mutate(x1 = scale(x1),
         x2 = scale(x2))

## rough estimate of partial correlation for x1
lm(scale(outcome) ~ x1 + x2 + x3 + x4 + x5 + x6 + x7 + x8 + x9 + x10,
   data = data)

## Odds ratio effect size here
betareg::betareg(outcome ~ x1 + x2 + x3 + x4 + x5 + x6 + x7 + x8 + x9 + x10,
                 data = data) %>% 
  coef() %>% 
  exp()

## Start plot of the distribution of the outcome
plot(density(data$outcome), lwd = 2, col = "chartreuse3",
     main = "Distribution of Outcome",
     xlab = "Value of Outcome",
     ylim=c(0, 2.5))

## Replications
replicates <- replicate(1000, {
  
  d1 <- data[sample(1:pop, n), ]
  lines(density(d1$outcome), col = alpha("dodgerblue3", .1))
  
  ## Population Effect Size
  betareg::betareg(outcome ~ x1 + x2 + x3 + x4 + x5 + x6 + x7 + x8 + x9 + x10,
                   data = d1) %>% 
    summary() %>% 
    coef() %>% 
    .$mean                
},
simplify = FALSE)

## Finish Plot
lines(density(data$outcome), lwd = 2, col = "chartreuse3")

## Assess power
replicates %>% 
  purrr::map(~data.frame(.x) %>% 
               rownames_to_column() %>% 
               set_names(c("var", "est", "se", "z", "p"))) %>% 
  do.call("rbind", .) %>% 
  data.frame %>% 
  filter(var %in% c("x1", "x2")) %>% 
  summarize(power = sum(p < .05)/2000)


## Interaction Effects
## rough estimate of partial correlation for x1
lm(scale(outcome) ~ x1 * x2 + x3 + x4 + x5 + x6 + x7 + x8 + x9 + x10,
   data = data)

replicates2 <- replicate(1000, {
  
  d1 <- data[sample(1:pop, n), ]
  
  ## Population Effect Size
  betareg::betareg(outcome ~ x1 * x2 + x3 + x4 + x5 + x6 + x7 + x8 + x9 + x10,
                   data = d1) %>% 
    summary() %>% 
    coef() %>% 
    .$mean                
},
simplify = FALSE)

replicates2 %>% 
  purrr::map(~data.frame(.x) %>% 
               rownames_to_column() %>% 
               set_names(c("var", "est", "se", "z", "p"))) %>% 
  do.call("rbind", .) %>% 
  data.frame %>% 
  filter(var %in% c("x1:x2")) %>% 
  summarize(power = sum(p < .05)/1000)