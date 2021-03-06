
#################  Executive Summary  #################

# In this analysis, I used machine learning methods to build prediction models 
# designed to predict what whether an employee will stay with the company (IBM)
# or will leave.

# In this section I'll describe the dataset and summarize the goal of the project and key steps 
# that were performed.

# The data was provided by IBM and can be found on Kaggle here:
# https://www.kaggle.com/pavansubhasht/ibm-hr-analytics-attrition-dataset

# My goal was to build a prediction model with a prediction accuracy 88%.
# I surpassed that goal.

# I split the data into a training set (90% of data) to train the prediction models
# and a testing set (10% of data) to test the accuracy of the prediction model.

# After running three prediction models, the highest accuracy obtained was 
# 0.8911565 or 89.11565%. Surpassing my goal of 88% prediction accuracy.

# The most effective prediction model was "Generalized Linear Model".

# This report contains four sections: 
# Executive Summary, Analysis, Results, and Conclusion.

# Executive Summary describes the dataset and summarizes the goal of the project and key steps 
# that were performed.

# Analysis explains the process and techniques used, such as data cleaning, data exploration and 
# visualization, any insights gained, and the modeling approach.

# Results presents the modeling results and discusses the model performance.

# Conclusion gives a brief summary of the report, its limitations and future work.

# Thank you for taking the time to look at this report.
# I hope that you will run this code by stepping through (by pressing Ctrl + Enter) 
# as I'm explaining it.


#################  Analysis  #################

# In this section, I'll explain the process and techniques used, such as data cleaning, 
# data exploration and visualization, any insights gained, and the modeling approach. 
# You'll see these models in action in the Results section.

# 90% of the data was designated for training the prediction model and 10% of the data 
# was reserved for testing the accuracy of that model's predictions.

# A simple way of thinking about this is that the model (or algorithm) will learn 
# about the data by taking in different factors and will make a prediction of which
# employees will stay and which will leave.
# Different approaches will have the model/algorithm using the factors given to it 
# in different ways to make predictions.

# The model/algorithm decides to predict a review rating "Y" based on factors "A", "B",
# and "C" (or more). Then the model/algorithm is exposed to the testing dataset to see if 
# what it predicts as the review rating "Y" (based on the factors in the new dataset "A", "B",
# and "C") is actually that accurate or not.

# I hope that you will step through the code with me as I explain it.

# You can run all of the code by clicking Run. You can run it line by line by pressing Ctrl + Enter 
# on your keyboard. You can also highlight a section of code and run just that by clicking Run or pressing
# Ctrl + Enter on your keyboard.

# Let's dig in!



# These next lines will install what is needed to run the code and will skip what your
# system already has installed.

# Note: This could take a few minutes.

if(!require(caret)) install.packages("caret", repos = "http://cran.us.r-project.org")
if(!require(data.table)) install.packages("data.table", repos = "http://cran.us.r-project.org")
if(!require(dotwhisker)) install.packages("dotwhisker", repos = "http://cran.us.r-project.org")
if(!require(tidyverse)) install.packages("tidyverse", repos = "http://cran.us.r-project.org")
if(!require(rmarkdown)) install.packages("rmarkdown", repos = "http://cran.us.r-project.org")
if(!require(readr)) install.packages("readr", repos = "http://cran.us.r-project.org")
if(!require(rpart)) install.packages("rpart", repos = "http://cran.us.r-project.org")
if(!require(pROC)) install.packages("pROC", repos = "http://cran.us.r-project.org")
if(!require(rpart.plot)) install.packages("rpart.plot", repos = "http://cran.us.r-project.org")
library(caret)
library(data.table)
library(dotwhisker)
library(tidyverse)
library(rmarkdown)
library(readr)
library(rpart)
library(pROC)
library(rpart.plot)


wd <- getwd()

# Uncomment and run the next
# line to see your working directory:
# wd

setwd(wd)

# You can change this by editing the file path instead 
# of using "wd".




downloadedFile <- "https://raw.githubusercontent.com/AveryClark/Harvard-Attrition-Capstone/master/HR-Employee-Attrition.csv"

CSV_HR_Attrition <- read_csv(url(downloadedFile))


