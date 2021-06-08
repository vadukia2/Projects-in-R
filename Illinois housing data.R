

## Import Libraries

library(tidyverse)
library(glmnet)
library(rpart)
library(rpart.plot)
library(randomForest)
library(gbm)


## Import Data


history <- read.csv("historic_property_data.csv")
codebook <- read.csv("codebook.csv")
predict <- read.csv("predict_property_data.csv")
train <- history
test <- predict


## Subset Necessary Data


# Subset Historical Data
train <- subset(train, select = c(sale_price, meta_town_code, meta_nbhd, char_age, char_air, char_attic_type, char_beds, char_bldg_sf, char_bsmt, char_fbath, char_gar1_cnst, char_hbath, char_gar1_size, char_heat, char_roof_cnst, char_tp_plan, char_type_resd, char_use, econ_midincome, geo_school_elem_district, geo_school_hs_district, econ_tax_rate, geo_floodplain, geo_fs_flood_risk_direction, geo_ohare_noise, ind_garage, char_apts, char_attic_fnsh, char_bsmt_fin, char_ext_wall, char_frpl, char_gar1_area, char_gar1_att, char_hd_sf, char_oheat, char_porch, char_tp_dsgn, geo_fs_flood_factor, geo_withinmr100, geo_withinmr101300))

# Subset Predict Data
test <- subset(test, select = c(pid, meta_town_code, meta_nbhd, char_age, char_air, char_attic_type, char_beds, char_bldg_sf, char_bsmt, char_fbath, char_gar1_cnst, char_hbath, char_gar1_size, char_heat, char_roof_cnst, char_tp_plan, char_type_resd, char_use, econ_midincome, geo_school_elem_district, geo_school_hs_district, econ_tax_rate, geo_floodplain, geo_fs_flood_risk_direction, geo_ohare_noise, ind_garage, char_apts, char_attic_fnsh, char_bsmt_fin, char_ext_wall, char_frpl, char_gar1_area, char_gar1_att, char_hd_sf, char_oheat, char_porch, char_tp_dsgn, geo_fs_flood_factor, geo_withinmr100, geo_withinmr101300))



## Removing Outliers

### Data Visualization

historical_dist = ggplot(history) + 
  aes(x = sale_price) + 
  geom_histogram(bins = 3000L, color = "blue") + 
  theme_light()

historical_dist

### Curtail 90% Confidence

lower <- quantile(train$sale_price, 0.05)
upper <- quantile(train$sale_price, 0.95)
print(c(lower,upper))


train <- train[train$sale_price >= lower & train$sale_price <= upper,]
rm(upper, lower)


## Clean Up

### Meta_Nbhd


# Add Neighbourhood Col in Historical Data
train <- train %>% mutate(nbhd = (meta_nbhd %% 1000))
train <- subset(train, select = -c(meta_nbhd))



# Add Neighbourhood Col in Predict Data
test <- test %>% mutate(nbhd = (meta_nbhd %% 1000))
test <- subset(test, select = -c(meta_nbhd))

### Geo_School_Elem_District


# Create Bins for Elem School in Historical
for(i in 1:length(train$geo_school_elem_district)){
  if(is.na(train$geo_school_elem_district[i])){
    train$geo_school_elem_district[i] = "XXXXX"
  }
  else{
    train$geo_school_elem_district[i] = train$geo_school_elem_district[i]
  }
}

rm(i)

train <- train %>% mutate(elem = as.factor(geo_school_elem_district))
train$elem <- as.numeric(train$elem)
train <- subset(train, select = -c(geo_school_elem_district))

# Create Bins for Elem School in Predictive
for(i in 1:length(test$geo_school_elem_district)){
  if(is.na(test$geo_school_elem_district[i])){
    test$geo_school_elem_district[i] = "XXXXX"
  }
  else{
    test$geo_school_elem_district[i] = test$geo_school_elem_district[i]
  }
}

rm(i)

test <- test %>% mutate(elem = as.factor(geo_school_elem_district))
test$elem <- as.numeric(test$elem)
test <- subset(test, select = -c(geo_school_elem_district))


### Geo_School_HS_District


# Create Bins for High School in Historical
for(i in 1:length(train$geo_school_hs_district)){
  if(is.na(train$geo_school_hs_district[i])){
    train$geo_school_hs_district[i] = "XXXXX"
  }
  else{
    train$geo_school_hs_district[i] = train$geo_school_hs_district[i]
  }
}

rm(i)

train <- train %>% mutate(hs = as.factor(geo_school_hs_district))
train$hs <- as.numeric(train$hs)
train <- subset(train, select = -c(geo_school_hs_district))

