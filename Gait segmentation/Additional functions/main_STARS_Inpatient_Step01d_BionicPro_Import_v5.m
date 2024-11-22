%% main_STARS_Inpatient_BionicPro_Step1_Import_v5
% Script to extract the BionicPro data in a mat file for each trial of a subject
% Adapted from the script of the outpatient subjects
% Version 5: Adjust the handling of the systems

% Version 5 - Apr 2023 - FLanotte
clc, clear all, close all,
addpath('./Matlab_function')
%% Folder constants
folderanalysis      = cd();   	% Folder path to the scripts for analysis
cd('../Data_Raw')             	% Move in the data folder
foldersubjectsdata	= cd();     % Folder path to the raw data of all subjects
dlgtitle        = 'User input';
% Selection of the subject
subjecttype     = 'STARS';
foldersubjs 	= dir(['*' subjecttype '*']);   % Folders of the type of subject
numberofsubs    = length(foldersubjs);          % Number of subjects available
subjectnumber   = str2num(cell2mat(inputdlg('Enter the subject number',dlgtitle)));	% Subject selection
if subjectnumber > numberofsubs                 % Return if subject number does not exist
    return
end
subjectstring   = foldersubjs(subjectnumber).name;  % String with the selected subject folder
cd(subjectstring)                                   % Move in the subject folder
% Session ID
sessions_labels	= {'01_Admission','02_Discharge','01_M01','03_M03','04_M06','05_M09','06_M12'};  % Possible Sessions
session_of_int  = listdlg('ListString',sessions_labels);    % Select session of interest
sessionID       = sessions_labels{session_of_int};          % Session ID
% BionicPro data folder
try
    cd(sessionID)
catch
    questdlg(['The folder ' sessionID ' does not exist']);
    return
end
cd('BionicPro')           	% Move in the folder with the raw data of BionicPro
folderdataraw   = cd();     % Folder path with the selected subject data

%% Data Loading and extraction
triallist	= {'Stand','SSV1','SSV2','SSV3','SSV4'...
    'FV1','FV2','FV3',...
    'TUG1','TUG2','TUG3',...
    'BBS01','BBS02','BBS03','BBS04','BBS05','BBS06','BBS07',...
    'BBS08','BBS09','BBS10','BBS11','BBS12','BBS13','BBS14',...
    'FGA01','FGA02','FGA03','FGA04','FGA05',...
    'FGA06','FGA07','FGA08','FGA09','FGA10',...
    'MWT6','DLT'};
numberoftrials      = length(triallist) - 1;	% Number of trials
elementsinfolder    = dir();                    % Elements in the folder
elementsinfolder([1,2]) = [];
numberofelements    = length(elementsinfolder); % Number of elements in the folder

BionicPro_SSV     	= struct();                	% Struct with data
BionicPro_FV     	= struct();             	% Struct with data
BionicPro_TUG     	= struct();              	% Struct with data
BionicPro_BBS     	= struct();              	% Struct with data
BionicPro_MWT6     	= struct();               	% Struct with data
BionicPro_FGA     	= struct();               	% Struct with data

BBS_label 	= {'Sit2Stand','Stand','Sitting','Stand2Sit','Transfers',...
    'StandEyeClose','StandFeetTogether','ReachingForward','Pickup',...
    'LookBehind','Turn360','PlaceAltFoot','StandFootinfront','StandOneLeg'};

FGA_label 	= {'GaitLevel','ChangeSpeed','HorizontalHead','VerticalHead','PivotTurn',...
    'StepObstacle','NarrowBase','GaitEyesClosed','Backwards','Stairs'};

for t = 1 : numberofelements
    cd(folderdataraw)
    filein      = elementsinfolder(t).name;    % String with the file name
%     if ~contains(filein,'FV')
%         continue
%     end
    trialidx  	= listdlg('PromptString',{'Select kind of test for',filein},'ListString',triallist);
    trialID     = triallist{trialidx};
    if strcmp(trialID,'DLT')	% Skip trial if delete is selected
        continue
    end
    
    if elementsinfolder(t).isdir
        cd(filein)
        tempcont = dir('*.hdf5*');
        if isempty(tempcont)
            continue
        end
        filein = tempcont.name;
    end
    TrialStruct	= struct();	% Init of structure for data saving
    [time,data,Pel,Thigh_L,Thigh_R,Shank_L,Shank_R,Foot_L,Foot_R] = openbionicprodata(filein);
    % Segmenting start and stop for BBS and FGA
    rangeofinterest = 1: length(time);
