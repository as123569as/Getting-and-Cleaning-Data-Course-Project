library(reshape2)
library(dplyr)
## Create and set working directory:
if (!file.exists("Project Data")){
   dir.create("Project Data")
   setwd("./Project Data")
}

## Download the dataset:
if (!file.exists("dataset.zip")){
   fileURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
   download.file(fileURL,"dataset.zip")
}

## Unzip the dataset:
if (!file.exists("UCI HAR Dataset")) { 
   unzip("dataset.zip") 
}

# Import activity labels and features:
activitylabels <- read.table("UCI HAR Dataset/activity_labels.txt")
features <- read.table("UCI HAR Dataset/features.txt")

# Extract only the data on mean and standard deviation:
features_mean_std_item <- grep(".*mean.*|.*std.*", features[,2])  #pick the items that contain "mean" and "std"
features_mean_std_names <- features[features_mean_std_item,2]     #select the features that contain "mean" and "std"

# Import the train datasets:
train <- read.table("UCI HAR Dataset/train/X_train.txt")[features_mean_std_item]
trainActivities <- read.table("UCI HAR Dataset/train/Y_train.txt")
trainSubjects <- read.table("UCI HAR Dataset/train/subject_train.txt")
train <- cbind(trainSubjects, trainActivities, train)

# Import the test datasets:
test <- read.table("UCI HAR Dataset/test/X_test.txt")[features_mean_std_item]
testActivities <- read.table("UCI HAR Dataset/test/Y_test.txt")
testSubjects <- read.table("UCI HAR Dataset/test/subject_test.txt")
test <- cbind(testSubjects, testActivities, test)

# merge datasets and add labels:
TotalData <- rbind(train, test)
colnames(TotalData) <- c("subject", "activity", as.character(features_mean_std_names))
TotalData$activity <- factor(TotalData$activity, levels = activitylabels[,1], labels = activitylabels[,2])

# Use pipe to calculate the mean of each variable:
TotalData_mean <- TotalData %>%
                  melt(id = c("subject", "activity")) %>%
                  dcast(subject + activity ~ variable, mean)

# Export the result into txt file:
write.table(TotalData_mean, "tidy.txt", row.names = FALSE, quote = FALSE)
