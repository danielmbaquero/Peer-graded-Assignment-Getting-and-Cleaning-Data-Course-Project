
## Load the neccesary libraries
library(dplyr)

## Set the paths for all necesary files
## Read the data sets and load them to data frames
trainPath <- "./UCI HAR Dataset/train/X_train.txt"
trainActivityPath <- "./UCI HAR Dataset/train/y_train.txt"
testPath <- "./UCI HAR Dataset/test/X_test.txt"
testActivityPath <- "./UCI HAR Dataset/test/y_test.txt"
collabelsPath <- "./UCI HAR Dataset/features.txt"
activityDescPath <- "./UCI HAR Dataset/activity_labels.txt"
train <- read.table(trainPath)
trainActivity <- read.table(trainActivityPath)
test <- read.table(testPath)
testActivity <- read.table(testActivityPath)
activityDesc <- read.table(activityDescPath)
collabels <- read.table(collabelsPath)
collabels <- gsub("meanFreq", "NO", collabels$V2)


## Merge both the train and test data 
## Put labels to the data frame
allData <- rbind(train, test)
allActivity <- rbind(trainActivity, testActivity)
allData <- cbind(allActivity, allData)
names(allData) <- c("activity", collabels)


##Extract anly the means and stds for each measurement
col_means <- grepl("mean",names(allData))
col_std <- grepl("std", names(allData))
activity_name <- names(allData) == "activity"
my_data <- allData[,col_means|col_std|activity_name]


## Give descriptive name for the activities
my_data <- mutate(my_data, activity = gsub(activityDesc[1,1], activityDesc[1,2], my_data$activity))
my_data <- mutate(my_data, activity = gsub(activityDesc[2,1], activityDesc[2,2], my_data$activity))
my_data <- mutate(my_data, activity = gsub(activityDesc[3,1], activityDesc[3,2], my_data$activity))
my_data <- mutate(my_data, activity = gsub(activityDesc[4,1], activityDesc[4,2], my_data$activity))
my_data <- mutate(my_data, activity = gsub(activityDesc[5,1], activityDesc[5,2], my_data$activity))
my_data <- mutate(my_data, activity = gsub(activityDesc[6,1], activityDesc[6,2], my_data$activity))


## Use descriptive variable names
{my_data_names <- names(my_data) %>% gsub(
    pattern = "^t", replacement = "time ") %>% gsub(
        pattern = "^f", replacement = "frequency ") %>% gsub(
            pattern = "Acc", replacement = " accelerometer ") %>% gsub(
                pattern = "Gyro", replacement = " gyroscope ") %>% tolower()}
names(my_data) <- my_data_names
my_data <- tbl_df(my_data)

### Create and independent data set

## Seth necessary paths, read and load the files
subject_trainPath <- "./UCI HAR Dataset/train/subject_train.txt"
subject_testPath <- "./UCI HAR Dataset/test/subject_test.txt"
subject_train <- read.table(subject_trainPath)
subject_test <- read.table(subject_testPath)

## Merge subjects from test and train
subject <- rbind(subject_train, subject_test)

## Create new tidy dataset
new_tidy <- mutate(my_data, subjectID = subject[,1])
new_tidy$activity <- as.factor(new_tidy$activity)
new_tidy$subjectID <- as.factor(new_tidy$subjectID)
new_tidy <- group_by(new_tidy, activity, subjectID)
new_tidy <- summarise_all(new_tidy, mean)