%     if contains(trialID,'BBS') || contains(trialID,'FGA') || contains(trialID,'MWT') 
%         Foot_L = zeros(4,4,length(time));
%     end
    figure,
    subplot(313), hold on,
    plot(squeeze(Thigh_L(1:3,1,:))','r'),plot(squeeze(Thigh_R(1:3,1,:))','b')
    ylabel('Feet Accelerometer')
    subplot(311), hold on, plot(squeeze(Pel(1:3,1,:))'),
    ylabel('Pelvis Accelerometer')
    subplot(312), hold on, plot(squeeze(Pel(1:3,2,:))'),
    ylabel('Pelvis Gyro')
    [f,range] = ginput(2);
    if ~isempty(f)
        f = round(f);
        close all
        rangeofinterest = (f(1):f(2));
%         if strcmp(trialID,'BBS05')
%             rangeofinterest = [1:f(1),f(2):length(time)];
%         end
        time = time(rangeofinterest);
    end
    
    % Pelvis (PE)
    PE.acc(:,:)	= permute(Pel(1:3,1,rangeofinterest),[3 1 2]);
    PE.gyr(:,:)	= permute(Pel(1:3,2,rangeofinterest),[3 1 2]);
    PE.mag(:,:)	= permute(Pel(1:3,3,rangeofinterest),[3 1 2]);
    PE.acc_norm	= vecnorm(PE.acc')';
    PE.gyr_norm	= vecnorm(PE.gyr')';
    PE.mag_norm	= vecnorm(PE.mag')';
    
    % Left Foot (LF)
    LF.acc(:,:)	= permute(Foot_L(1:3,1,rangeofinterest), [3 1 2]);
    LF.gyr(:,:)	= permute(Foot_L(1:3,2,rangeofinterest), [3 1 2]);
    LF.mag(:,:)	= permute(Foot_L(1:3,3,rangeofinterest), [3 1 2]);
    LF.acc_norm	= vecnorm(LF.acc')';
    LF.gyr_norm	= vecnorm(LF.gyr')';
    LF.mag_norm	= vecnorm(LF.mag')';
    
    % Right Foot (RF)
    RF.acc(:,:)	= permute(Foot_R(1:3,1,rangeofinterest),[3 1 2]);
    RF.gyr(:,:)	= permute(Foot_R(1:3,2,rangeofinterest),[3 1 2]);
    RF.mag(:,:)	= permute(Foot_R(1:3,3,rangeofinterest),[3 1 2]);
    RF.acc_norm	= vecnorm(RF.acc')';
    RF.gyr_norm	= vecnorm(RF.gyr')';
    RF.mag_norm	= vecnorm(RF.mag')';
    
    % Left Thigh (LT)
    LT.acc(:,:)	= permute(Thigh_L(1:3,1,rangeofinterest),[3 1 2]);
    LT.gyr(:,:)	= permute(Thigh_L(1:3,2,rangeofinterest),[3 1 2]);
    LT.mag(:,:)	= permute(Thigh_L(1:3,3,rangeofinterest),[3 1 2]);
    LT.acc_norm	= vecnorm(LT.acc')';
    LT.gyr_norm	= vecnorm(LT.gyr')';
    LT.mag_norm	= vecnorm(LT.mag')';
    
    % Right Thigh (RT)
    RT.acc(:,:)	= permute(Thigh_R(1:3,1,rangeofinterest),[3 1 2]);
    RT.gyr(:,:)	= permute(Thigh_R(1:3,2,rangeofinterest),[3 1 2]);
    RT.mag(:,:)	= permute(Thigh_R(1:3,3,rangeofinterest),[3 1 2]);
    RT.acc_norm	= vecnorm(RT.acc')';
    RT.gyr_norm	= vecnorm(RT.gyr')';
    RT.mag_norm	= vecnorm(RT.mag')';
    
    % Left Shank(LS)
    LS.acc(:,:)	= permute(Shank_L(1:3,1,rangeofinterest),[3 1 2]);
    LS.gyr(:,:)	= permute(Shank_L(1:3,2,rangeofinterest),[3 1 2]);
    LS.mag(:,:)	= permute(Shank_L(1:3,3,rangeofinterest),[3 1 2]);
    LS.acc_norm	= vecnorm(LS.acc')';
    LS.gyr_norm	= vecnorm(LS.gyr')';
    LS.mag_norm	= vecnorm(LS.mag')';
    
    % Right Shank (RS)
    RS.acc(:,:)	= permute(Shank_R(1:3,1,rangeofinterest),[3 1 2]);
    RS.gyr(:,:)	= permute(Shank_R(1:3,2,rangeofinterest),[3 1 2]);
    RS.mag(:,:)	= permute(Shank_R(1:3,3,rangeofinterest),[3 1 2]);
    RS.acc_norm	= vecnorm(RS.acc')';
    RS.gyr_norm	= vecnorm(RS.gyr')';
    RS.mag_norm	= vecnorm(RS.mag')';
    
    gcf_r = plotrawimusignals(PE,RT,RS,RF,'Right',time);
    gcf_l = plotrawimusignals(PE,LT,LS,LF,'Left',time);
    
    qualitycheck = questdlg('Are data good?',dlgtitle,'Y','N','Y');
    close all      
    if strcmp(qualitycheck,'N')
        continue
    end
    
    % If the folder in enter, then export the angles
    if elementsinfolder(t).isdir
        csv_file  	= dir('*raw_angles.csv*');
        if ~isempty(csv_file)
            temp_table 	= readtable(csv_file.name,'Delimiter',',');
            temp_array 	= table2array(temp_table(:,2:end))';
            PE.sag_ang  = temp_array(:,7);
            PE.fro_ang  = temp_array(:,14);
            LT.sag_ang  = temp_array(:,8);
            LT.fro_ang  = temp_array(:,15);
            LS.sag_ang  = temp_array(:,9);
            LS.fro_ang  = temp_array(:,16);
            LF.sag_ang  = temp_array(:,10);
            LF.fro_ang  = temp_array(:,17);
            RT.sag_ang  = temp_array(:,11);
            RT.fro_ang  = temp_array(:,18);
            RS.sag_ang  = temp_array(:,12);
            RS.fro_ang  = temp_array(:,19);
            RF.sag_ang  = temp_array(:,13);
            RF.fro_ang  = temp_array(:,20);
        end
    end
    
    % Save data in the struct
    TrialStruct.time	= time;
    TrialStruct.range	= rangeofinterest;
    TrialStruct.PE   	= PE;
    TrialStruct.RT  	= RT;
    TrialStruct.RS  	= RS;
    TrialStruct.RF   	= RF;
    TrialStruct.LT   	= LT;
    TrialStruct.LS  	= LS;
    TrialStruct.LF      = LF;
    if contains(trialID,'BBS')
       bbsidx = str2num(trialID(end-1:end));
       TrialStruct.BBSLabel = BBS_label{bbsidx};       
    end
    if contains(trialID,'FGA')
       fgaidx = str2num(trialID(end-1:end));
       TrialStruct.FGALabel = FGA_label{fgaidx};       
    end
    
    if contains(trialID,'SSV')
        BionicPro_SSV = setfield(BionicPro_SSV,trialID,TrialStruct);
    else if contains(trialID,'FV')
            BionicPro_FV = setfield(BionicPro_FV,trialID,TrialStruct);
        else if contains(trialID,'TUG')
                BionicPro_TUG = setfield(BionicPro_TUG,trialID,TrialStruct);
            else
                if contains(trialID,'BBS')
                    if isfield(BionicPro_BBS,trialID)
                        BionicPro_BBS.(trialID).time = ...
                            [BionicPro_BBS.(trialID).time;TrialStruct.time+1000];
                        BionicPro_BBS.(trialID).range = ...
                            [BionicPro_BBS.(trialID).range,TrialStruct.range];
                        for sens_lab = {'PE','RT','RS','RF','LT','LS','LF'}
                            for axis_lab = {'acc','gyr','mag','acc_norm','gyr_norm','mag_norm'}
                                BionicPro_BBS.(trialID).(sens_lab{1}).(axis_lab{1}) = ...
                                    [BionicPro_BBS.(trialID).(sens_lab{1}).(axis_lab{1});...
                                    TrialStruct.(sens_lab{1}).(axis_lab{1})];
                            end
                        end
                    else
                        BionicPro_BBS = setfield(BionicPro_BBS,trialID,TrialStruct);
                    end
                else if contains(trialID,'MWT6')
                        BionicPro_MWT6 = setfield(BionicPro_MWT6,trialID,TrialStruct);
                    else if contains(trialID,'FGA')
                            BionicPro_FGA = setfield(BionicPro_FGA,trialID,TrialStruct);
                        else
                            BionicPro_SSV   = setfield(BionicPro_SSV,trialID,TrialStruct);
                            BionicPro_FV    = setfield(BionicPro_FV,trialID,TrialStruct);
                            BionicPro_TUG   = setfield(BionicPro_TUG,trialID,TrialStruct);
                            BionicPro_BBS   = setfield(BionicPro_BBS,trialID,TrialStruct);
                            BionicPro_MWT6  = setfield(BionicPro_MWT6,trialID,TrialStruct);
                            BionicPro_FGA   = setfield(BionicPro_FGA,trialID,TrialStruct);
                        end
                    end
                end
            end
        end
    end
    clear data Foot_L Foot_R RF LF Thigh_L Thigh_R LT RT Shank_L Shank_R LS RS Pel PE time
end
%% Move to process data
cd(folderanalysis)
cd('../Data_Processed/')
cd(subjectstring)
% 10MWT - SSV
cd('./10MWT_SSV')
fileout = [subjectstring '_' sessionID '_10MWT_SSV_BP_Extracted.mat'];	% File name
[~] = dynamicstructuresavingshort(subjectstring,sessionID(4:6),BionicPro_SSV,fileout,'10MWT-SSV')
% 10MWT - FV
cd('../10MWT_FV')
fileout = [subjectstring '_' sessionID '_10MWT_FV_BP_Extracted.mat'];  	% File name
[~] = dynamicstructuresavingshort(subjectstring,sessionID(4:6),BionicPro_FV,fileout,'10MWT-FV')
% TUG
cd('../TUG')
fileout = [subjectstring '_' sessionID '_TUG_BP_Extracted.mat'];         % File name
[~] = dynamicstructuresavingshort(subjectstring,sessionID(4:6),BionicPro_TUG,fileout,'TUG')
% BBS
cd('../BBS')
fileout = [subjectstring '_' sessionID '_BBS_BP_Extracted.mat'];         % File name
[~] = dynamicstructuresavingshort(subjectstring,sessionID(4:6),BionicPro_BBS,fileout,'BBS')
% 6MWT
cd('../6MWT')
fileout = [subjectstring '_' sessionID '_MWT6_BP_Extracted.mat'];         % File name
[~] = dynamicstructuresavingshort(subjectstring,sessionID(4:6),BionicPro_MWT6,fileout,'MWT6')
% BBS
cd('../FGA')
fileout = [subjectstring '_' sessionID '_FGA_BP_Extracted_BionicPro.mat'];         % File name
[~] = dynamicstructuresavingshort(subjectstring,sessionID(4:6),BionicPro_FGA,fileout,'FGA')
%% End of teh script
cd(folderanalysis)
%% Functions
% Function 1: Plot raw signals
function gcf = plotrawimusignals(imupe,imuthigh,imushank,imufoot,side,time)
gcf = figure('Color',[1 1 1],'Name',side);
ax(1) = subplot(2,4,1); hold on,
plot(time,imupe.acc(:,1),'r')
plot(time,imupe.acc(:,2),'g')
plot(time,imupe.acc(:,3),'b')
ylabel('Pelvis Acc')
ax(2) = subplot(2,4,5); hold on,
plot(time,imupe.gyr(:,1),'r')
plot(time,imupe.gyr(:,2),'g')
plot(time,imupe.gyr(:,3),'b')
ylabel('Pelvis Gyro')

ax(3) = subplot(2,4,2); hold on,
plot(time,imuthigh.acc(:,1),'r')
plot(time,imuthigh.acc(:,2),'g')
plot(time,imuthigh.acc(:,3),'b')
ylabel('Thigh Acc')
ax(4) = subplot(2,4,6); hold on,
plot(time,imuthigh.gyr(:,1),'r')
plot(time,imuthigh.gyr(:,2),'g')
plot(time,imuthigh.gyr(:,3),'b')
ylabel('Thigh Gyro')

ax(5) = subplot(2,4,3); hold on,
plot(time,imushank.acc(:,1),'r')
plot(time,imushank.acc(:,2),'g')
plot(time,imushank.acc(:,3),'b')
ylabel('Shank Acc')
ax(6) = subplot(2,4,7); hold on,
plot(time,imushank.gyr(:,1),'r')
plot(time,imushank.gyr(:,2),'g')
plot(time,imushank.gyr(:,3),'b')
ylabel('Shank Gyro')

ax(7) = subplot(2,4,4); hold on,
plot(time,imufoot.acc(:,1),'r')
plot(time,imufoot.acc(:,2),'g')
plot(time,imufoot.acc(:,3),'b')
ylabel('Foot Acc')
ax(8) = subplot(2,4,8); hold on,
plot(time,imufoot.gyr(:,1),'r')
plot(time,imufoot.gyr(:,2),'g')
plot(time,imufoot.gyr(:,3),'b')
ylabel('Foot Gyro')

linkaxes(ax,'x')
end