# The next line sets a random seed
# so that anyone else running this
# code can replicate the same results.
set.seed(1, sample.kind="Rounding")


# Let's probe the data and see what we learn.
head(CSV_HR_Attrition)
tibble(CSV_HR_Attrition)
str(CSV_HR_Attrition)
table(CSV_HR_Attrition$Attrition)


head(CSV_HR_Attrition$Over18)
levels(as.factor(CSV_HR_Attrition$Over18))
levels(as.factor(CSV_HR_Attrition$EmployeeCount))
levels(as.factor(CSV_HR_Attrition$StandardHours))
# I'll remove the "Over18," "EmployeeCount," and "StandardHours" columns since 
# all the values are the same in each. You can see this by looking at each column's 
# values as factors. These three have only one factor each.

dropColumns <- c("Over18", "EmployeeCount", "StandardHours")
CSV_HR_Attrition <- CSV_HR_Attrition[ , !(names(CSV_HR_Attrition) %in% dropColumns)]

tibble(CSV_HR_Attrition)

# Now I'll run a multiple regression analysis on all the data to see which variables
# make the biggest difference.

# Factors are not allowed in the variable you're trying to predict for in multiple regression analysis, 
# so I'll need to convert the Attrition variable into numeric form first.

CSV_HR_Attrition$Attrition <- as.factor(CSV_HR_Attrition$Attrition)

CSV_HR_Attrition$Attrition <- ifelse(CSV_HR_Attrition$Attrition=="Yes", 0, 1)[CSV_HR_Attrition$Attrition]



allCovariatesEffectsMR <- lm(Attrition ~ Age + BusinessTravel + DailyRate + Department + DistanceFromHome
                             + Education + EducationField + EmployeeNumber + EnvironmentSatisfaction 
                             + Gender + HourlyRate + JobInvolvement + JobLevel 
                             + JobRole + JobSatisfaction + MaritalStatus + MonthlyIncome + MonthlyRate 
                             + NumCompaniesWorked + OverTime + PercentSalaryHike + PerformanceRating 
                             + RelationshipSatisfaction + StockOptionLevel + TotalWorkingYears 
                             + TrainingTimesLastYear + WorkLifeBalance + YearsAtCompany + YearsInCurrentRole 
                             + YearsSinceLastPromotion + YearsWithCurrManager, data=CSV_HR_Attrition)


summary(allCovariatesEffectsMR)

modcoef <- summary(allCovariatesEffectsMR)[["coefficients"]]
modcoef[order(modcoef[ , 4]), ] 

topFactors <- modcoef[order(modcoef[ , 4]), ]
topFactors[1:10,4]
topFactors[1:10,0]

# By sorting by p-value, we can see that according to our multiple reggression analysis, the factors with 
# the greatest significance on attrition (in order) are: 
# OverTime, EnvironmentSatisfaction, JobSatisfaction, JobInvolvement, 
# BusinessTravel, NumCompaniesWorked, MaritalStatus, DistanceFromHome, JobRole,
# and YearsSinceLastPromotion.


# Note: When I tried to reach a higher accuracy level by using only some columns that 
# had proven to be significant in this test, my accuracy actually decreased. So I let 
# each type of analysis decide for itself which predictors to include from the entire list.





# Now that we've seen what the most important factors
# for predicting attrition are according to our 
# multiple regression analysis, let's see what
# they are according to a RPART (Recursive Partitioning 
# And Regression Trees) analysis.


# The RPART analysis works by splitting the data into groups like a big 
# decision tree. It then makes its predictions per entry (or in our case,
# per employee) based upon where the predictors fall in its decision 
# tree path.


# Before we begin the RPATH analysis,
# I'd like to clean up the JobRole
# variable by shortening the titles
# to make it nicer to present in our graphs.

# This will also give us separate 
# datasets for each job role,
# which we'll test for differences
# later.

head(CSV_HR_Attrition$JobRole)
jobRoleLevels <- as.factor(CSV_HR_Attrition$JobRole)
levels(jobRoleLevels)