# Create Bins for High School in Predictive
for(i in 1:length(test$geo_school_hs_district)){
  if(is.na(test$geo_school_hs_district[i])){
    test$geo_school_hs_district[i] = "XXXXX"
  }
  else{
    test$geo_school_hs_district[i] = test$geo_school_hs_district[i]
  }
}

rm(i)

test <- test %>% mutate(hs = as.factor(geo_school_hs_district))
test$hs <- as.numeric(test$hs)
test <- subset(test, select = -c(geo_school_hs_district))


### Char_Fbath



# Fix NA values in Historical for fbath
for(i in 1:length(train$char_fbath)){
  
  if(is.na(train$char_fbath[i])){
    train$char_fbath[i] = 1
  }
  else{
    train$char_fbath[i] = train$char_fbath[i]
  }
  
}

rm(i)

# Fix NA values in Predictive for fbath
for(i in 1:length(test$char_fbath)){
  
  if(is.na(test$char_fbath[i])){
    test$char_fbath[i] = 1
  }
  else{
    test$char_fbath[i] = test$char_fbath[i]
  }
  
}

rm(i)


### Ind_Garage


train$ind_garage <- as.numeric(train$ind_garage)
test$ind_garage <- as.numeric(test$ind_garage)


### Clean Up All

# Make Copy for safekeeping
train_w_na <- train
test_w_na <- test

# All the relevant column numbers that have NA values
relevant = c(4,5,8,10,12,13,14,15,16,17,18,20,21,22,23,24,25,26,27,28,29,30,32,33,34,35,36,37)

# Replace NA values with mean for Historical Data
for(v in relevant){
  
  m = mean(train[,v], na.rm = TRUE)
  for(i in 1:length(train[,v])){
    if(is.na(train[i,v])){
      train[i,v] = m
    }
    else{
      train[i,v] = train[i,v]
    }
  }
  
  rm(i,m)
  
}

rm(v)

# Replace NA values with mean for Predictive Data
for(v in relevant){
  
  m = mean(test[,v], na.rm = TRUE)
  for(i in 1:length(test[,v])){
    if(is.na(test[i,v])){
      test[i,v] = m
    }
    else{
      test[i,v] = test[i,v]
    }
  }
  
  rm(i,m)
  
}

rm(v, relevant)

# Make a clean copy
train_clean <- train
test_clean <- test


# Create empty dataframe to hold result
result <- test_clean[1,]
result$pred <- 0
result <- result[-1,]

## Filtered Random Forest for Testing

# Divide data set into char_use because single family homes should be compared within themselves
single_fam = train_clean[train_clean$char_use == 1,]
test_single = test_clean[test_clean$char_use == 1,]

# Multi family homes should be compared within themselves
multi_fam = train_clean[train_clean$char_use == 2,]
test_multi = test_clean[test_clean$char_use == 2,]

# All other (unkown / NA) family homes should be compared within themselves
other_fam = train_clean[train_clean$char_use == mean(train_clean$char_use),]
test_other = test_clean[test_clean$char_use == mean(test_clean$char_use),]


# Divide into town code
towns <- sort(unique(train$meta_town_code))

# 20 predictors for single family based on forward step AIC
single_tree <- formula(sale_price ~ char_age + char_air + char_attic_type + char_beds + 
                         char_bldg_sf + char_bsmt + char_fbath + char_gar1_size + char_roof_cnst + 
                         econ_midincome + elem + hs + econ_tax_rate + geo_fs_flood_risk_direction + 
                         geo_ohare_noise + nbhd + char_bsmt_fin + char_ext_wall + char_hd_sf + geo_fs_flood_factor)

# 34 Predictors for single family based on forward step AIC
multi_tree <- formula(sale_price ~ char_age + char_air + char_attic_type + char_beds + char_bldg_sf + 
                        char_bsmt + char_fbath + char_gar1_cnst + char_hbath + char_gar1_size + 
                        char_heat + char_roof_cnst + char_tp_plan + char_type_resd + econ_midincome + 
                        elem + hs + econ_tax_rate + geo_floodplain + geo_fs_flood_risk_direction + 
                        geo_ohare_noise + ind_garage + nbhd + char_apts + char_attic_fnsh + 
                        char_bsmt_fin + char_frpl + char_gar1_att + char_hd_sf + char_oheat + 
                        char_tp_dsgn + geo_fs_flood_factor + geo_withinmr100 + geo_withinmr101300)

