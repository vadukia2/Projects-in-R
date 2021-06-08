# Dependencies
library(tidyverse)
library(haven)
library(stargazer)
library(lubridate)
library(glmnet)
library(rpart)
library(rpart.plot)
library(randomForest)
library(gbm)
library(boot)

# run on Bridge
# in_file = '/ocean/projects/ses190002p/mohans2/proj3_ML/features_training_small.csv'
# crsp >- read.csv(in_file)



data <- read.csv("E:/OneDrive/OneDrive - University of Illinois - Urbana/FIN 555/Project 3/features_training.csv")


crsp <- data %>% filter(yyyy >= 2002)



# first replace NAs with mean
for(v in 1:ncol(crsp)){
  
  for(i in 1:length(crsp[,v])){
    if(is.na(crsp[i,v])){
      crsp[i,v] = mean(crsp[,v], na.rm = TRUE)
    }
    else{
      crsp[i,v] = crsp[i,v]
    } }
  
  rm(i)
  
}

sum(!complete.cases(crsp))


FF_factors <- read.csv("FF_factors.csv") %>%
  separate(Date, into = c('yyyy', 'mm'), sep = 4) %>%
  mutate(yyyy = as.numeric(yyyy),
         mm = as.numeric(mm))




# merge FF 3 factors
crsp <- left_join(crsp, FF_factors, by = c("yyyy", "mm"))



# check for NAs
sum(!complete.cases(crsp))

# Question 1
crsp_new = crsp %>%
  group_by(PERMNO) %>% 
  arrange(yyyy,mm) %>%
  ungroup() %>%
  filter(yyyy >= 1972 & yyyy <= 2002) %>%
  mutate(ExcessReturn = 100*RET - RF)


# check for NAs
sum(!complete.cases(crsp_new))



# Question 2
## simple regression
mod1 <- lm(ExcessReturn ~ Mkt.RF + SMB + HML, data = crsp_new)


stargazer(mod1, out = "table.html")



# Question 3

## creating dummies and interaction terms

# FFbm
crsp_new <- crsp_new %>%
  group_by(yyyy,mm) %>%
  mutate(size_FFBM = ifelse(FFbm > quantile(FFbm, 0.7, na.rm = TRUE), "B", 
                            ifelse(FFbm < quantile(FFbm, 0.3, na.rm =TRUE), "S", "M"))) %>%
  mutate(BS_FFBM = mean(RET[size_FFBM == "B"]) - mean(RET[size_FFBM == "S"]))




# DecME
crsp_new <- crsp_new %>%
  group_by(yyyy,mm) %>%
  mutate(size_DecME = ifelse(DecME > quantile(DecME, 0.7, na.rm = TRUE), "B", 
                             ifelse(DecME < quantile(DecME, 0.3, na.rm =TRUE), "S", "M"))) %>%
  mutate(BS_DecME = mean(RET[size_DecME == "B"]) - mean(RET[size_DecME == "S"]))



# Dmq
crsp_new <- crsp_new %>%
  group_by(yyyy,mm) %>%
  mutate(size_Dmq = ifelse(Dmq > quantile(Dmq, 0.7, na.rm = TRUE), "B", 
                           ifelse(Dmq < quantile(Dmq, 0.3, na.rm =TRUE), "S", "M"))) %>%
  mutate(BS_Dmq = mean(RET[size_Dmq == "B"]) - mean(RET[size_Dmq == "S"]))



# Blq
crsp_new <- crsp_new %>%
  group_by(yyyy,mm) %>%
  mutate(size_Blq = ifelse(Blq > quantile(Blq, 0.7, na.rm = TRUE), "B", 
                           ifelse(Blq < quantile(Blq, 0.3, na.rm =TRUE), "S", "M")))

# size_Olq
crsp_new <- crsp_new %>%
  group_by(yyyy,mm) %>%
  mutate(size_Olq = ifelse(Olq > quantile(Olq, 0.7, na.rm = TRUE), "B", 
                           ifelse(Olq < quantile(Olq, 0.3, na.rm =TRUE), "S", "M")))





# size_Roe
crsp_new <- crsp_new %>%
  group_by(yyyy,mm) %>%
  mutate(size_Roe = ifelse(Roe > quantile(Roe, 0.7, na.rm = TRUE), "B", 
                           ifelse(Roe < quantile(Roe, 0.3, na.rm =TRUE), "S", "M"))) %>%
  mutate(BS_Roe = mean(RET[size_Roe == "B"]) - mean(RET[size_Roe == "S"]))




