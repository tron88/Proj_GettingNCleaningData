Proj_GettingNCleaningData
=========================

Course programming project for Getting and Cleaning Data.  
See details here: https://class.coursera.org/getdata-005/human_grading/view/courses/972582/assessments/3/submissions

#Contents
The directory contains the following files:
README.md  -- this file
CodeBook.md -- description of the tasks the run_analysis.R script does in getting the final data statistics. 
run_analysis.R -- the R script
allMean.txt  -- output data for the means of all features for the combined test and training data
allSD.txt    -- output data for the sds of all features for the combined test and training data
allMeanbyActivity.txt -- output data for the means of all features for the combined test and training data and grouped by activity types
allSDbyActivity.txt -- output data for the sds of all features for the combined test and training data and grouped by activity types


##For completeness, the key tasks in the run_analysis.R script are again described below.

### Use data.table by performing a library load:  
library(data.table)

### Change to the right working directory if necessary such that when one does
###> getwd() # this should show the following directory
### [1] "C:/Path/to/the/data/.../UCI HAR Dataset"
###setwd('data/UCI HAR Dataset/')  # Or change to the appropriate working directory ... 

###Start reading the training and test data as data.tables
trainDT <- read.table("train/X_train.txt")   #Read in the training data set
testDT <- read.table("test/X_test.txt")      #Read in the test data set

trainlbl <- read.table("train/y_train.txt")  #Read in the activity label for the training set
testlbl <- read.table("test/y_test.txt")     #Read in the activity label for the test set

features <- read.table("./features.txt") #Read in the features which will become the column names 
activitylbl <- read.table("./activity_labels.txt")

### Add the column labels
colnames(testlbl) <-"Activity Label"  
colnames(trainlbl) <-"Activity Label"
colnames(activitylbl)<- c("Activity Label", "Type")

activitylbl<- data.table(activitylbl)
testlbl2 <- merge(testlbl, activitylbl, by="Activity Label", sort=FALSE)
trainlbl2 <- merge(trainlbl, activitylbl, by="Activity Label", sort=FALSE)
testlbl2 <- data.table(testlbl2)
trainlbl2 <- data.table(trainlbl2)

colnames(testDT)<- features[,2]
colnames(trainDT)<- features[,2]

newtestDT <- cbind(testlbl2, testDT)         #Add the test activity label as the 1st column of test data
newtrainDT <- cbind(trainlbl2, trainDT)      #Add the training activity label as the 1st col of the training data
newtestDT <- data.table(newtestDT)
newtrainDT <- data.table(newtrainDT)

###Combine the test and training data set into one
allDT <- rbind(newtrainDT,newtestDT)        #Combine both the training set and the test set
allDT <- data.table(allDT)                  #Cast into a data.table

###Prepare for computing the means and sds for each column "features"
setkey(allDT, "Activity Label"); setkey(activitylbl, "Activity Label")  #At this stage, both allDT and activitylbl gets sorted for key matching 
cvars <- colnames(allDT)                    #Collect col names for calculating the means and sds for each columns later 
cvars <- tail(cvars, -2)                    #Exclude the "Activity Label" column in the next calculation

###For each features calculate the mean/average and the sd 
allmeanDT <- allDT[, lapply(.SD, mean), .SDcols =cvars]         #Calculate the mean of each features (column) measurements
allsdDT   <- allDT[, lapply(.SD, sd), .SDcols =cvars]           #Calculate the sd of each features (column) measurements

###Calculating the means and sds but now grouped by "Activity"
allMeanByActDT <- allDT[, lapply(.SD, mean), .SDcols =cvars, by="Activity Label"]         #Extracts the mean of each features (cols) grouped by "Activity Label"
allsdByActDT   <- allDT[, lapply(.SD, sd), .SDcols =cvars, by="Activity Label"]           #Extracts the sd of each features (cols) grouped by "Activity Label"


###Write out the combined data and the features mean data and features sd data (one file each)
write.table(allDT, file = "./alldata.txt", row.names=FALSE, col.names = TRUE)                #Write out combined test and training data set into one txt file
write.table(allmeanDT, file= "./allMean.txt", row.names=FALSE, col.names = TRUE)   #Write out mean data
write.table(allsdDT, file= "./allSD.txt", row.names=FALSE, col.names = TRUE)       #Write out sd data

write.table(allMeanByActDT, file= "./allMeanbyActivity.txt", row.names=FALSE, col.names = TRUE)   #Write out mean data for each Activity
write.table(allsdByActDT, file= "./allSDbyActivity.txt", row.names=FALSE, col.names = TRUE)       #Write out sd data for each Activity


#FIN
