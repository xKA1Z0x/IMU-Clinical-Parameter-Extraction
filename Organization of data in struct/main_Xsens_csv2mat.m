clc
clear all
%script needed to convert csv export from Xsens into a .mat struct that
%could be easily read by the segmentation code by FL (source:
%\\fs2.smpp.local\RTO\STARS\Inpatient Study\Analysis\STARS_Inpatient_Step03_XSens_GaitSegmentation_v1)
%this cose is working on the infrastructure of the P2C data prepared for
%the database paper (\\fs2\RTO\P2C\P2C_Database_Segmented - Database paper
%version), i.e. condition--participant--task&trial--data source--files

%a .mat file will be saved in each specific path(condition--participant--task&trial--data source)
%additionally, an excel incomplete_data file will be saved in the same folder of the cose

%% control panel - settings
avoid_cond=["Control", "LL", "PD"];  %write here specific folder of conditions you do not want this code to process
avoid_part=["CVA01", "CVA02", "CVA03", "CVA04", "CVA05", "CVA06", "CVA07", "CVA08", "CVA09", "CVA10", "CVA12", "CVA13", "CVA14", "CVA15", "CVA17", "CVA11", "CVA18", "CVA19", "CVA20", "CVA21", "CVA22", "CVA23", "CVA24", "CVA25", "CVA26", "CVA27", "CVA28", "CVA29"];  %write here specific folder of participants you do not want this code to process
avoid_tasks=[""];  %write here specific folder of tasks or trials you do not want this code to process

need_quat2eul_conversion=0;   %0/1 flag activating or not the conversion from quaternions to euler angles
orientation_type='XYZ';  %gloabl orientation of the P2C / Jungle databases (Xsens based)

label_inversion=1;  %0/1 flag activating or not the inversion of the labels in the joint angle data

file_sheet="s"; % if "f", it means the data is derived from different files, one for each data type (AJ, V, ACC, ...). if "s", it means there is a unique excel file with multiple sheets
if file_sheet=="s"
    need_quat2eul_conversion=0;
    label_inversion=0;
end

%P2C
initial_folder= "Z:\P2C\P2C_Database_Segmented - Database paper version";
%initial_folder="\\fs2\RTO\P2C\P2C_Database_Segmented - Database paper version"; %direct the code to a specific folder, without interactively ask to the user
%Jungle
% initial_folder="\\fs2\RTO\P2C\Amazon Data\General_Movement_Dataset";
verbosity=1; %flag for turning on and off the verbosity of the code. 0=the code is not outputting any info; 1= the code is providing info on the portion under processing
%% positioning in the proper folder and selecting the files
addpath('\\fs2.smpp.local\rto\STARS\Inpatient Study\Analysis\Matlab_function');

folderanalysis      = cd();   	% Folder path to the scripts for analysis
if initial_folder==""
    subjtoload      = uigetdir('Select the folder with the data');	% Selection of the subject to analyze
else subjtoload= initial_folder;
end
cd(subjtoload)

conditions=dir(subjtoload);
incomplete_data=[];
list_files=["orientation.csv","velocity.csv", "angularVelocity.csv", "sensorFreeAcceleration.csv", "acceleration.csv", "jointAngle.csv", "position.csv" ];

%% nesting in the data architecture
xsens_ord=[];
lab=[];

