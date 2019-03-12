run_analysis<-function()
  
{
  #####################################################################################
  # The dataset used in this analysis is courtesy of:                                 #
  #                                                                                   #
  # [1] Davide Anguita, Alessandro Ghio, Luca Oneto, Xavier Parra and                 #
  # Jorge L. Reyes-Ortiz. Human Activity Recognition on Smartphones                   # 
  # using a Multiclass Hardware-Friendly Support Vector Machine.                      #
  # International Workshop of Ambient Assisted Living (IWAAL 2012).                   #
  # Vitoria-Gasteiz, Spain. Dec 2012                                                  #
  # This dataset is distributed AS-IS and no responsibility implied                   #
  # or explicit can be addressed to the authors or their institutions                 #
  # for its use or misuse. Any commercial use is prohibited.                          #   
  # Jorge L. Reyes-Ortiz, Alessandro Ghio, Luca Oneto, Davide Anguita. November 2012. #
  #####################################################################################
  
  #Load the necessairy libraries
  library(dplyr)
  library(tidyr)
  
  #Download the zip file required for the analysis
  download.file("https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip","Assignment.zip")
  
  #Get a file list from .zip file and name it "filelist"
  filelist<-unzip("Assignment.zip",list=TRUE)%>%
  
  #Select the "Name" column (Full file path) 
  select(Name)%>%
  #Create a temporary column by extracting the file name from the "Name" column 
  mutate(temp=basename(Name))%>%
  #Create a folder called "Path" which extracts the filepath from the "Name" column
  mutate(Path=dirname(Name))%>%
    
  #Filter the "temp" column and only keep ".txt" files.
  filter(grepl("txt",temp))%>% 
  #Create a column for variable name from the temp folder by removing the ".txt" extansion.
  mutate(Varnames=gsub(".txt","",temp))%>%
  #Create "Folder" column from "Path" column.  Extract only name of the folder that contains the files.
  mutate(Folder=sub('.*/','',Path))%>%
    
  #select all but "temp" column.  Remove "README" and "features_info" files.  They are not used in this analysis.
  #the result is a table with filenames to extract and a list of variable names to call them.  
  select(-temp,-Path)%>%filter(Varnames!="README" & Varnames!="features_info" & Folder!="Inertial Signals")
  
  #Loop through the "filelist" names and import the files from the "Name" column and 
  #name the data frames using the "Varnames" column.
  for (i in 1:nrow(filelist)) {
      assign(filelist[i,2],read.delim(unzip("Assignment.zip",filelist[i,1]),header = FALSE, sep=""))
  }

  #Concatenate the columns in the features dataframe.  This makes all entries unique and avoids errors later
  features<-unite(features,V1)
  
  #Change the column names of the "X_test" dataframe using the features list.
  colnames(X_test)<-features$V1
  #Add the subject row to identify which person did the activity and add the activity row
  #to show which activity was performed.  Add a "TestTrain" column to identify which 
  #subset the data came from.  This creates a tidy dataset
  X_test<-X_test%>%mutate(Subject=subject_test$V1)%>%mutate(Activity2=y_test$V1)%>%mutate(TestTrain="Test")
  
  #Change the column names of the "X_train" dataframe using the features list.
  colnames(X_train)<-features$V1
  #Add the subject row to identify which person did the activity and add the activity row
  #to show which activity was performed.  Add a "TestTrain" column to identify which 
  #subset the data came from.  This creates a tidy dataset
  X_train<-X_train%>%mutate(Subject=subject_train$V1)%>%mutate(Activity2=y_train$V1)%>%mutate(TestTrain="Train")
  
  #Change the activity labels column names.
  colnames(activity_labels)=c("V1","Activity")
  
  #Append the X_test and X_train datasests.  Not that the "TestTrain" Column allows us to 
  #distinguish between the test and train datasets.
  Data<-rbind(X_test,X_train)
  #Replace the activity numerical labels with the named labels.
  Data<-left_join(Data,activity_labels,by=c("Activity2"="V1"))
  
  #Select all columns in the dataset that contain "Mean", mean()" or "std()". Includes the averages 
  #of the angle() variables.
  Data<-Data%>%select(Subject,Activity,TestTrain,contains("mean()"),contains("std()"),contains("Mean"))
  
  #Aggregate the dataset by subject and activity to obtain an average for each group.
  GroupedData<-Data%>%select(-TestTrain)%>%group_by(Subject,Activity)%>%summarise_all(list(mean))
  
  #Export the data as a text file.
  write.table(GroupedData,"GroupedData.txt")

}
