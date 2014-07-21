# This codebook describes the variables, the data, and any transformations to clean up the data.

#The data set characteristics can be described as multivariate, time series. There are 3 "categories" of feature data in both the training and test date sets described below. Note that the trailing '-XYZ' is used to denote 3-axial signals in the X, Y and Z directions. This totals to 561 feature attributes (columns). There is a total of 10299 instances (rows) -- when combining the test and training data set. 
# 1: time-domain those that begins with "t" with units in sec (e.g. tBodyAcc-XYZ for each of the X/Y/Z compnents, etc. ). 
# 2: freq-domain: Fast Fourier Transform (FFT) was applied to some of the time signals (e.g. fBodyAcc-XYZ, etc) with units in 1/s 
# 3: angle (e.g. angle(X,gravityMean), etc.) with units in radians


#Training and test data sets, activity labels, and features are read in as data tables from the following directory.
setwd('data/UCI HAR Dataset/')

trainDT <- read.table("train/X_train.txt")   #Read in the training data set
testDT <- read.table("test/X_test.txt")      #Read in the test data set
trainlbl <- read.table("train/y_train.txt")  #Read in the activity code for the training set
testlbl <- read.table("test/y_test.txt")     #Read in the activity code for the test set
features <- read.table("./features.txt")     #Read in the features which will become the column names 
activitylbl <- read.table("./activity_labels.txt") #Read in the decoder activity "Type" for the activity and its description: e.g. "a 5 means the activity type is STANDING, etc."

#Data tables columns are labeled accordingly: "Activity Label", "Type", "Features ..."
colnames(testlbl) <-"Activity Label"  
colnames(trainlbl) <-"Activity Label"
colnames(activitylbl)<- c("Activity Label", "Type")
colnames(testDT)<- features[,2]
colnames(trainDT)<- features[,2]

#Since the test and training activity data ("y_test.txt" and "y_train.txt") are number-coded, we first match them with the appropriate activity types ("activity_labels.txt") to make them human interpretable. This is done with the merge function but setting sort to "FALSE" since we still need to combine this label data sets with the features data sets. 

testlbl2 <- merge(testlbl, activitylbl, by="Activity Label", sort=FALSE)
trainlbl2 <- merge(trainlbl, activitylbl, by="Activity Label", sort=FALSE)


#The activity label tables are merged, accordingly, with its appropriate test and training data sets by a cbind function.
newtestDT <- cbind(testlbl2, testDT)         #Add the test activity label as the 1st column of test data
newtrainDT <- cbind(trainlbl2, trainDT)      #Add the training activity label as the 1st col of the training data

#Test and training data sets are combined by stacking them together using the rbind function. 
#At this point, we have a combined data set with columns appropriately labeled.
allDT <- rbind(newtrainDT,newtestDT)        #Combine both the training set and the test set

#Calculation of means and sds.
#Calculate all the features means and sds for the combined test and training data set. But first, we identify the features list
cvars <- colnames(allDT)                    #Collect col names for calculating the means and sds for each columns later 
cvars <- tail(cvars, -2)                    #Exclude the "Activity Label" column in the next calculation

allmeanDT <- allDT[, lapply(.SD, mean), .SDcols =cvars]         #Calculate the mean of each features (column) measurements
allsdDT   <- allDT[, lapply(.SD, sd), .SDcols =cvars]           #Calculate the sd of each features (column) measurements

#Calculate the features means and sds and grouped by "Activity Label" -- there will be 6 means and sds corresponding to the 6 activity types per features column. 
allMeanByActDT <- allDT[, lapply(.SD, mean), .SDcols =cvars, by="Activity Label"]         #Extracts the mean of each features (cols) grouped by "Activity Label"
allsdByActDT   <- allDT[, lapply(.SD, sd), .SDcols =cvars, by="Activity Label"]           #Extracts the sd of each features (cols) grouped by "Activity Label"


#Write out results to txt files ...
write.table(allDT, file = "./alldata.txt", row.names=FALSE, col.names = TRUE)                #Write out combined test and training data set into one txt file
write.table(allmeanDT, file= "./allMean.txt", row.names=FALSE, col.names = TRUE)   #Write out mean data
write.table(allsdDT, file= "./allSD.txt", row.names=FALSE, col.names = TRUE)       #Write out sd data
write.table(allMeanByActDT, file= "./allMeanbyActivity.txt", row.names=FALSE, col.names = TRUE)   #Write out mean data for each Activity
write.table(allsdByActDT, file= "./allSDbyActivity.txt", row.names=FALSE, col.names = TRUE)       #Write out sd data for each Activity

#Fin


