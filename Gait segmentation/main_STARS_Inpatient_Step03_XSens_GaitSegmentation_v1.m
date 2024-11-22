%% main_STARS_Inpatient_Step03_XSens_GaitSegmentation_v1 _ adapted versio n for P2C project
% Script to segment the XSens 10MWT data in single strides based on the heel
% strikes and toe-off events defined from the maximum distance of the foot
% position from the pelvis sensors. Strides are then interpolated over 100
% samples for visualization
% Based on the STARS Chronic version main_XSens_Step2_IMU_Single_Gait_Cycle_Process

% Version modified - Sep 2024 - FLanotte _ SCampagnini
clc, clear all, close all,
addpath('./Matlab_function')
%% Folder constants
folderanalysis      = cd();   	% Folder path to the scripts for analysis
cd(strcat(folderanalysis, '\Example_STARS_sbj'))         % Move in the folder with mat files
folderdataprocessed = cd();     % Folder path to the mat files folder
%% File selection and loading
subjtoload      = uigetdir('Select the subject to analyse');	% Selection of the subject to analyze
cd(subjtoload)
testtoload      = uigetdir('Select the test to analyse');       % Selection of the subject to analyze
cd(testtoload)
sessiontolaod   = uigetfile('*XS_Extracted.mat*');              % Selection of the session to load
Hz          = 100;                                        	% Sampling rate in Hz
temp        = load(sessiontolaod);                          % Loading of the datase
subjid      = fieldnames(temp);                           	% Retrieving the subject id, i.e. name of the structure
subdata     = getfield(temp,subjid{1});                   	% Extracting the content of the structure
clear temp
trialslabel = fieldnames(subdata);                         	% Label of the trials
numoftrials = length(trialslabel);                        	% Number of trials tested
% if string(trialslabel(end))=="TestLabel"                  % not needed, the control is already inside (line 39)
%     numoftrials=numoftrials-1;
% end
subdata_out = struct();
%% Gait segmentation
for t = 1 : numoftrials
    ext     = subdata.(trialslabel{t});        	% Access to the trial field
    clear temp
    % for 10MWT tests only select frames for 10 m after haved covered 2m
    if contains(trialslabel{t},'V')
        positiontravel = vecnorm(ext.Pos(1,1:3)'-ext.Pos(:,1:3)');  % Compute the distance traveled from the pelvis sensor position
        startframe  = find(positiontravel > (positiontravel(1)+2),1,'first');   % 10mwt starts after 2m
        stopframe   = find(positiontravel > (positiontravel(1)+12),1,'first');  % ends detection of the test
        if isempty(startframe)
            startframe = 1;
        end
        if isempty(stopframe)
            stopframe = length(positiontravel);
        end
        % Figure for check
        % plot(positiontravel),hold on,
        % mark(1)= plot(startframe,positiontravel(startframe),'go');
        % mark(2)= plot(stopframe,positiontravel(stopframe),'ro');
        % ylabel('Distance traveled (m)')
        % legend(mark,{'Start test','End test'})
        % title('Click to continue')
        % waitforbuttonpress;
        % close
        frames      = startframe:stopframe;
    else
        continue
        frames  = [1:size(ext.Pos,1)];   % Frames to be considered
    end
    time    = frames / Hz;        	% Time vector
    Pos     = ext.Pos(frames,:);   	% Positions of the sensors [cm]
    JA      = ext.JA(frames,:);    	% Joint Angles [deg]
    ACC     = ext.ACC(frames,:);   	% Accelerations
    ACC_S   = ext.ACC_S(frames,:);	% Accelerations of the sensor
    AV      = ext.AV(frames,:);    	% Angular velocities
    Q       = ext.Q(frames,:);    	% Orientations
    
    % Check if invert the axis
    % concerning the columns reconstructed by the xsens, the system is
    % referencing everything to global coordinates. For this reason, in
    % some trials the peaks of velocity might be negative, in others
    % positive, depending on the walking direction of the user.
    figure,hold on
    plot(AV(:,20),'r'),plot(AV(:,11),'b')
    inversionflag = questdlg('To inver axis?','User input','Yes','No','Yes');
    if strcmp(inversionflag,'Yes')
        changecolumns = [1,2,4,5,7,8,10,11,13,14,16,17,19,20,22,23]; % Sensors x-y axis
        ACC(:,changecolumns)    = -ACC(:,changecolumns);
        AV(:,changecolumns)     = -AV(:,changecolumns);
    end   
    close 
    % Detect single gait cycles events
    Ts      = 1/Hz;
    Tw      = 0.5;
    L_hs    = heelstrike(Pos(:,7),JA(:,3),Ts,Tw); 	% Left Heel Strike (HS) to Left HS
    R_hs    = heelstrike(Pos(:,4),JA(:,3),Ts,Tw); 	% Right HS to HS
    
    % Display the segmentation
    figure(100)
    % Left Foot
    pl(1) = plot(Pos(:,7),'b');
    hold on
    plot(L_hs(:,1),Pos(L_hs(:,1),7),'bx')
    plot(L_hs(:,2),Pos(L_hs(:,2),7),'bo')
    % Right Foot
    pl(2) = plot(Pos(:,4),'r');
    plot(R_hs(:,1),Pos(R_hs(:,1),4),'rx')
    plot(R_hs(:,2),Pos(R_hs(:,2),4),'ro')