for (i in seq(1, length(CSV_HR_Attrition$JobRole), by=1)) {
  
  if(CSV_HR_Attrition$JobRole[i] == "Healthcare Representative") {
    CSV_HR_Attrition$JobRole[i] <- "HC R"
    if(isFALSE(exists("dbSplit_HCRData"))) {
      dbSplit_HCRData <- CSV_HR_Attrition[i,]
    }
    else {
      dbSplit_HCRData <- rbind(dbSplit_HCRData, CSV_HR_Attrition[i,]) 
    }
  } 
  
  else if(CSV_HR_Attrition$JobRole[i] == "Human Resources") {
    CSV_HR_Attrition$JobRole[i] <- "HR"
    if(isFALSE(exists("dbSplit_HRData"))) {
      dbSplit_HRData <- CSV_HR_Attrition[i,]
    }
    else {
      dbSplit_HRData <- rbind(dbSplit_HRData, CSV_HR_Attrition[i,]) 
    }
  } 
  
  else if(CSV_HR_Attrition$JobRole[i] == "Laboratory Technician") {
    CSV_HR_Attrition$JobRole[i] <- "LT"
    if(isFALSE(exists("dbSplit_LTData"))) {
      dbSplit_LTData <- CSV_HR_Attrition[i,]
    }
    else {
      dbSplit_LTData <- rbind(dbSplit_LTData, CSV_HR_Attrition[i,]) 
    }
  } 
  
  else if(CSV_HR_Attrition$JobRole[i] == "Manager") {
    CSV_HR_Attrition$JobRole[i] <- "Mgr"
    if(isFALSE(exists("dbSplit_MgrData"))) {
      dbSplit_MgrData <- CSV_HR_Attrition[i,]
    }
    else {
      dbSplit_MgrData <- rbind(dbSplit_MgrData, CSV_HR_Attrition[i,]) 
    }
  } 
  
  else if(CSV_HR_Attrition$JobRole[i] == "Manufacturing Director") {
    CSV_HR_Attrition$JobRole[i] <- "MD"
    if(isFALSE(exists("dbSplit_MDData"))) {
      dbSplit_MDData <- CSV_HR_Attrition[i,]
    }
    else {
      dbSplit_MDData <- rbind(dbSplit_MDData, CSV_HR_Attrition[i,]) 
    }
  } 
  
  else if(CSV_HR_Attrition$JobRole[i] == "Research Director") {
    CSV_HR_Attrition$JobRole[i] <- "RD"
    if(isFALSE(exists("dbSplit_RDData"))) {
      dbSplit_RDData <- CSV_HR_Attrition[i,]
    }
    else {
      dbSplit_RDData <- rbind(dbSplit_RDData, CSV_HR_Attrition[i,]) 
    }
  } 
  
  else if(CSV_HR_Attrition$JobRole[i] == "Research Scientist") {
    CSV_HR_Attrition$JobRole[i] <- "R Sci"
    if(isFALSE(exists("dbSplit_RSciData"))) {
      dbSplit_RSciData <- CSV_HR_Attrition[i,]
    }
    else {
      dbSplit_RSciData <- rbind(dbSplit_RSciData, CSV_HR_Attrition[i,]) 
    }
  } 
  
  else if(CSV_HR_Attrition$JobRole[i] == "Sales Executive") {
    CSV_HR_Attrition$JobRole[i] <- "Sal Ex"
    if(isFALSE(exists("dbSplit_SalExData"))) {
      dbSplit_SalExData <- CSV_HR_Attrition[i,]
    }
    else {
      dbSplit_SalExData <- rbind(dbSplit_SalExData, CSV_HR_Attrition[i,]) 
    }
  } 
  
  else if(CSV_HR_Attrition$JobRole[i] == "Sales Representative") {
    CSV_HR_Attrition$JobRole[i] <- "Sal R"
    if(isFALSE(exists("dbSplit_SalRData"))) {
      dbSplit_SalRData <- CSV_HR_Attrition[i,]
    }
    else {
      dbSplit_SalRData <- rbind(dbSplit_SalRData, CSV_HR_Attrition[i,]) 
    }
  }
  
}

