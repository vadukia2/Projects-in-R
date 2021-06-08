# Factor Wars and Machine Learning


 
# Fama French 3 Factor Model:

Upon merging the three-factor data provided by Fama French, which includes exposure to the broad market (Mkt-Rf), small cap stocks - big cap stocks (SMB), and high book to market value
- low book to market value (HML), and the 1-month T-Bill rate (RF), we were able to run a regression that gave us the coefficients for each of the three factors. Our regression results show a coefficient of 1.194 for Mkt-Rf with a standard error of 0.015, 0.680 for SMB with a standard error of 0.025, 0.420 for HML with a standard error of 0.036. Our regression model also has a bias -1.302 with a standard error of 0.087. These regression figures show that the Fama French 3 Factor model has a positive correlation with stock returns as each of the factors have a positive
coefficient.

## Interaction Terms:

We have chosen several interaction terms including ROE, ROA, and R&D. The reason behind using Big ROE – Small ROE is because the larger the return on equity, there could be greater
stock returns since it means each unit of equity is generating more returns. Similar to how Farma French has SMB which is small market cap – big market cap, with the reasoning that small market cap stock outperform big market cap stock, the idea here is that firms with a larger ROE could have a higher return than firms with lower ROE values. As with the other interaction terms in this project, the sizes Big, Medium, and Small were based off of the 70% and 30% quantiles.

Big ROA- Small ROA is another interaction term we have chosen because it indicates that firms with a larger return per unit of asset could have higher stock returns than firms with lower returns per unit of asset. This is because each unit of asset, all else equal, is used to generate greater profits for firms with higher ROAs, which could indicate that the firm is generating excess profits against other firms.

Big R&D Spending – Small R&D Spending is an interaction term we chose because innovation is often what drives growth. Innovation could be measured through R&D spending, which would include improvements on products and services, or even brand new solutions that could potentially increase market share. R&D spending should pay off in the future via an increase in returns.

Other interaction terms we chose included the factors Debt-to-Market, Quarterly Debt-to-Market, Assets-to-Market, and Gross Profits-to-Assets. The Debt-to-Market (Big Dm - Small Dm) and
Quarterly Debt-to-Market (Big Dmq - Small Dmq) interaction terms provide us with information about the amount of debt a company is using to finance its assets on both a yearly and quarterly basis. The Assets-to-Market (Big Am - Small Am) interaction term reflects a company’s asset value compared to its market value, where the more assets a company has, it may be able to generate excess returns all else equal. The Gross Profits-to-Assets (Big Gpa - Small Gpa) interaction term can provide insight into whether the firm’s assets are profitable or not by
 
comparing its gross profits to its assets. These interaction terms would indicate how healthy the company is and how profitable they are, which are both great predictors for calculating future
stock returns.

We also looked at interaction terms from the following factors: Farma-French’s Book-to-Market, Market Equity of Last December, Book-to-Market Equity, Cash Flow-to-Price. The
Farma-French’s Book-to-Market (Big FFbm - Small FFbm) interaction term is essential to our model because the Farma-French three factor model is a system of developing stock returns by adding size risk and value risk factors to the market risk factors. These additional factors would provide a more accurate prediction of stock prices. While using the model’s Book-to Market as
the interaction term, we can observe how well the market values the company’s equity compared to its book value.

The Market Equity of Last December (Big DecME - Small DecMe) interaction term is important in providing the most recent snapshot of the market value of equity from the previous year.
Market value of equity represents how well the company is doing and by using this factor we can compare growth and if the company is improving currently. The Book-to-Market Equity (Big
BEa - Small BEa) interaction term identifies undervalued or overvalued securities by dividing the book value by the market value. This ratio calculates the market value relative to the actual worth of the company. These factors and interaction terms would add additional value to our model when predicting returns.

The final individual interaction term we chose was the Cash Flow-to-Price (Big CFp - Small
CFp). We decided on this term because it measures the operating cash flow per share relative to its stock price value. This would help us determine if the company is undervalued or overvalued. Along with our other interaction terms, this term would help the model create a more accurate prediction.