%     xlim([0 frames(end)])
    title('Foot Traj.')
    ylabel('x- displacement (m)')
    legend(pl,'Left','Right')
    
    % Evaluate the segmentation
    segmentationflag = questdlg('Segmentation is good?','User input','Yes','No','Yes');
    if strcmp(segmentationflag,'No')
        side = questdlg('Select the side to segment','User input','Left','Right','Left');
        [locs,~] = ginput();        % Getting the new peaks
        locs = floor(locs);
        for i = 1:length(locs)-1
            locs2(i,1) = locs(i);
            locs2(i,2) = locs(i+1);
        end
        if strcmp(locs,'Right')
            R_hs = locs2;
        else
            L_hs = locs2;
        end
        clear locs locs2      
    end
    close all   
    % Toe-off detection
    for r = 1 : size(L_hs,1) %for each stride detected
        [~,L_to(r)] = min(Pos(L_hs(r,1):L_hs(r,2),7));
        L_to(r) = L_to(r) + L_hs(r,1) - 1;
    end
    for r = 1 : size(R_hs,1) %for each stride detected
        [~,R_to(r)] = min(Pos(R_hs(r,1):R_hs(r,2),4));
        R_to(r) = R_to(r) + R_hs(r,1) - 1;
    end
    
    L_seg_frame = sort([L_hs(:,2); L_hs(:,1)]); %R_hs and
    R_seg_frame = sort([R_hs(:,2); R_hs(:,1)]);
    
    % Segmentation into strides
    dt = 1/Hz;  
    for i = 1:24
        % Stride segmentation based on the left heel strike
        [int.Lseg.JA_mean(:,i),int.Lseg.JA_std(:,i),int.Lseg.JA_seg(:,:,i),seg.Lseg.SG_period,seg.Lseg.JA_seg(:,i)]	=...
            single_gait(JA(:,i),L_seg_frame,dt);  % Joint kinematics
        [int.Lseg.AV_mean(:,i),int.Lseg.AV_std(:,i),int.Lseg.AV_seg(:,:,i),~,seg.Lseg.AV_seg(:,i)]                 	=...
            single_gait(AV(:,i),L_seg_frame,dt);  % Angular velocity
        [int.Lseg.ACC_mean(:,i),int.Lseg.ACC_std(:,i),int.Lseg.ACC_seg(:,:,i),~,seg.Lseg.ACC_seg(:,i)]             	=...
            single_gait(ACC(:,i),L_seg_frame,dt); % Acceleration
        % Stride segmetation based on the right heel strike
        [int.Rseg.JA_mean(:,i),int.Rseg.JA_std(:,i),int.Rseg.JA_seg(:,:,i),seg.Rseg.SG_period,seg.Rseg.JA_seg(:,i)]	=...
            single_gait(JA(:,i),R_seg_frame,dt);  % Joint kinematics
        [int.Rseg.AV_mean(:,i),int.Rseg.AV_std(:,i),int.Rseg.AV_seg(:,:,i),~,seg.Rseg.AV_seg(:,i)]                	=...
            single_gait(AV(:,i),R_seg_frame,dt);  % Angular velocity
        [int.Rseg.ACC_mean(:,i),int.Rseg.ACC_std(:,i),int.Rseg.ACC_seg(:,:,i),~,seg.Rseg.ACC_seg(:,i)]           	=...
            single_gait(ACC(:,i),R_seg_frame,dt); % Acceleration
    end
    % Loading timings and indeces in the struct
    seg.startframe      = frames(1);
    seg.stopframe       = frames(end);
    seg.Lseg.LHS_idx    = L_hs;
    seg.Rseg.RHS_idx    = R_hs;
    seg.Lseg.LHS_tim    = time(L_hs);
    seg.Rseg.RHS_tim    = time(R_hs);
    seg.Lseg.LTO_idx    = L_to;
    seg.Rseg.RTO_idx    = R_to;
    seg.Lseg.LTO_tim    = time(L_to);
    seg.Rseg.RTO_tim    = time(R_to);
    
    % Plotting the segmentation - Left side HS
    gcf1 = plotdatasegmentedstrides(int.Lseg,'JA');     % Joint kinematics
    set(gcf1,'Name','Left HS Seg JA')
    gcf2 = plotdatasegmentedstrides(int.Lseg,'ACC');	% Accelerations
    set(gcf2,'Name','Left HS Seg ACC')
    gcf3 = plotdatasegmentedstrides(int.Lseg,'AV');     % Angular speed
    set(gcf3,'Name','Left HS Seg AV')
    title('Click to continue')
    waitforbuttonpress;

    % Plotting the segmentation - Right side HS
    gcf4 = plotdatasegmentedstrides(int.Rseg,'JA');     % Joint kinematics
    set(gcf4,'Name','Right HS Seg JA')
    gcf5 = plotdatasegmentedstrides(int.Rseg,'ACC');	% Accelerations
    set(gcf5,'Name','Right HS Seg ACC')
    gcf6 = plotdatasegmentedstrides(int.Rseg,'AV');     % Angular speed
    set(gcf6,'Name','Right HS Seg AV')
    title('Click to continue')
    waitforbuttonpress;
    close all
    
    % Adding field in the structure
    subdata_out.(trialslabel{t}).Segmented      = seg;
    subdata_out.(trialslabel{t}).Interpolated 	= int;
    clear seg R_hs L_hs R_seg_frame L_hs_frame int L_to R_to
end
%% Saving the data
eval([subjid{1},'= subdata_out'])	% Create a struct with the identifier of the subject (dynamic assigment)
save([sessiontolaod(1:end-13),'Segmented.mat'],subjid{1})	% Data saving
%% End of the script
cd(folderanalysis)