jobRoleLevelsAfter <- as.factor(CSV_HR_Attrition$JobRole)
levels(jobRoleLevelsAfter)
head(jobRoleLevelsAfter)



# Now on to the RPATH analysis.

CSV_HR_Attrition$Attrition <- as.factor(CSV_HR_Attrition$Attrition)


set.seed(1, sample.kind="Rounding")

tuneGrid.rpart <- expand.grid(
  cp = seq(.01, .05, by = .005)
)

ctrl <- trainControl(method = "cv", number = 2)

CSV_HR_Attrition.train.rpart <- train(
  y = CSV_HR_Attrition$Attrition, 
  x = subset(CSV_HR_Attrition, select = -Attrition), 
  method = "rpart", 
  trControl = ctrl, 
  tuneGrid = tuneGrid.rpart, 
  na.action = na.pass)


plot(varImp(CSV_HR_Attrition.train.rpart, scale = FALSE), 20)

# According to our RPART analysis, the most important 
# factors in predicting attrition are:

# MonthlyIncome, JobLevel, TotalWorkingYears,
# OverTime, YearsAtCompany, JobRole,
# and MaritalStatus.


rpart.plot(CSV_HR_Attrition.train.rpart$finalModel, type = 5, 
           box.palette = c("palegreen3", "palegreen1", "pink1", "red"),
           tweak = 1)

# According to our RPART Analysis:

# If an employee does NOT work overtime,
# the probability they will leave the
# company is 10%. This group accounts
# for around 72% of our dataset.

# If an employee DOES work overtime and
# also makes $2475 or more per month,
# the probability they will leave the
# company is 23%. This group accounts
# for around 24% of our dataset.

# If an employee DOES work overtime and
# also makes LESS THAN $2475 per month,
# the probability they will leave the
# company is 70%. This group accounts
# for around 5% of our dataset.



# Now let's repeat the RPART analysis, 
# but with more tests to get better
# detail and accuracy.

set.seed(1, sample.kind="Rounding")

tuneGrid.rpart <- expand.grid(
  cp = seq(.01, .05, by = .005)
)

ctrl <- trainControl(method = "cv", number = 6)

CSV_HR_Attrition.train.rpart <- train(
  y = CSV_HR_Attrition$Attrition, 
  x = subset(CSV_HR_Attrition, select = -Attrition), 
  method = "rpart", 
  trControl = ctrl, 
  tuneGrid = tuneGrid.rpart, 
  na.action = na.pass)


plot(varImp(CSV_HR_Attrition.train.rpart, scale = FALSE), 20)


rpart.plot(CSV_HR_Attrition.train.rpart$finalModel, type = 5, 
           box.palette = c("palegreen3", "palegreen1", "pink1", "red"),
           tweak = 1)


# Now we can see that with more
# tests, our RPART analysis has 
# similar conclusions but more 
# detail and more accuracy.

# If you're confused about how to 
# interpret this, look at the 
# explanation of the first RPART 
# plot above.




# Just for good measure,
# let's see what happens when
# we have lots of tests.

set.seed(1, sample.kind="Rounding")

tuneGrid.rpart <- expand.grid(
  cp = seq(.01, .05, by = .005)
)

ctrl <- trainControl(method = "repeatedcv", number = 20, repeats = 5)

CSV_HR_Attrition.train.rpart <- train(
  y = CSV_HR_Attrition$Attrition, 
  x = subset(CSV_HR_Attrition, select = -Attrition), 
  method = "rpart", 
  trControl = ctrl, 
  tuneGrid = tuneGrid.rpart, 
  na.action = na.pass)


plot(varImp(CSV_HR_Attrition.train.rpart, scale = FALSE), 20)


rpart.plot(CSV_HR_Attrition.train.rpart$finalModel, type = 5, 
           box.palette = c("palegreen3", "palegreen1", "pink1", "red"),
           tweak = 1)

# Now we can reach conclusions that 
# have more detail and accuracy.

# If you're confused about how to 
# interpret this, look at the 
# explanation of the first RPART 
# plot above.





# Now let's run the same analysis but 
# looking at job roles separately, 
# instead of all job roles together.



# Sales Executive:

set.seed(1, sample.kind="Rounding")

