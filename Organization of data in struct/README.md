The code 'main_Xsens_csv2mat.m' should be used to reorganize the csv files exported from the sensors into a matlab struct that could be fed to the segmentation and parameters calculation codes. 
For a graphical / visual explanation of the process, please refer to the pptx presentation 'Data_reorganization.pptx'

More specifically, the code transfers the information content from the csv files extracted from sensors to a #patientName#_#taskName#_Extracted.mat file. The specific csv files needed are the following:

sensorFreeAcceleration.csv
acceleration.csv
angularVelocity.csv
jointAngle.csv
orientation.csv
position.csv
velocity.csv

Some important points to keep in mind:

1. The main code is also calling a the funtion called 'extract_columns_v2.m', which is extracting only the time columns and the actual information content of each csv file
   The function has also a previous version, extracting only a limited infromation from the files (e.g., upper limb is not extracted). Refer to 'extract_columns.m', 'code_versions_logging.txt', and 'columns_name_legend.txt' to access the code for a restricted extraction, a logging file with the main differences between the codes, and the specific columns extracted by the code, respectively. To be noted: the restricted file version is not performing the JointAngle axes renaming (see point 5)

2. Upon activation (using the flag need_quat2eul_conversion), the code is enabling a function called 'orientation_conversion.m', which is converting the quaternions into the euler angles, in case the euler angles are not directly available form the sensor export

3. In the case of the JointAngle.csv file, a type was discovered in the P2C and Jungle datasets. In fact, the direct export of the sensor is reporting as coorinates the movements of the joints, not the axis, i.e.,flexion/extension, adduction/abduction, and internal/external rotation. In an intermediate process, these moevement were erroneously allocated to the axes coordinates. Hence, an axis inversion is perormed between lines 135-143 of the code. If this is not a typo present in your dataset, make sure to comment these lines
  
4. The global coordinate system of the sensors is the following: z - vertical axis, x - axis in the direction of walk (antero-posterior), y - medio-lateral

5. The code is entering the specific P2C \ Jungle data\folders architecture, i.e., #condition#\#participant#\#task#\Sensor Data\Xsens. It is also flexible to the following possible architectures, #condition#\#participant#\#task#\Sensor_Data\Xsens or #condition#\#participant#\#task#\Xsens. However, if the architectrure type is different than one of these, you should modify the initial for cycles of the code (lines 42-62)

6. All variables that the user could possibly change are stored in the initial 'Control Panel' section. These are:

avoid_cond _ string or vector of strings  %write here specific folder of conditions you do not want this code to process
avoid_part _ string or vector of strings  %write here specific folder of participants you do not want this code to process
avoid_tasks _ string or vector of strings %write here specific folder of tasks or trials you do not want this code to process

initial_folder _ string %path where all the data is stored (for P2C this is the folder "Y:\P2C\P2C_Database_Segmented - Database paper version") in case this is provided as an empty string, the code will require the user interaction and the manual selection of such folder

verbosity _ 0/1 integer %flag for turning on and off the verbosity of the code. 0=the code is not outputting any info; 1= the code is providing info on the portion under processing

need_quat2eul_conversion _ 0/1 integer   %0/1 flag activating or not the conversion from quaternions to euler angles
orientation_type='XYZ' _string  %gloabl orientation of the P2C / Jungle databases (Xsens based)

