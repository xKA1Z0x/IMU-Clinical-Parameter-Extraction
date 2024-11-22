The code 'main_STARS_Inpatient_Step03_XSens_GaitSegmentation_v2' should be used to segment the gait information into single strides. The code is inputting the #patientName#_#taskName#_Extracted.mat structs and creating a #patientName#_#taskName#_Segmented.mat
For more detail on the code steps and how the code is interacting with the user, please refer to the pptx presentation 'Segmentation.pptx'.

In the file 'code_versions_logging.txt' a list of the differences between this code and the previous versions is provided.

Some important points to keep in mind:

1. The main code is also calling a set of functions. Some more related to procedural steps are 'fix_peaks.mat' and 'spreadfigures.mat'. Some more related to the gait segmentation itself are contained in the folder 'additional functions'. In line 28. the path with these additional functions is added.

2. The code is entering the specific P2C \ Jungle data\folders architecture, i.e., #condition##participant##task#\Sensor Data\Xsens. It is also flexible to the following possible architectures, #condition##participant##task#\Sensor_Data\Xsens or #condition##participant##task#\Xsens. However, if the architectrure type is different than one of these, you should modify the initial for cycles of the code (lines 42-64). Otherwise, the REMOTE VERSION code is also free from such architecture.

3. All variables that the user could possibly change are stored in the initial 'Control Panel' section. These are:

specific_cond _ string or vector of strings  %write here specific folder of conditions you want this code to process
specific_part _ string or vector of strings  %write here specific folder of participants you want this code to process
specific_tasks _ string or vector of strings %write here specific folder of tasks or trials you want this code to process

pattern_gait_tasks _ string or vector of strings %list of patterns contained in the task names that identify gait patterns (those over which the execution of this code makes sense) if specific tasks need to be avoided, this variable could be used

initial_folder _ string  % path direct the code to the specific specific data folder, if placed to an empty string, the code will ask the user to manually select such folder (example for P2C dataset is "Y:\P2C\P2C_Database_Segmented - Database paper version")
Hz _ integer % sampling frequency of the signals
cutoff_HPF  _ integer  %cutoff frequency of the high-pass filter, to remove the drift from the foot vertical position signal
order_HPF  _integer   %order of the high-pass filter, to remove the drift from the foot vertical position signal

verbosity _ 0/1 integer %flag for turning on and off the verbosity of the code. 0=the code is not outputting any info; 1= the code is providing info on the portion under processing, 0=otherwise
plot_verbosity _ 0/1 integer %flag for turning on and off extra plots to check the processing of the code; 1= the code is providing the extra plots, 0=otherwise