tuneGrid.rpart <- expand.grid(
  cp = seq(.01, .05, by = .005)
)

ctrl <- trainControl(method = "repeatedcv", number = 20, repeats = 5)

jobRoleSplit_CSV_HR_Attrition.train.rpart <- train(
  y = dbSplit_SalExData$Attrition, 
  x = subset(dbSplit_SalExData, select = -Attrition), 
  method = "rpart", 
  trControl = ctrl, 
  tuneGrid = tuneGrid.rpart, 
  na.action = na.pass)



# Healthcare Representative:

set.seed(1, sample.kind="Rounding")

tuneGrid.rpart <- expand.grid(
  cp = seq(.01, .05, by = .005)
)

ctrl <- trainControl(method = "repeatedcv", number = 20, repeats = 5)

jobRoleSplit_CSV_HR_Attrition.train.rpart <- train(
  y = dbSplit_HCRData$Attrition, 
  x = subset(dbSplit_HCRData, select = -Attrition), 
  method = "rpart", 
  trControl = ctrl, 
  tuneGrid = tuneGrid.rpart, 
  na.action = na.pass)

# Healthcare Representative:

plot(varImp(jobRoleSplit_CSV_HR_Attrition.train.rpart, scale = FALSE), 20)

# Healthcare Representative:

rpart.plot(jobRoleSplit_CSV_HR_Attrition.train.rpart$finalModel, type = 5, 
           box.palette = c("palegreen3", "palegreen1", "pink1", "red"),
           tweak = 1)




# Human Resources:

set.seed(1, sample.kind="Rounding")

tuneGrid.rpart <- expand.grid(
  cp = seq(.01, .05, by = .005)
)

ctrl <- trainControl(method = "repeatedcv", number = 20, repeats = 5)

jobRoleSplit_CSV_HR_Attrition.train.rpart <- train(
  y = dbSplit_HRData$Attrition, 
  x = subset(dbSplit_HRData, select = -Attrition), 
  method = "rpart", 
  trControl = ctrl, 
  tuneGrid = tuneGrid.rpart, 
  na.action = na.pass)

# Human Resources:

plot(varImp(jobRoleSplit_CSV_HR_Attrition.train.rpart, scale = FALSE), 20)

# Human Resources:

rpart.plot(jobRoleSplit_CSV_HR_Attrition.train.rpart$finalModel, type = 5, 
           box.palette = c("palegreen3", "palegreen1", "pink1", "red"),
           tweak = 1)





# Laboratory Technician:

set.seed(1, sample.kind="Rounding")

tuneGrid.rpart <- expand.grid(
  cp = seq(.01, .05, by = .005)
)

ctrl <- trainControl(method = "repeatedcv", number = 20, repeats = 5)

jobRoleSplit_CSV_HR_Attrition.train.rpart <- train(
  y = dbSplit_LTData$Attrition, 
  x = subset(dbSplit_LTData, select = -Attrition), 
  method = "rpart", 
  trControl = ctrl, 
  tuneGrid = tuneGrid.rpart, 
  na.action = na.pass)

# Laboratory Technician:

plot(varImp(jobRoleSplit_CSV_HR_Attrition.train.rpart, scale = FALSE), 20)

# Laboratory Technician:

rpart.plot(jobRoleSplit_CSV_HR_Attrition.train.rpart$finalModel, type = 5, 
           box.palette = c("palegreen3", "palegreen1", "pink1", "red"),
           tweak = 1)





# Manager:

set.seed(1, sample.kind="Rounding")

tuneGrid.rpart <- expand.grid(
  cp = seq(.01, .05, by = .005)
)

ctrl <- trainControl(method = "repeatedcv", number = 20, repeats = 5)

jobRoleSplit_CSV_HR_Attrition.train.rpart <- train(
  y = dbSplit_MgrData$Attrition, 
  x = subset(dbSplit_MgrData, select = -Attrition), 
  method = "rpart", 
  trControl = ctrl, 
  tuneGrid = tuneGrid.rpart, 
  na.action = na.pass)

# Manager:

plot(varImp(jobRoleSplit_CSV_HR_Attrition.train.rpart, scale = FALSE), 20)

