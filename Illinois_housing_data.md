# EXECUTIVE SUMMARY



# Case Overview
The Case revolves around determining the fair market value of 10,000 properties in Cook County - which is the second most populous county in the US - and includes Chicago and 130 other municipalities. The initial case data provided us with 50,000 properties to train and validate our algorithm so that we can then go on and use it on the 10,000 properties to predict their value. The analysis of the data has been conducted in R; the script of which is submitted separately.

 
## Methodology

For the analysis of our project we only used functions from the following libraries in R: Tidyverse, Glmnet, Rpart, Rpart.plot, RandomForest and Gbm. These include all the functions we could possibly need that would help us with data transformation and calculations. An easy to understand, summary and pictorial representation of this entire section can be found at the very beginning of the appendix.

After importing the data and creating separate data frames for historical data, predict data, and code book, our next step was to subset the relevant variables for our comparison .The variables that were selected for the analysis in the initial step were based on the “True” values of the column “var_is_predictor” in the code book and also use a certain level of our own discretion in deciding which variable would play a factor in determining the price. This process helped us to narrow down to a set of 37 variables out of the initial 63.

Next we removed the outliers from the data which could potentially distort the values because the sale price ranged from $800 to $15 million. The coefficients of our algorithm would greatly be affected by this. Therefore, we created a frequency distribution graph visualising the sale_price and the frequency represented as a histogram. We set our confidence interval to 90%, thus discarding the top and bottom 5% of values by creating an upper and lower bound This reduced the number of observations in our training data set from 50,000 to 45,040.



## Clean up of data


 Meta_nbhd

Meta nbhd is the neighborhood code, where the first two digits are the township code and next 3 digits as the neighborhood code. We have created a new variable called “nbhd” using the mutate function which includes only the last three digits i.e. neighbourhood code for both train data (data related to historical values) and test data (data for which we have to make the prediction. This will be important later because we use “nbhd” as a predictor when building our algorithm.



 Geo_school_elem_district

We have first replaced the NA values with “XXXX” so that the variable is not taken into consideration for prediction in the test and train data and created a new variable on the same
 
named “elem'' where the values were coerced to factor and then numeric. Since we no longer needed the original variable, we removed it for efficiency. We followed the exact same process for geo_hs_district, where our new numeric variable was titled “hs”.



 Clean up of Char_fbath

We have replaced the na values with 1 as per the code book description for both test and train data.



 Clean up of ind garage

We coerced the boolean values to numeric class for both test and train data.



 Clean up All

Our goal was to get every single variable into a numeric format because we wanted to replace the missing “NA” values with something that made more sense mathematically and wouldn’t skew the coefficients for our predictive algorithm. Therefore, for all the variables we finally replaced the every NA value with the mean value of each respective column. Now that the data was clean, we created two new dataframes, titled: ‘train_clean’ and ‘test_clean’
 
## Creating prediction model

For creating the prediction model we used a modified version of the Random forest method, that filters out new data sets and builds trees based on them. We call it the Filtered Random Forest method. It is explained in the sections below.

 Dividing the test and training data set as per the Usage of property

We divided the data frames according to the usage of the property as indicated by the char_use variable, it could either be a single family home, or a multifamily home; trivially we also had a third division titled “other_family” usage which is basically the mean of the column char_use to account for the NA values. We made this decision because we think it is only fair that we compare like-sized homes. After this division we continued to create separate prediction models on each of these data sets. For the purpose of simplicity we use the shorthand contraction FUB for the three family-use-based data sets that we just described.

 ## Variable Selection

After using trial and error we implemented a brute force variable addition approach and thus narrowed down to a set of 20 variables for single family usage data set, 34 variables for multi family usage data set and we left all 37 predictors for “other family” usage as they were initially NA values (this is explained in the next section).

## Random forest

To build a prediction algorithm, we used a random forest model. We made this decision because there is a non linear relationship between the predictors and the response; furthermore, there are many variables in the model which are being taken into consideration, thus making linear models futile. We believe it will yield us the most accurate predictions using machine learning and will maintain this accuracy even when a large portion of the data is missing . Also random forests are appropriate for data sets which have numerous numeric and categorical variables.

We build the random forest on the three FUB data frames.

-> Random forest for each town code

The random forest that we perform is for each unique town code for each separate FUB data set. Segregation of the prediction model on the basis of town code helps us to segregate prediction for each district and improves the accuracy of the predictions. We use this logic because we don’t think it is fair to value homes in downtown Chicago with those in the suburbs, and so on.
 
-> Mtry for Random forest

While executing the random forest model for the FUB data sets, we tried different levels of mtry settings using the brute force method to find out which one reduces the MSE to the lowest for the validation data. We identified the mtry setting as 3 for single family homes, and 5 for multi family homes.

-> Other family and linear regression

For other family (corresponding to NA values) we have very few observations (only 25 in the training and 5 in the test), which is too less for us to build a tree on. So for these observations we simply performed linear regression to predict the values.

Note: When validating our algorithm and designing the random forest prediction model, we segregated the original historical data (with known sale prices) into training and testing data; the records were split in the ratio of 3:1 respectively. However, for our final model, we designed the optimized model with the lowest MSE, we used the entire historical data set as the training data and entire predict data as the test data.

Finally, after designing the optimized prediction model. The model was executed on the prediction file.
 
## Conclusion
Using random forest and subsetting into FUB data sets, and then further into the different town code as explained in our methodology we built a random forest model and trained it on the historical data to then predict the value of the houses from the predict data. Below are the summary statistics of the predicted value of our houses:


![image](https://user-images.githubusercontent.com/77515069/121123682-7bdee280-c7d8-11eb-920b-629912613f82.png)


The file that contains the assessed value has the PID of the property and its assessed predicted value is submitted as assessed_values.csv

In conclusion, we believe that our model will not include as extreme values as $800 and $15 million (figure 3 in the appendix) from the original historical data set, however, it should perform better on average as it hopes to imitate a fair distribution of the sale prices.



**Please see the executed code here:**
[Visit executed code](https://github.com/vadukia2/Projects-in-R/blob/80d65e4baeafd6d7079e0558c1da8e9d14150be2/Illinois%20housing%20data.R)



## Appendix


![image](https://user-images.githubusercontent.com/77515069/121123744-987b1a80-c7d8-11eb-9983-8a1cbd5eecdf.png)

Figure 1: Methodology description: training data


![image](https://user-images.githubusercontent.com/77515069/121123764-a2048280-c7d8-11eb-93e9-14dac84a7ec1.png)

Figure 2: Methodology description: test data


![image](https://user-images.githubusercontent.com/77515069/121123816-b5afe900-c7d8-11eb-8590-81c251ca795e.png)

Figure 3: Historical distribution of sale prices



