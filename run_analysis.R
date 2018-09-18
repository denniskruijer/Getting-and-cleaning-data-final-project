# Download and unpackage data (step 0):
library(dplyr)

if(!file.exists("./data")){
    dir.create("./data")
}

url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(url, destfile = "./data/UCIdata.zip", method = "curl")

if(!file.exists("./data")){
    unzip("./data/UCIdata.zip")
}

# Create readable tables:
features <- read.table("/Users/denniskruijer/Desktop/R/UCI HAR Dataset/features_info.txt", col.names = c("n", "functions"))
activity <- read.table("/Users/denniskruijer/Desktop/R/UCI HAR Dataset/activity_labels.txt", col.names = c("code", "activity"))

subject_test <- read.table("/Users/denniskruijer/Desktop/R/UCI HAR Dataset/test/subject_test.txt", col.names = "subject")
X_test <- read.table("/Users/denniskruijer/Desktop/R/UCI HAR Dataset/test/X_test.txt", col.names = features$functions)
y_test <- read.table("/Users/denniskruijer/Desktop/R/UCI HAR Dataset/test/y_test.txt", col.names = "code")

subject_train <- read.table("/Users/denniskruijer/Desktop/R/UCI HAR Dataset/train/subject_train.txt", col.names = "subject")
X_train <- read.table("/Users/denniskruijer/Desktop/R/UCI HAR Dataset/train/X_train.txt", col.names = features$functions)
y_train <- read.table("/Users/denniskruijer/Desktop/R/UCI HAR Dataset/train/y_train.txt", col.names = "code")

# Merge the data into one table (step 1):

subject <- rbind(subject_test, subject_train)
X <- rbind(X_test, X_train)
y <- rbind(y_test, y_train)
all_data <- cbind(subject, X, y)

str(all_data)
dim(all_data)
summary(all_data)

# Extract measurements of mean and standard deviation (step 2):

clean_data <- all_data %>% select(subject, code, contains("mean"), contains("std"))

# Use descriptive activity names to name the activities in the data set (step 3):

clean_data$code <- activity[clean_data$code, 2]

# Appropriately label the data set with descriptive variable names (step 4):

head(clean_data)
summary(clean_data)

names(clean_data)[2] = "activity"
names(clean_data) <- gsub("Acc", "Accelerometer", names(clean_data))
names(clean_data) <- gsub("Gyro", "Gyroscope", names(clean_data))
names(clean_data) <- gsub("BodyBody", "Body", names(clean_data))
names(clean_data) <- gsub("Mag", "Magnitude", names(clean_data))
names(clean_data) <- gsub("^t", "Time", names(clean_data))
names(clean_data) <- gsub("^f", "Frequency", names(clean_data))
names(clean_data) <- gsub("tBody", "TimeBody", names(clean_data))
names(clean_data) <- gsub("-mean()", "Mean", names(clean_data))
names(clean_data) <- gsub("-std()", "STD", names(clean_data))
names(clean_data) <- gsub("-freq()", "Frequency", names(clean_data))

clean_data

# From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject (Step 5):

new_data <- clean_data %>%
    group_by(subject, activity) %>%
    summarise_all(funs(mean))
write.table(new_data, "new_data.txt", row.name=FALSE)

str(new_data)
summary(new_data)
head(new_data)