# Manager:

rpart.plot(jobRoleSplit_CSV_HR_Attrition.train.rpart$finalModel, type = 5, 
           box.palette = c("palegreen3", "palegreen1", "pink1", "red"),
           tweak = 1)





# Manufacturing Director:

set.seed(1, sample.kind="Rounding")

tuneGrid.rpart <- expand.grid(
  cp = seq(.01, .05, by = .005)
)

ctrl <- trainControl(method = "repeatedcv", number = 20, repeats = 5)

jobRoleSplit_CSV_HR_Attrition.train.rpart <- train(
  y = dbSplit_MDData$Attrition, 
  x = subset(dbSplit_MDData, select = -Attrition), 
  method = "rpart", 
  trControl = ctrl, 
  tuneGrid = tuneGrid.rpart, 
  na.action = na.pass)

# Manufacturing Director:

plot(varImp(jobRoleSplit_CSV_HR_Attrition.train.rpart, scale = FALSE), 20)

# Manufacturing Director:

rpart.plot(jobRoleSplit_CSV_HR_Attrition.train.rpart$finalModel, type = 5, 
           box.palette = c("palegreen3", "palegreen1", "pink1", "red"),
           tweak = 1)






# Research Director:

set.seed(1, sample.kind="Rounding")

tuneGrid.rpart <- expand.grid(
  cp = seq(.01, .05, by = .005)
)

ctrl <- trainControl(method = "repeatedcv", number = 20, repeats = 5)

jobRoleSplit7_CSV_HR_Attrition.train.rpart <- train(
  y = dbSplit_RDData$Attrition, 
  x = subset(dbSplit_RDData, select = -Attrition), 
  method = "rpart", 
  trControl = ctrl, 
  tuneGrid = tuneGrid.rpart, 
  na.action = na.pass)

# Research Director:

plot(varImp(jobRoleSplit7_CSV_HR_Attrition.train.rpart, scale = FALSE), 20)

# Research Director:

rpart.plot(jobRoleSplit7_CSV_HR_Attrition.train.rpart$finalModel, type = 5, 
           box.palette = c("palegreen3", "palegreen1", "pink1", "red"),
           tweak = 1)





# Research Scientist:

set.seed(1, sample.kind="Rounding")

tuneGrid.rpart <- expand.grid(
  cp = seq(.01, .05, by = .005)
)

ctrl <- trainControl(method = "repeatedcv", number = 20, repeats = 5)

jobRoleSplit8_CSV_HR_Attrition.train.rpart <- train(
  y = dbSplit_RSciData$Attrition, 
  x = subset(dbSplit_RSciData, select = -Attrition), 
  method = "rpart", 
  trControl = ctrl, 
  tuneGrid = tuneGrid.rpart, 
  na.action = na.pass)

# Research Scientist:

plot(varImp(jobRoleSplit8_CSV_HR_Attrition.train.rpart, scale = FALSE), 20)

# Research Scientist:

rpart.plot(jobRoleSplit8_CSV_HR_Attrition.train.rpart$finalModel, type = 5, 
           box.palette = c("palegreen3", "palegreen1", "red1", "red"),
           tweak = 1)






# Sales Executive:

set.seed(1, sample.kind="Rounding")

tuneGrid.rpart <- expand.grid(
  cp = seq(.01, .05, by = .005)
)

ctrl <- trainControl(method = "repeatedcv", number = 20, repeats = 5)

jobRoleSplit9_CSV_HR_Attrition.train.rpart <- train(
  y = dbSplit_SalExData$Attrition, 
  x = subset(dbSplit_SalExData, select = -Attrition), 
  method = "rpart", 
  trControl = ctrl, 
  tuneGrid = tuneGrid.rpart, 
  na.action = na.pass)

# Sales Executive:

plot(varImp(jobRoleSplit9_CSV_HR_Attrition.train.rpart, scale = FALSE), 20)

# Sales Executive:

rpart.plot(jobRoleSplit9_CSV_HR_Attrition.train.rpart$finalModel, type = 5, 
           box.palette = c("palegreen3", "palegreen1", "pink1", "red"),
           tweak = 1)







