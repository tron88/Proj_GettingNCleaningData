library(data.table)   #Use data.table library

#> getwd() should show the following directory
# [1] "C:/Path/to/the/data/.../UCI HAR Dataset"
#setwd('data/UCI HAR Dataset/')  # Change to the appropriate working directory ... 

#Start reading the training and test data as data.tables
trainDT <- read.table("train/X_train.txt")   #Read in the training data set
testDT <- read.table("test/X_test.txt")      #Read in the test data set

trainlbl <- read.table("train/y_train.txt")  #Read in the activity label for the training set
testlbl <- read.table("test/y_test.txt")     #Read in the activity label for the test set

features <- read.table("../UCI HAR Dataset/features.txt") #Read in the features which will become the column names 
activitylbl <- read.table("./activity_labels.txt")

# Add column labels
colnames(testlbl) <-"Activity Label"  
colnames(trainlbl) <-"Activity Label"
colnames(activitylbl)<- c("Activity Label", "Type")

activitylbl<- data.table(activitylbl)
testlbl2 <- merge(testlbl, activitylbl, by="Activity Label", sort=FALSE)
trainlbl2 <- merge(trainlbl, activitylbl, by="Activity Label", sort=FALSE)
testlbl2 <- data.table(testlbl2)
trainlbl2 <- data.table(trainlbl2)

# Add column labels
colnames(testDT)<- features[,2]
colnames(trainDT)<- features[,2]

newtestDT <- cbind(testlbl2, testDT)         #Add the test activity label as the 1st column of test data
newtrainDT <- cbind(trainlbl2, trainDT)      #Add the training activity label as the 1st col of the training data
newtestDT <- data.table(newtestDT)
newtrainDT <- data.table(newtrainDT)

allDT <- rbind(newtrainDT,newtestDT)        #Combine both the training set and the test set
allDT <- data.table(allDT)                  #Cast into a data.table

setkey(allDT, "Activity Label"); setkey(activitylbl, "Activity Label")  #At this stage, both allDT and activitylbl gets sorted for key matching 

cvars <- colnames(allDT)                    #Collect col names for calculating the means and sds for each columns later 
cvars <- tail(cvars, -2)                    #Exclude the "Activity Label" column in the next calculation

allmeanDT <- allDT[, lapply(.SD, mean), .SDcols =cvars]         #Calculate the mean of each features (column) measurements
allsdDT   <- allDT[, lapply(.SD, sd), .SDcols =cvars]           #Calculate the sd of each features (column) measurements

allMeanByActDT <- allDT[, lapply(.SD, mean), .SDcols =cvars, by="Activity Label"]         #Extracts the mean of each features (cols) grouped by "Activity Label"
allsdByActDT   <- allDT[, lapply(.SD, sd), .SDcols =cvars, by="Activity Label"]           #Extracts the sd of each features (cols) grouped by "Activity Label"

write.table(allDT, file = "./alldata.txt", row.names=FALSE, col.names = TRUE)                #Write out combined test and training data set into one txt file
write.table(allmeanDT, file= "./allMean.txt", row.names=FALSE, col.names = TRUE)   #Write out mean data
write.table(allsdDT, file= "./allSD.txt", row.names=FALSE, col.names = TRUE)       #Write out sd data

write.table(allMeanByActDT, file= "./allMeanbyActivity.txt", row.names=FALSE, col.names = TRUE)   #Write out mean data for each Activity
write.table(allsdByActDT, file= "./allSDbyActivity.txt", row.names=FALSE, col.names = TRUE)       #Write out sd data for each Activity