For our multiplicative interaction terms (BB-SS), we observed Big ROE* Big ROA - Small ROE
* Small ROE. We created this interaction term because taking on debt increases assets, which is the denominator of RoA. When debt increases, ROA decreases. If ROE is bigger than ROA it means that the company is managing borrowed capital and is taking on leverage. This interaction term would be helpful because if the company is using debt to finance their operations then this would increase the shareholder value, which would be a good predictor of future stock price.

Additionally, we observed a multiplicative interaction term between three year investment growth and two year investment growth (Big Lg3 * Small Lg3 - Big Lg2 * Small Lg2). These growth factors are important to observe because if the company is increasing investment growth between years 2 and 3, then this would show good growth of the company and a rising stock price.
 
## Predication Power:

We did not have time to run the total dataset for our model, so we tested the data after 2002 instead. We have used 3 machine learning models to predict the excess return using the above mentioned factors and the interaction terms. The three models we used were i.) LASSO ii.)
Decision Tree and iii) Random Forest.

## Lasso:

The Lasso Model did not eliminate any of the predictor variable we used for prediction. There was a strong prediction indicated for variables like lag_ME,AFbm, FF_Momentum, Tanq, Roa, Glaq, Iaq1, IG2, Gla, Nop, Amq, Bs_am, BS_ROE and BBSS_RoaRoE. Please refer to the picture below:
 
![image](https://user-images.githubusercontent.com/77515069/121127439-a2a01780-c7de-11eb-9972-cebe608b145b.png)
 
 
We used 75% of the data to train the model and 25% of the data as test data to calculate the
efficiency of the model. We got a Mean Squared error (MSE) of 0.0362283 which suggests that the model has a good predictive model.

## Decision tree:

In this model too we used the same methodology as LASSO to test the efficiency of the model and got an MSE of 0.03414162 which was better than LASSO suggesting this tree based model
had better predictive power compared to LASSO. This is also in line with what Prof. Mao taught us in class that tree based models generally have better predictability compared to linear models.




## Random Forest:

This was the best predictor model among all three models. It had an MSE of 0.0272. We used the same method as for the other two models to check the efficiency of this model. The below pictures show the importance of each variable as per the random forest model. It can be seen that Price, Volume, AFbn, FF_Momentum, R61 were some of the key predictors.
 
 
 ![image](https://user-images.githubusercontent.com/77515069/121127516-bcd9f580-c7de-11eb-8900-d560c2f1bf99.png)

 

## Economic interpretation:

Our captured factors and interaction terms do fit in some well-known trading strategies. For
example, when explaining the value investment strategy, Buffet said that "It's Far Better to Buy a Wonderful Company at a Fair Price Than a Fair Company at a Wonderful Price." He likes to buy quality stocks at the rock-bottom price. In particular, he wants to look for businesses that exhibit long-term prospects, such as desirable long-term ROE, R&D spending, Debt to equity and profit margin. Our model contains most of these factors. We have Big ROE – Small ROE and Big
R&D spending – Small R&D spending as interaction factors. The greater the ROE is, the greater the stock return. R&D spending can make a company's current products durable and make future products innovative. These factors combined can effectively reflect a company's performance in the long run.
 
Besides value investment strategy, our model also can fit in growth investing strategy. Growth investing strategy is an investment strategy that looks for companies that are expected to grow faster than market average rate. Growth investors often look at profit margin, earning growth, return on equity and share performance. In our model, we have interaction terms such as Big Cash flow to price – Small Cash flow to price and Big ROE* Big ROA - Small ROE * Small ROE can be used in growth investing strategy. Cash flow to price can be useful for value stock with positive cash flow but not profitable because of non-cash charges. ROE and ROA can reflect a company's financial leverage and efficiency of that company generating profit.


**Please see the executed code here:**
[Visit executed code](https://github.com/vadukia2/Projects-in-R/blob/e7964358d9cb605a305c55bd986d50570f4a3f53/Factor%20wars%20and%20ML.R)