# Sales Representative:

set.seed(1, sample.kind="Rounding")

tuneGrid.rpart <- expand.grid(
  cp = seq(.01, .05, by = .005)
)

ctrl <- trainControl(method = "repeatedcv", number = 20, repeats = 5)

jobRoleSplit10_CSV_HR_Attrition.train.rpart <- train(
  y = dbSplit_SalRData$Attrition, 
  x = subset(dbSplit_SalRData, select = -Attrition), 
  method = "rpart", 
  trControl = ctrl, 
  tuneGrid = tuneGrid.rpart, 
  na.action = na.pass)

# Sales Representative:

plot(varImp(jobRoleSplit10_CSV_HR_Attrition.train.rpart, scale = FALSE), 20)

# Sales Representative:

rpart.plot(jobRoleSplit10_CSV_HR_Attrition.train.rpart$finalModel, type = 5, 
           box.palette = c("palegreen3", "palegreen1", "pink1", "red"),
           tweak = 1)












# Now we'll split our data into a training dataset and a validation dataset.

# The testing set will be 10% of the data.


CSV_HR_Attrition$Attrition <- ifelse(CSV_HR_Attrition$Attrition==1, 0, 1)[CSV_HR_Attrition$Attrition]
# The next line sets a random seed
# so that anyone else running this
# code can replicate the same results.
set.seed(1, sample.kind="Rounding")
# if using R 3.5 or earlier, use `set.seed(1)` instead
test_index <- createDataPartition(y = CSV_HR_Attrition$Attrition, times = 1, p = 0.1, list = FALSE)
trainingSet <- CSV_HR_Attrition[-test_index,]
testingSet <- CSV_HR_Attrition[test_index,]

head(trainingSet)
tibble(trainingSet)
str(trainingSet)

head(testingSet)
tibble(testingSet)
str(testingSet)




# Now let's build some prediction models and look at their accuracy.




#################  Results  #################

# Now we'll go over the models and the final results.

# Note: When I tried to reach a higher accuracy level by using only some columns that 
# had proven to be significant, my accuracy actually decreased. So I've let each type
# of analysis decide for itself which predictors to include.

# Now we'll build two functions that will help us see the accuracy 
# of our prediction models.

# This function will round our decimals up or down to 1 or 0.
roundBinary = function(x) {
  posneg = sign(x)
  z = abs(x)*10^0
  z = z + 0.5
  z = trunc(z)
  z = z/10^0
  z*posneg
}

# This function will insert our model into a confusion matrix
# to test model accuracy against the test set.
accuracy <- function(model_testing) {
  u <- union(model_testing, testingSet$Attrition)
  t <- table(factor(model_testing, u), factor(testingSet$Attrition, u))
  confusionMatrix(t)
}


# For our first prediction model, we'll start with a very simple approach.
# Let's see what the majority of people did and predict that outcome for
# every employee.
mu_hat <- mean(trainingSet$Attrition)
mu_hat
percentLeft <- mean(trainingSet$Attrition)
percentLeft
# 16.32653% of the employees in the training set left the company.

percentStayed <- (1 - percentLeft)
percentStayed
# 83.67347% of the employees in the training set stayed with the company.

# So for our first model, we're going to predict the most common outcome 
# (FALSE or 0, which means the employee stayed) as our prediction for 
# everyone in the company to establish as our baseline accuracy level. 
# Then we will hopefully improve accuracy in subsequent models.
# Let's see how accurate this approach is.

length(testingSet$Attrition)
# There are 147 employees in the testing set.

sum(testingSet$Attrition)
# Only 21 left the company.

length(testingSet$Attrition) - sum(testingSet$Attrition)
# 126 stayed with the company.

model01 <- rep(0, length(testingSet$Attrition))
model01

model01 <- roundBinary(model01)
model01

matrixModel01 <- accuracy(model01)
matrixModel01

# The confusion matrix will show us the model's prediction accuracy.
matrixModel01$overall[1]
model01_Acc <- matrixModel01$overall[1]

# 85.71429% stayed with the company which means our first model's prediction 
# (that everyone stayed) has 85.71429% accuracy.

