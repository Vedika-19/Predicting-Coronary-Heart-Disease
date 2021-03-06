
#LOADING THE DATA AND CHECKING FOR MISSING VALUES
heart=read.csv(file.choose())
heart=subset(heart,select= -row.names)
str(heart)
names(heart)
head(heart)
library(gmodels)
CrossTable(heart$chd_036)
hist(heart$chd_036)

#CONCLUSION: We can see that 65.4% of 0 class is there and 34.6% 1 class is there in our dataset. The graphical representation makes it easy to visualise the difference between 0 class and 1 class.

#CHECKING FOR MISSING VALUES
colSums(is.na(heart))
colSums(heart == "")
colSums(heart == "unknown")

#Conclusion: There are no missing values in our dataset. 

#EXPLORATORY DATA ANALYSIS
plot(heart)
library(tidyverse)
library(corrplot)
heart %>% select(sbp,tobacco,ldl,adiposity,typea,obesity,alcohol) %>% cor() %>% corrplot(method = "number", type = "upper", tl.cex = 0.8, tl.srt = 45, tl.col = "black")
#Conclusion: The correlation plot tells us that the correlation between adiposity and obesity is 0.72 which is enough to say that the two variables are somewhat highly correlated.Hence if we want we can remove one variable from our analysis.

#Splitting the data into training and test datasets (80-20 split):
library(caTools)
set.seed(3236)
split = sample.split(heart$chd_036,SplitRatio = 0.80)
training = subset(heart, split == TRUE)
testing = subset(heart, split == FALSE)

#LOGISTIC REGRESSION
lr= glm(chd_036~. ,family=binomial(link='logit'),data=training)
summary(lr)
#We remove alcohol feature as the pvalue of alcohol is the greatest and is > 0.05.

lr1=glm(chd_036~ sbp + tobacco + ldl + adiposity + famhist + typea + obesity + age, family = binomial(link='logit'),data=training)
summary(lr1)
#We remove sbp feature as the pvalue of sbp is the greatest and is > 0.05.

lr2=glm(chd_036~ tobacco + ldl + adiposity + famhist + typea + obesity + age, family = binomial(link='logit'),data=training)
summary(lr2)
#We remove adiposity feature as the pvalue of adiposity is the greatest and is > 0.05.

lr3=glm(chd_036~ tobacco + ldl + famhist + typea + obesity + age, family = binomial(link='logit'),data=training)
summary(lr3)
#We remove obesity feature as the pvalue of obesity is the greatest and is > 0.05.

lr4=glm(chd_036~ tobacco + ldl + famhist + typea + age, family = binomial(link='logit'),data=training)
summary(lr4)
#Since, the pvalues of all the features are < 0.05, we s=do not remove any more features and we can say that the remaining features are significant.
#FINAL MODEL: -6.22650 + 0.07816 * tobacco + 0.13377 * ldl + 0.76678 * famhist (Present) + 0.04205 * typea + 0.04485 * age

pred=predict(lr4,newdata=testing)
library(ROCR)
ROCRpred = prediction(pred, testing[,10])
ROCRperf = performance(ROCRpred, 'tpr','fpr')
plot(ROCRperf, colorize=T, main= "ROC Curve of Logistic Regression", ylab = "Sensitivity", xlab = "1-Specificity")
abline(a=0,b=1)
auc = performance(ROCRpred,measure = "auc")
auc = auc@y.values[[1]]
auc
#Conclusion: Our ROC curve shows accuracy of 87.86% 

#Confusion Matrix
library(caret)
pred1= ifelse(pred>0.5, 1,0)
confusionMatrix(factor(pred1), factor(testing$chd_036))

#Conclusion: Confusion matrix shows that our model could predict 57 people does not have chd which was correct and 22 people was predicted as having chd which was false. Here we could improve our model as the patients whose predictions was wrong is at risk. Similarly, it predicted that 3 people doesnot have chd which was wrong as they had chd and 10 people who have chd was predicted correctly.

precision=57/(57+3)
precision

#Conclusion: We get the precision od 95%. Hence, we can say that our model can predict 95% of data as correct predictions.

###DECISION TREE

##CART
library(rpart)
cartfit = rpart(chd_036~.,data=training)
library(rpart.plot)
rpart.plot(cartfit)
pred1=predict(cartfit,newdata=testing)
ROCRpred = prediction(pred1, testing[,10])
ROCRperf = performance(ROCRpred, 'tpr','fpr')
plot(ROCRperf, colorize=T, main= "ROC Curve of CART", ylab = "Sensitivity", xlab = "1-Specificity")
abline(a=0,b=1)
auc = performance(ROCRpred,measure = "auc")
auc = auc@y.values[[1]]
auc
#Conclusion: We get the accuracy of 77.47% in CART Decision Tree.

#Confusion Matrix
pred1= ifelse(pred1>0.5, 1,0)
confusionMatrix(factor(pred1), factor(testing$chd_036))
#Conclusion: Confusion matrix shows that our model could predict 48 people does not have chd which was correct and 16 people was predicted as having chd which was false. Here we could improve our model as the patients whose predictions was wrong is at risk. Similarly, it predicted that 12 people doesnot have chd which was wrong as they had chd and 16 people who have chd was predicted correctly.

precision1=48/(48+12)
precision1
#Conclusion: We get the precision od 80%. Hence, we can say that our model can predict 80% of data as correct predictions using CART.

library(randomForest)
rf=randomForest(chd_036~.,data=training)
varImpPlot(rf)
importance(rf)
pred2=predict(rf,newdata=testing)
ROCRpred = prediction(pred2, testing[,10])
ROCRperf = performance(ROCRpred, 'tpr','fpr')
plot(ROCRperf, colorize=T, main= "ROC Curve of Random Forest", ylab = "Sensitivity", xlab = "1-Specificity")

auc = performance(ROCRpred,measure = "auc")
auc = auc@y.values[[1]]
auc
#Conclusion: Accuracy of random forest is 80.10%

#Confusion Matrix
pred2= ifelse(pred2>0.5, 1,0)
confusionMatrix(factor(pred2), factor(testing$chd_036))
#Conclusion: Confusion matrix shows that our model could predict 55 people does not have chd which was correct and 17 people was predicted as having chd which was false. Here we could improve our model as the patients whose predictions was wrong is at risk. Similarly, it predicted that 5 people doesnot have chd which was wrong as they had chd and 15 people who have chd was predicted correctly.


precision2=55/(55+5)
precision2
#Conclusion: We get the precision od 91.66%. Hence, we can say that our model can predict 91.66% of data as correct predictions using CART.

#Conclusion: Among CART and Random Forest, we can say that Random Forest is better than CART as we get both the accuracy from ROC curve and precision is more for Random Forest than CART. 
#We see the most important splitting criteria is age in our case. The decision tree formed is first divided on the basis of age.

#The precision of the Random Forest model is 91.66%

#Conclusion: From the ROC curve we see the accuracy of Logistic Regression is 87.86% which is more than Random Forest (i.e. 80.10%).
#We can also see that our Logistic regression gives better precision than random forest. 
#So we can conclude that Logistic Regression gives better model as compared to Random forest.