# size_Roa
crsp_new <- crsp_new %>%
  group_by(yyyy,mm) %>%
  mutate(size_Roa = ifelse(Roa > quantile(Roa, 0.7, na.rm = TRUE), "B", 
                           ifelse(Roa < quantile(Roa, 0.3, na.rm =TRUE), "S", "M")))





# size_Iaq1
crsp_new <- crsp_new %>%
  group_by(yyyy,mm) %>%
  mutate(size_Iaq1 = ifelse(Iaq1 > quantile(Iaq1, 0.7, na.rm = TRUE), "B", 
                            ifelse(Iaq1 < quantile(Iaq1, 0.3, na.rm =TRUE), "S", "M"))) 






# size_BEa
crsp_new <- crsp_new %>%
  group_by(yyyy,mm) %>%
  mutate(size_BEa = ifelse(BEa > quantile(BEa, 0.7, na.rm = TRUE), "B", 
                           ifelse(BEa < quantile(BEa, 0.3, na.rm =TRUE), "S", "M"))) %>%
  mutate(BS_BEa = mean(RET[size_BEa == "B"]) - mean(RET[size_BEa == "S"]))





# size_Investment
crsp_new <- crsp_new %>%
  group_by(yyyy,mm) %>%
  mutate(size_Investment = ifelse(Investment > quantile(Investment, 0.7, na.rm = TRUE), "B", 
                                  ifelse(Investment < quantile(Investment, 0.3, na.rm =TRUE), "S", "M"))) 




# size_Gla
crsp_new <- crsp_new %>%
  group_by(yyyy,mm) %>%
  mutate(size_Gla = ifelse(Gla > quantile(Gla, 0.7, na.rm = TRUE), "B", 
                           ifelse(Gla < quantile(Gla, 0.3, na.rm =TRUE), "S", "M")))



# size_Dm
crsp_new <- crsp_new %>%
  group_by(yyyy,mm) %>%
  mutate(size_Dm = ifelse(Dm > quantile(Dm, 0.7, na.rm = TRUE), "B", 
                          ifelse(Dm < quantile(Dm, 0.3, na.rm =TRUE), "S", "M"))) %>%
  mutate(BS_Dm = mean(RET[size_Dm == "B"]) - mean(RET[size_Dm == "S"]))





# size_CFp
crsp_new <- crsp_new %>%
  group_by(yyyy,mm) %>%
  mutate(size_CFp = ifelse(CFp > quantile(CFp, 0.7, na.rm = TRUE), "B", 
                           ifelse(CFp < quantile(CFp, 0.3, na.rm =TRUE), "S", "M"))) %>%
  mutate(BS_CFp = mean(RET[size_CFp == "B"]) - mean(RET[size_CFp == "S"]))



# size_op
crsp_new <- crsp_new %>%
  group_by(yyyy,mm) %>%
  mutate(size_Op = ifelse(Op > quantile(Op, 0.7, na.rm = TRUE), "B", 
                          ifelse(Op < quantile(Op, 0.3, na.rm =TRUE), "S", "M"))) 




# size_Gpa
crsp_new <- crsp_new %>%
  group_by(yyyy,mm) %>%
  mutate(size_Gpa = ifelse(Gpa > quantile(Gpa, 0.7, na.rm = TRUE), "B", 
                           ifelse(Gpa < quantile(Gpa, 0.3, na.rm =TRUE), "S", "M"))) %>%
  mutate(BS_Gpa = mean(RET[size_Gpa == "B"]) - mean(RET[size_Gpa == "S"]))






# size_Rdm
crsp_new <- crsp_new %>%
  group_by(yyyy,mm) %>%
  mutate(size_Rdm = ifelse(Rdm > quantile(Rdm, 0.7, na.rm = TRUE), "B", 
                           ifelse(Rdm < quantile(Rdm, 0.3, na.rm =TRUE), "S", "M"))) 



# size_Am
crsp_new <- crsp_new %>%
  group_by(yyyy,mm) %>%
  mutate(size_Am = ifelse(Am > quantile(Am, 0.7, na.rm = TRUE), "B", 
                          ifelse(Am < quantile(Am, 0.3, na.rm =TRUE), "S", "M"))) %>%
  mutate(BS_Am = mean(RET[size_Am == "B"]) - mean(RET[size_Am == "S"]))




# size_Amq
crsp_new <- crsp_new %>%
  group_by(yyyy,mm) %>%
  mutate(size_Amq = ifelse(Amq > quantile(Amq, 0.7, na.rm = TRUE), "B", 
                           ifelse(Amq < quantile(Amq, 0.3, na.rm =TRUE), "S", "M")))



