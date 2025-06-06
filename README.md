# About ChronoPreH

Here is the description of this R package ChronoPreH, which in essence is a "meta" of multiple prediction models synthetically.

Basically, it is used for the prediction of large datasets, including mostly medical datasets, for the usage of disease prediction. It can also be used for astronomical datasets to predict the age of stars and planets (actually since the data for astronomy is always very large, I'm thinking maybe python is more fit, but I like R language very much...). Maybe also more, but I am just familiar with these two fields. Happy to communicate if you want to apply it in your discipline! : )

The theoretical basis of this model is that, for various scenarios, currently, we select the 'best model' for ALL population. However, each individual can perform heterogeneously even given the best model. So, we should select the best model for each individual to make predictions, and this result would always be better than a universal method throughout.

# Fit function

This is for a single variable in the dataset. For instance, in CHARLS (a longitudinal cohort study by Peking University: https://charls.pku.edu.cn/en/), there are variables such as age, sex, HbA1c, smoking status, alcohol drinking status, whether or not having stroke, whether or not having dementia, whether or not having cancer, and so on. These kind of datasets, similar to the global aging datasets (https://g2aging.org/home) like HRS (Health Retirement Studies, United States, https://hrs.isr.umich.edu/about), and many other countries, collect data as "waves", for instance, every 1 year, every 2 years, they collect medical data from their population. And best of all, these datasets have harmonized data across multiple waves, so like for each variable, it has year1, year2, year3 data cleaned. Now the years (time) are x (e.g. 2021,2022,2023 ***BUT THE TIMEPOINTS ARE DISCRETE!!!***), and the y are the values of the variables. y can be continuous (e.g. 0.01,0.02,0.03), or categorical (0,1,0).

There are other types of datasets with continuous time, such as the UK Biobank (https://www.ukbiobank.ac.uk/), and actually most real-world medical systems used in hospitals are like this. You just can't expect doctors to have data for patients of say last year, need to have at least last week, at best last minute (some hospitals doing this actually to yesterday, which is very quick). So for these datasets are having ***CONTINUOUS TIMEPOINTS***, and so first x is still time, but now maybe (I mean in real life you transform data format like year-month-date to a number) like Jan.2 2023, Jan.5 2023, Feb. 6, 2023. y are still variables of interest. 

Nevertheless, the method is the same for both types of datasets. I just want to be clear if you found this to be confusing. Previously, I did some math modeling and was thinking to have for each timepoint, multiple variables synthesizing, I mean it should work for datasets with discrete timepoints, but for continuous timepoint not ok. For the sake of applicability, it is now like this.

## (1) Continuous variable

There are several methods you can use to model continuous variable overtime, and surely more in the future, I just collected 11 methods, and like run them for prediction at the same time, use the absolute error (|predict result - true value|) to get the best model for the specific variable. This is different from other packages or methods or papers that use various models but apply the model through all variables; now my model do for each variable in the dataset, their unique "best model". I think this is great because for different models, they might be heterogeneous across different variables, so the robustness is not necessary even.

Confounders (continuous or categorical, can be manually defined) are adjusted whenever applicable in the 11 methods. (Previously I was thinking about defining whether a confounder is categorical or continuous automatically, but it always generates error, so I think manually define would be better, and more efficient.)

The script file is in R/FitCont.R, and this argument is named "FitCont".

The test file is in test/testthis/FitCont_test.R

Interestingly when I tested, the model runs super fast, like within one second, which is just a great start. I thought it will take at least like 10 minutes or so.

Here are the included prediction models (x=time, y=variable of interest):
- linear model (lm)
- Orthogonal Polynomials (poly)
- nonlinear (weighted) least-squares estimates (nls)
- Interpolating Splines (splinefun)
- Smoothing Spline (smooth.spline)
- Generalized additive models with integrated smoothness estimation (gam)
- random forest (randomForest)
- Ranger is a fast implementation of random forests (Breiman 2001) or recursive partitioning, particularly suited for high dimensional data (ranger)
- eXtreme Gradient Boosting Training (xgboost)
- Support Vector Machines (svm)
- Fit neural network (nnet)

Some basic ones, some more advanced, like machine learning.

I really was trying to include Bayesian analysis because it is so popular these days, but it is literally taking forever to run, and always have errors around posterior inputs. Maybe I will write a separate argument just for Bayes if I have time in the future. Also, I figured that since I used so many models, the running time for a large dataset should be longer compared with just using one method, which is why Bayes is not quite suitable (and I personaly think there's really no need to include it here). 

I was also thinking about ARIMA, but it does not include x as time. Basically, it ranks the y-values according to time-series. I will also try to adjust this in the future.

To visualize the results conveniently, I created another argument: FitCont_vi. It a forest plot for the result of the 12 models above, showing the error from prediction to the true value, and highlight the closest one with red. In this way, we can see which model is the best, and how much.

It's in R/FitCont_vi.R

The PDF of the figure generated from sample is in test/visualization/FitCont_visualization_test.pdf

## (2) Categorical variable

For categorical variables, I used slightly different models, because many models used in continuous variables are not applicable here. I have 8 models for categorical variable, in the future there can be more.

Likewise, confounders are adjusted whenever possible.

The script file is in R/FitCat.R, and this argument is named "FitCat".

The test file is in test/testthis/FitCat_test.R

Here are the included prediction models (x=time, y=variable of interest):
- multinomial logistic regression (nnet::multinom)
- random forest (randomForest)
- ranger (ranger)
- eXtreme Gradient Boosting Training (xgboost)
- Support Vector Machines (svm)
- naive Bayes (naiveBayes)
- Decision tree (rpart)
- k-Nearest Neighbors (knn)

When doing this I realized a slight (actually can be huge) problem here, that, since the result is categorical, there can be more than one model having the correct prediction; also, there can be no model having correct prediction. To pick the best model, I calculated prediction probability, and use it to decide when there are more than one with correct prediction result or all have wrong prediction result. If there is only one model having the correct prediction, then that will be it regardless of prediction probability.

To visualize the results conveniently, I created another argument: FitCat_vi. This can easily show the models with correction or wrong prediction, and circle the correct prediction model with highest prediction probability.

It's in R/FitCat_vi.R

Also, there is a pdf file for the result figure generated using FitCat_vi in test/visualization/FitCat_visualization_test

# Apply ChronoPreH in your code

I am currently trying to upload this package to CRAN. But before that, I am testing this package using CHARLS harmonized dataset, so that it actually works when looping over a large population.








