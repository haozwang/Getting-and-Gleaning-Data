# download the raw data file, name it as data.zip, then extract the file

if (file.exists("data.zip")==FALSE) {
  fileURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
  download.file(fileURL,destfile = "data.zip")
  unzip(data.zip)
}

setwd("./UCI HAR Dataset")

# read all the necessary data files and store them with appropriate names

id_train <-read.csv("./train/subject_train.txt", header = FALSE, sep="")
activity_train <-read.csv("./train/y_train.txt", header = FALSE, sep="")
data_train <- read.csv("./train/X_train.txt", header = FALSE, sep="")

id_test <-read.csv("./test/subject_test.txt", header = FALSE, sep="")
activity_test <-read.csv("./test/y_test.txt", header = FALSE, sep="")
data_test <- read.csv("./test/X_test.txt", header = FALSE, sep="")

features_labels <- read.csv("features.txt", header = FALSE, sep="")



activity_labels <-read.csv("activity_labels.txt", header = FALSE, sep="")
activity_labels[,2]<-levels(activity_labels[,2]) # remove factor levels

# merge test and training data

id<-rbind(id_test,id_train)

data<-rbind(data_test,data_train)

activity<-rbind(activity_test,activity_train)


# Apply column names according to the features file

names(id)<-"id"
colnames(activity)<-"activity"

colnames(data)<-features_labels[,2]


# only keep the columns with heading name mean() or std()

mean_cols <- grep("mean()",features_labels[,2])
std_cols <- grep("std()",features_labels[,2])
keep_col<-c(mean_cols,std_cols)

keep_col<- sort(keep_col) # Keep only these column numbers in the data matrix

keep_data <- data[,keep_col]



# name the activities in the dataset


for (i in 1:10299) {
  activity[i,1] <- activity_labels[activity[i,1],2]
}



# Generate final table with the following structure


############################################
## subject_id ### activity ### other data ##
############################################

df<-data.frame(id, activity, keep_data) # generate final data set



############################################
# create second dataframe for step 5



#make a new dataframe

df_2<-matrix(1,180,81)
df_2<-data.frame(df_2)
names(df_2) <-names(df)


merged<- cbind(df, paste(df$id, df$activity, sep=";")) #create an index to average the data


# calculate the average of each of the columns based on id and activity

for (i in 3:81) {
  
  df_2[,i] = unname(tapply(merged[,i],merged[,82],mean))

}


df_names<-names(tapply(merged[,3],merged[,82],mean))#this grabs the ordering of the index

# split the index name to 2 columns
df_names=strsplit(df_names, ";")
df_names = unlist(df_names)

df_2[,1] = df_names[seq(1,360,2)]
df_2$id<-as.numeric(df_2$id)


df_2[,2] = df_names[seq(2,360,2)]



df_2<- df_2[order(df_2$id,df_2$activity),] # sort the df_2 by id, then by activity.


# save df_2 as a text file
write.table(df_2,file="step5.txt",row.names = FALSE)


# clean up

rm(list= ls()[!(ls() %in% c('df', "df_2"))]) # remove everything except df and df_2