# Roe and Roa
crsp_new <- crsp_new %>%
  group_by(yyyy,mm) %>%
  mutate(BBSS_RoaRoe = mean(RET[size_Roa == "B" & size_Roe == "B"]) - mean(RET[size_Roa == "S" & size_Roe == "S"]))


# Ig2 AND Ig3
crsp_new <- crsp_new %>%
  group_by(yyyy,mm) %>%
  mutate(size_Ig2 = ifelse(Ig2 > quantile(Ig2, 0.7, na.rm = TRUE), "B", 
                           ifelse(Ig2 < quantile(Ig2, 0.3, na.rm =TRUE), "S", "M"))) %>%
  mutate(size_Ig3 = ifelse(Ig3 > quantile(Ig3, 0.7, na.rm = TRUE), "B", 
                           ifelse(Ig3 < quantile(Ig3, 0.3, na.rm =TRUE), "S", "M"))) %>%
  mutate(BBSS_Ig2Ig3 = mean(RET[size_Ig2 == "B" & size_Ig3 == "B"]) - mean(RET[size_Ig2 == "S" & size_Ig3 == "S"]))



crsp_new[is.na(crsp_new)] = 0



# check for NAs
sum(!complete.cases(crsp_new))
# locate NAs
which(is.na(crsp_new), arr.ind=TRUE)
# We find 1976-1986 (row 117 to 220) only "M" so BS_FFBM all returns NA





# Split in the training and testing data sets
set.seed(1)
train_data <- sample_frac(crsp_new, 0.75)
test_data <- setdiff(crsp_new, train_data)



#Lasso 

# glmnet requires y and x to be vectors/matrices, not data frames

f1 <- formula(RET ~ PRC + VOL + SHROUT + lag_ME + FFbm + AFbm + FF_Momentum + DecME + R61 + Dmq + Blq + Olq + Tanq + Roe +
                Roa + Glaq + Iaq1 + dRoe + dRoa + BEa + Investment + Ig + Ig2 + Ig3 + Ivg + Gla + Hn + Robust + Dm + 
                CFp + Op + Nop + Gpa + Rdm + Tan + Bmq + Am + Amq + BS_Am + BS_Gpa + BS_CFp + BS_Dm + BS_BEa + BS_Roe + BS_Dmq
              + BS_DecME + BS_FFBM + BBSS_Ig2Ig3 + BBSS_RoaRoe)

x1 <- model.matrix(f1, data = train_data)
head(x1)

y <- train_data$RET

# estimate LASSO regression
cvfit1 <- cv.glmnet(x=x1, y=y)
Lasso_prediction <- coef(cvfit1, s = "lambda.min")



# predicted values of y
y_hat <- predict(cvfit1, newx = x1, s = "lambda.min")

LASSO_MSE <- mean((y - y_hat)^2)
LASSO_MSE 


### Decision tree

#As a benchmark,  we replicate the model of a simple tree we did in the last lecture.

#```{r, message=FALSE, warning=FALSE}

# Fit the tree 
tree_dt <- rpart(f1, data = train_data)

# Predict in the test data
tree_predict <- predict(tree_dt, newdata = test_data)

# MSE 
Decision_tree_MSE <- mean((tree_predict - test_data$RET)^2)
Decision_tree_MSE



# Random forest


tree_form <- formula(RET ~ PRC + VOL + SHROUT + lag_ME + FFbm + AFbm + FF_Momentum + DecME + R61 + Dmq + Blq + Olq + Tanq + Roe +
                       Roa + Glaq + Iaq1 + dRoe + dRoa + BEa + Investment + Ig + Ig2 + Ig3 + Ivg + Gla + Hn + Robust + Dm + 
                       CFp + Op + Nop + Gpa + Rdm + Tan + Bmq + Am + Amq + BS_Am + BS_Gpa + BS_CFp + BS_Dm + BS_BEa + BS_Roe + BS_Dmq
                     + BS_DecME + BS_FFBM  + BBSS_Ig2Ig3 + BBSS_RoaRoe)

rf_stocks <- randomForest(f1, data = train_data, mtry = 8, importance=TRUE)

# Importance
Plot_random_forest <- varImpPlot(rf_stocks)
Plot_random_forest


# MSE in the test data
rf_predict <- predict(rf_stocks, newdata = test_data)

# MSE
Random_forest_MSE <- mean((rf_predict - test_data$RET)^2)
Random_forest_MSE