cat(paste0("The first model has ", model01_Acc*100, "% accuracy."))

# Let's put this model into a list and start off our list of attempts:
accuracyTestResultsList <- tibble(method = "Most Common Outcome/Naive Approach Model", Accuracy = model01_Acc)
accuracyTestResultsList %>% knitr::kable()



# Now we'll carry out the same steps as we did in model 1 except we'll run a 
# RPART (Recursive Partitioning And Regression Trees) analysis.

# The RPART analysis works by splitting the data into groups like a big 
# decision tree. It then makes its predictions per entry (or in our case,
# per employee) based upon where the predictors fall in its decision 
# tree path.

# Notice I'm allowing the model to pull from all the predictors available.
# When I tried to limit the model to only the most significant predictors,
# it returned a lower accuracy level.
model02 <- rpart(Attrition~.,data=trainingSet)
model02

model02 <- predict(model02,testingSet,type = "matrix")
model02

model02 <- as.vector(model02)
tibble(model02)

model02 <- roundBinary(model02)
model02


table(testingSet$Attrition,model02)

confusionMatrix(table(testingSet$Attrition,model02))

matrixModel02 <- accuracy(model02)
matrixModel02

matrixModel02$overall[1]
model02_Acc <- matrixModel02$overall[1]

# Even though the RPART model took a different approach and predicted true for some
# employees leaving (unlike the first model), it also has an accuracy level of 85.71429%.

cat(paste0("The second model also has ", model02_Acc*100, "% accuracy despite using a different approach."))

# Let's put this model into a list and start off our list of attempts:
accuracyTestResultsList <- bind_rows(accuracyTestResultsList,
                                     tibble(method = "RPART Model", Accuracy = model02_Acc))
accuracyTestResultsList %>% knitr::kable()



# Now we'll carry out the same steps as we did in model 2 except we'll run 
# a Generalized Linear Model analysis. This will run a logistic regression,
# analyzing the relationships between our predictors and what we are trying
# to predict in order to build an accurate model.
model03 <- glm(Attrition~.,data=trainingSet)
model03

model03 <- predict(model03,testingSet,type = "response")
model03

tibble(model03)
model03 <- as.vector(model03)

model03 <- roundBinary(model03)
model03


table(testingSet$Attrition,model03)

confusionMatrix(table(testingSet$Attrition,model03))

matrixmodel03 <- accuracy(model03)
matrixmodel03

matrixmodel03$overall[1]
model03_Acc <- matrixmodel03$overall[1]

# Our Generalized Linear Model reached 89.11565% accuracy, which is 
# higher than the previous models.

cat(paste0("The third model has ", model03_Acc*100, "% accuracy."))

# Let's put this model into a list and start off our list of attempts:
accuracyTestResultsList <- bind_rows(accuracyTestResultsList,
                                     tibble(method = "Generalized Linear Model", Accuracy = model03_Acc))


# Let's see our final results:
accuracyTestResultsList %>% knitr::kable()

# The Generalized Linear Model has the highest prediction accuracy 
# with 89.11565% accuracy.

cat("The Generalized Linear Model has the highest prediction accuracy of all the models, 
    with 89.11565% accuracy.")



#################  Conclusion  #################

# In this section I'll give a brief summary of the report, its limitations 
# and future work.

# I split the data into a training set (90% of data) to train the prediction models
# and a testing set (10% of data) to test the accuracy of the prediction model.

# When I tried to reach a higher accuracy level by using only some columns that 
# had proven to be significant in early tests, my accuracy actually decreased. So I let 
# each type of analysis decide for itself which predictors to include from the entire list.

# After running three prediction models, the highest accuracy obtained was 
# 0.8911565 or 89.11565%. Surpassing my goal of 88% prediction accuracy.

# The most effective prediction model was "Generalized Linear Model".

# I feel as though my report has some limitations. I could have taken more
# modeling approaches to potentially reach a higher prediction accuracy.

# I would like to improve this analysis in the future by finding some prediction
# model approaches that will give me a prediction accuracy of greater than 93%.

# Thank you for reading my report. I hope you enjoyed it.
#  - Avery Clark