for c=1:length(conditions) %for each condition folder available
    c_name=conditions(c).name;
    if ~contains(c_name, '.') && isempty(find(avoid_cond==string(c_name)))  %check that the file name c_name is a folder for the conditions and not sparse files with .xxx extension + check that only the desired consitions are selected
        if verbosity==1
            fprintf("Processing condition: " + c_name);
        end
        c_folder=conditions(c).folder;
        cd(strcat(c_folder, "\", c_name))
        participants=dir(cd);
        for p=1:length(participants)
            p_name=participants(p).name;
            if ~contains(p_name, '.') && isempty(find(avoid_part==string(p_name))) %check that the file name p_name is a folder for the participant and not sparse files with .xxx extension + check that only the desired participants are selected
                if verbosity==1
                    fprintf("\n Processing participant: " + p_name);
                end
                p_folder=participants(p).folder;
                cd(strcat(p_folder, "\", p_name))
                tasktrials=dir(cd);
                for tt=1:length(tasktrials) %for each of the files contained
                    tt_name=tasktrials(tt).name;
                    if ~contains(tt_name, '.') && isempty(find(avoid_tasks==string(tt_name))) %check that the file name tt_name is a folder for the participant and not sparse files with .xxx extension + check that only the desired tasks and trials are selected
                        if verbosity==1
                            fprintf("\n Processing task and trial: " + tt_name);
                        end
                        tt_folder=tasktrials(tt).folder;
                        if isdir(strcat(tt_folder, "\", tt_name, "\Sensor Data\Xsens"))
                            cd(strcat(tt_folder, "\", tt_name, "\Sensor Data\Xsens"))
                        elseif isdir(strcat(tt_folder, "\", tt_name, "\Sensor_Data\Xsens"))
                            cd(strcat(tt_folder, "\", tt_name, "\Sensor_Data\Xsens"))   
                        else cd(strcat(tt_folder, "\", tt_name, "\Xsens"))
                        end
                        sensors=dir(cd);
                        
                        %check for presence of all the data files
                        if length(sensors)<2 && file_sheet=="f"
                            if verbosity==1
                                fprintf("\n Incomplete data");
                            end
                            incomplete_data=[incomplete_data; [string(cd), "all files"]];
                        else
                            sum_missing=7;
                            who="";  %I write here the files that are found
                            for j=1:length(sensors)
                                if ~isempty(find(list_files==string(sensors(j).name)))
                                    sum_missing=sum_missing-1;
                                    who=[who; list_files(find(list_files==string(sensors(j).name)))];
                                end
                            end
                            if sum_missing>0 && file_sheet=="f" %case in which some of the data files are missing
                                if verbosity==1
                                    fprintf("\n Incomplete data");
                                end
                                incomplete_data=[incomplete_data; [string(cd), join(who, " - ")]];
                            else
                                if file_sheet=="s"
                                    fileInfo = dir(fullfile(pwd, '*.xlsx'));
                                end

                                %adding position to the struct
                                if file_sheet=="f"
                                    filename="position.csv"; 
                                    sheet="";
                                else
                                    sheet="Segment Position";
                                    filename=fileInfo.name;
                                end
                                 
                                col_interest=["Pelvis_x", "Pelvis_y", "Pelvis_z", "RightFoot_x", "RightFoot_y", "RightFoot_z", "LeftFoot_x", "LeftFoot_y", "LeftFoot_z"];
                                addpath (folderanalysis)
                                [time, data_extracted, labels]=extract_columns_v2(filename, sheet, file_sheet, col_interest, verbosity);
                                xsens_ord.time=time;
                                xsens_ord.Pos=data_extracted;
                                lab.Pos=labels;
                                
                                %adding joint angles to the struct
                                if file_sheet=="f"
                                    filename="jointAngle.csv"; 
                                    sheet="";
                                else
                                    sheet="Joint Angles XZY";
                                    filename=fileInfo.name;
                                end

                                col_interest=["jL5S1_x", "jL5S1_y", "jL5S1_z", ...
                                    "jRightHip_x", "jRightHip_y",	"jRightHip_z",	"jRightKnee_x",	"jRightKnee_y",	"jRightKnee_z",	"jRightAnkle_x", "jRightAnkle_y", "jRightAnkle_z", ...
                                    "jLeftHip_x", "jLeftHip_y",	"jLeftHip_z",	"jLeftKnee_x",	"jLeftKnee_y",	"jLeftKnee_z",	"jLeftAnkle_x",	"jLeftAnkle_y",	"jLeftAnkle_z"];
                                addpath (folderanalysis)
                                [time, data_extracted, labels]=extract_columns_v2(filename, sheet, file_sheet, col_interest, verbosity);
                                
                                %adding orientation to the struct
                                if file_sheet=="f"
                                    filename="orientation.csv";
                                    sheet="";
                                else
                                    sheet="Segment Orientation - Euler";
                                    filename=fileInfo.name;
                                end
                                 
                                col_interest=["PelvisX", "PelvisY", "PelvisZ", "L5X", "L5Y", "L5Z", ...
                                    "RightUpperLegX", "RightUpperLegY", "RightUpperLegZ", "RightFootX",	"RightFootY",	"RightFootZ", "RightLowerLegX", "RightLowerLegY", "RightLowerLegZ", ...
                                    "LeftUpperLegX", "LeftUpperLegY", "LeftUpperLegZ", "LeftFootX",	"LeftFootY",	"LeftFootZ", "LeftLowerLegX", "LeftLowerLegY", "LeftLowerLegZ"];
                                addpath (folderanalysis)
                                if need_quat2eul_conversion==1
                                    filename_new= orientation_conversion(filename,orientation_type);
                                else filename_new=filename;
                                end
                                [time, data_extracted, labels]=extract_columns_v2(filename_new, sheet, file_sheet, col_interest, verbosity);
                                xsens_ord.Q=data_extracted;
                                lab.Q=labels;
                                
                                %%%%%%%%%%%%%part for the pelvis _ source: \\fs2.smpp.local\rto\STARS\Inpatient Study\Analysis\main_STARS_Inpatient_Step01c_XSens_Import_v5.m%%%%%%%%%%
                                % To get the foot trajectory w.r.t Pelvis
                                ori=xsens_ord.Q; %readmatrix("orientation.csv");
%                                 ori_tab=readtable("orientation.csv");
                                ori_tab_names=string(lab.Q);
                                if ori_tab_names(2)=="time" && ori_tab_names(3)=="ms"
                                    ori=ori(:,4:end);
                                end
                                position=readmatrix("position.csv");
                                clear Pel
                                for k = 1:length(time)
                                    q_PE_init   = quaternion((ori(1,1:4)));         % Pelvis quaternion at start
                                    q_PE        = quaternion(ori(k,1:4));           % Pelvis quaternion at instant k
                                    q_Pel(k,:)  = times(conj(q_PE_init),q_PE);      % Projection of the pelvis on the init one
                                    Pel(k,:)    = EulerAngles(q_Pel(k,:),'123')';   % Euler angles for orientation of pelvis
                                end
                                % Correct discontinuous signal near -+180 degree in pelvis rotation
                                Pel(:,3) = pelvis_correct(Pel(:,3));
                                xsens_ord.JA=[(Pel(:,:)*180/pi), data_extracted];
                                labels=["Pelvis_x", "Pelvis_y", "Pelvis_z", labels];
                                
                                %%%PART ONLY FOR P2C DATASET, WITH COLUMN NAME CHANGE
                                %deactivate the flag if this problem does not apply
                                if label_inversion==1
                                    old_labels=labels;
                                    oldy=find(endsWith(old_labels,"_y")==1);
                                    oldz=find(endsWith(old_labels,"_z")==1);
                                    labels(oldy)=replace(labels(oldy), "_y", "_z");
                                    labels(oldz)=replace(labels(oldz), "_z", "_y");
                                end
                                %%%%%%%
                                lab.JA=labels;
                                
                                %adding acceleration to the struct
                                if file_sheet=="f"
                                    filename="acceleration.csv"; 
                                    sheet="";
                                else
                                    sheet= "Segment Acceleration";
                                    filename=fileInfo.name;
                                end
                                 
                                col_interest=["Pelvis_x", "Pelvis_y", "Pelvis_z", "L5_x", "L5_y", "L5_z", ...
                                    "RightUpperLeg_x", "RightUpperLeg_y", "RightUpperLeg_z", "RightFoot_x",	"RightFoot_y",	"RightFoot_z", "RightLowerLeg_x", "RightLowerLeg_y", "RightLowerLeg_z", ...
                                    "LeftUpperLeg_x", "LeftUpperLeg_y", "LeftUpperLeg_z", "LeftFoot_x",	"LeftFoot_y",	"LeftFoot_z", "LeftLowerLeg_x", "LeftLowerLeg_y", "LeftLowerLeg_z"];
                                addpath (folderanalysis)
                                [time, data_extracted, labels]=extract_columns_v2(filename, sheet, file_sheet, col_interest, verbosity);
                                xsens_ord.ACC=data_extracted;
                                lab.ACC=labels;
                                
                                %adding sensor acceleration to the struct
                                if file_sheet=="f"
                                    filename="sensorFreeAcceleration.csv";
                                    sheet="";
                                else
                                    sheet="Sensor Free Acceleration";
                                    filename=fileInfo.name;
                                end
                                 
                                col_interest=["Pelvis_x", "Pelvis_y", "Pelvis_z", ...
                                    "RightUpperLeg_x", "RightUpperLeg_y", "RightUpperLeg_z", "RightFoot_x",	"RightFoot_y",	"RightFoot_z", "RightLowerLeg_x", "RightLowerLeg_y", "RightLowerLeg_z", ...
                                    "LeftUpperLeg_x", "LeftUpperLeg_y", "LeftUpperLeg_z", "LeftFoot_x",	"LeftFoot_y",	"LeftFoot_z", "LeftLowerLeg_x", "LeftLowerLeg_y", "LeftLowerLeg_z"];
                                addpath (folderanalysis)
                                [time, data_extracted, labels]=extract_columns_v2(filename, sheet, file_sheet, col_interest, verbosity);
                                xsens_ord.ACC_S=data_extracted;
                                lab.ACC_S=labels;
                                
                                %adding angular velocity to the struct
                                if file_sheet=="f"
                                    filename="angularVelocity.csv";
                                    sheet="";
                                else
                                    sheet= "Segment Angular Velocity";
                                    filename=fileInfo.name;
                                end
                                 
                                col_interest=["Pelvis_x", "Pelvis_y", "Pelvis_z", "L5_x", "L5_y", "L5_z", ...
                                    "RightUpperLeg_x", "RightUpperLeg_y", "RightUpperLeg_z", "RightFoot_x",	"RightFoot_y",	"RightFoot_z", "RightLowerLeg_x", "RightLowerLeg_y", "RightLowerLeg_z", ...
                                    "LeftUpperLeg_x", "LeftUpperLeg_y", "LeftUpperLeg_z", "LeftFoot_x",	"LeftFoot_y",	"LeftFoot_z", "LeftLowerLeg_x", "LeftLowerLeg_y", "LeftLowerLeg_z"];
                                addpath (folderanalysis)
                                [time, data_extracted, labels]=extract_columns_v2(filename, sheet, file_sheet, col_interest, verbosity);
                                xsens_ord.AV=data_extracted;
                                lab.AV=labels;
                                
                                %adding velocity to the struct
                                if file_sheet=="f"
                                    filename="velocity.csv";
                                    sheet="";
                                else
                                    sheet="Segment Velocity";
                                    filename=fileInfo.name;
                                end
                                 
                                col_interest=["Pelvis_x", "Pelvis_y", "Pelvis_z", "L5_x", "L5_y", "L5_z", ...
                                    "RightUpperLeg_x", "RightUpperLeg_y", "RightUpperLeg_z", "RightFoot_x",	"RightFoot_y",	"RightFoot_z", "RightLowerLeg_x", "RightLowerLeg_y", "RightLowerLeg_z", ...
                                    "LeftUpperLeg_x", "LeftUpperLeg_y", "LeftUpperLeg_z", "LeftFoot_x",	"LeftFoot_y",	"LeftFoot_z", "LeftLowerLeg_x", "LeftLowerLeg_y", "LeftLowerLeg_z"];
                                addpath (folderanalysis)
                                [time, data_extracted, labels]=extract_columns_v2(filename, sheet, file_sheet, col_interest, verbosity);
                                xsens_ord.V=data_extracted;
                                lab.V=labels;
                                
                                                               
                                xsens_ord.Labels=lab;
                                
                                save((p_name+ "_"+ tt_name + "_Extracted.mat"), 'xsens_ord');
                                xsens_ord=[];
                            end
                        end
                    end
                end
            end
        end
    end
end

writematrix(incomplete_data, strcat(initial_folder,"\missing_data.xlsx"));