# All true predictors (37)
tree_form = formula(sale_price ~ char_age + char_air + char_attic_type + char_beds + char_bldg_sf + 
                      char_bsmt + char_fbath + char_gar1_cnst + char_hbath + char_gar1_size + 
                      char_heat + char_roof_cnst + char_tp_plan + char_type_resd + econ_midincome + 
                      elem + hs + econ_tax_rate + geo_floodplain + geo_fs_flood_risk_direction + 
                      geo_ohare_noise + ind_garage + nbhd + char_apts + char_attic_fnsh + 
                      char_bsmt_fin + char_ext_wall + char_frpl + char_gar1_area + char_gar1_att + 
                      char_hd_sf + char_oheat + char_porch + char_tp_dsgn + geo_fs_flood_factor + 
                      geo_withinmr100 + geo_withinmr101300)

# Random Forest for every single town code for single family homes
for(i in 1:length(towns)){
  
  single_sample = single_fam[single_fam$meta_town_code == towns[i],]
  test_sample = test_single[test_single$meta_town_code == towns[i],]
  
  set.seed(1)
  train_housing_data <- single_sample
  test_housing_data <- test_sample
  
  # Sweet Spot = 3
  rf_housing <- randomForest(single_tree, data = train_housing_data, mtry = 3, importance=TRUE)
  
  # MSE in the test data
  rf_predict <- predict(rf_housing, newdata = test_housing_data)
  
  test_housing_data <- test_housing_data %>% mutate(pred = rf_predict)
  
  result <- rbind(result, test_housing_data)
  
  rm(single_sample, test_sample, train_housing_data, test_housing_data, rf_housing, rf_predict)
  
}

rm(i)

# Random Forest for every single town code for multi family homes
for(i in 1:length(towns)){
  
  multi_sample = multi_fam[multi_fam$meta_town_code == towns[i],]
  test_sample = test_multi[test_multi$meta_town_code == towns[i],]
  
  set.seed(1)
  train_housing_data <- multi_sample
  test_housing_data <- test_sample
  
  if(nrow(test_housing_data) == 0){
    next
  }
  
  if(nrow(test_housing_data) <= 5){
    rf_housing = lm(multi_tree, train_housing_data) 
    rf_predict = predict(rf_housing, test_housing_data)
  }
  
  else{
    # Sweet Spot = 5
    rf_housing <- randomForest(multi_tree, data = train_housing_data, mtry = 5, importance=TRUE)
    
    # MSE in the test data
    rf_predict <- predict(rf_housing, newdata = test_housing_data)
    
  }
  
  test_housing_data <- test_housing_data %>% mutate(pred = rf_predict)
  
  result <- rbind(result, test_housing_data)
  
  rm(multi_sample, test_sample, train_housing_data, test_housing_data, rf_housing, rf_predict)
  
}

rm(i)

# Linear Modeling for every single town code for other family homes because very few records
# Ignore warnings
for(i in 1:length(towns)){
  
  other_sample = other_fam[other_fam$meta_town_code == towns[i],]
  other_test = test_other[test_other$meta_town_code == towns[i],]
  if(nrow(other_sample) == 0){
    next
  }
  
  rf_housing = lm(tree_form, other_sample) 
  rf_predict = predict(rf_housing, other_test)
  
  other_test <- other_test %>% mutate(pred = rf_predict)
  
  result <- rbind(result, other_test)
  
  rm(other_sample, other_test, rf_housing, rf_predict)
  
}

rm(i, single_tree, multi_tree, tree_form, towns)

# Model predicted few negative values (negate to get absolute values only)
result[result$pred < 0,41] <- result[result$pred < 0, 41] * (-1)

# Missing row for unknown reason, replaced with mean
temp <- result[1,]
temp$pid <- 7660
temp$pred <- mean(result$pred)
result <- rbind(result, temp)
rm(temp)

# Sort by PID
result_copy <- result[order(result$pid),]

# Deliverable
result_copy <- result_copy[,-c(2:40)]


## Write to Excel


library(writexl)
write_xlsx(result_copy, "assessed_value.xlsx")

## Prediction Stats & Visualization
predict_dist = ggplot(result_copy) + 
  aes(x = pred) + 
  geom_histogram(bins = 8000L, color = "blue") + 
  theme_light()

predict_dist

# Min, max and mean
print(c("min:", "max:", "mean:"))
print(c(min(result_copy$pred), max(result_copy$pred), mean(result_copy$pred)))

# Quantiles
print(c(quantile(result_copy$pred, 0.1), quantile(result_copy$pred, 0.25), quantile(result_copy$pred, 0.5),
quantile(result_copy$pred, 0.75), quantile(result_copy$pred, 0.9)))



