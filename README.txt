README for run_analysis.R script

Files included in this analysis:

"Code Book.txt" - Code book describing the underlying data

"run_analysis.R" - Script that carries out the analysis

Funciton of Script:

The downloaded data is loaded by the "Run_analysis.R" script.
The script merges the test and train data into a single tidy dataset,
extracts only the measurements on the mean and standard deviation for each measurement,
uses descriptive activity names to name the activities in the data set,
appropriately labels the data set with descriptive variable names,
creates a second, independent tidy data set with the average of each variable for each activity and each subject.

The script writes an output file called "GroupedData.txt" to the working directory.