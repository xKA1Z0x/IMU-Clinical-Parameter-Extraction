%% main_STARS_Inpatient_Step03_XSens_GaitSegmentation_v1 _ adapted versio n for P2C project
% Script to segment the XSens 10MWT data in single strides based on the heel
% strikes and toe-off events defined from the maximum distance of the foot
% position from the pelvis sensors. Strides are then interpolated over 100
% samples for visualization
% Based on the STARS Chronic version main_XSens_Step2_IMU_Single_Gait_Cycle_Process

% Version modified - Sep 2024 - FLanotte _ SCampagnini
clc, clear all, close all,
addpath('./Matlab_function')

%% control panel - settings
specific_cond=["Control"];  %write here specific folder of conditions you want this code to process
specific_part=["HC05"]; %, "CVA15"];  %write here specific folder of participants you want this code to process
specific_tasks=[""];%"10MWT_2_2", "10MWT_2_3","10MWT_2_1",  "10MWT_3_3", "10MWT_3_2", "10MWT_3_1"];%,"10MWT_1_2" ,  "10MWT_1_3", "10MWT_2_2", "10MWT_2_3", "10MWT_3_3", "10MWT_3_1"];%"10MWT_1_3","10MWT_3_2", "10MWT_2_1", "10MWT_1_2",%"6MWT_OG_1_1", "2MWT_TREAD_1_1"];  %write here specific folder of tasks or trials you want this code to process
% "10MWT_2_1""10MWT_1_1",
% [ "10MWT_2_2", "10MWT_2_3", "10MWT_2_1", "10MWT_1_2", "10MWT_1_3",
pattern_gait_tasks=["2MWT"];%, "TUG", "STAIRS"]; %list of patterns contained in the task names that identify gait patterns (those over which the execution of this code makes sense)

initial_folder="\\fs2\RTO\P2C\P2C_Database_Segmented - Database paper version"; %direct the code to a specific folder, without interactively ask to the user
Hz          = 60;
cutoff_HPF  = 1;  %cutoff frequency of the high-pass filter, to remove the drift from the foot vertical position signal
order_HPF   = 5;  %order of the high-pass filter, to remove the drift from the foot vertical position signal

verbosity=1; %flag for turning on and off the verbosity of the code. 0=the code is not outputting any info; 1= the code is providing info on the portion under processing, 0=otherwise
plot_verbosity=0; %flag for turning on and off extra plots to check the processing of the code; 1= the code is providing the extra plots, 0=otherwise

%% positioning in the proper folder and selecting the files
addpath('\\fs2.smpp.local\rto\STARS\Inpatient Study\Analysis\Matlab_function')

folderanalysis      = cd();   	% Folder path to the scripts for analysis
addpath(folderanalysis)
if initial_folder==""
    subjtoload      = uigetdir('Select the folder with the data');	% Selection of the subject to analyze
else subjtoload= initial_folder;
end
cd(subjtoload)

conditions=dir(subjtoload);

subdata_out = struct();
%% Gait segmentation

for c=1:length(conditions) %for each condition folder available
    c_name=conditions(c).name;
    
    if ~contains(c_name, '.') && (specific_cond(1)=="" || ~isempty(find(specific_cond==string(c_name))))  %check that the file name c_name is a folder for the conditions and not sparse files with .xxx extension + check that only the desired consitions are selected
        if verbosity==1
            fprintf("Processing condition: " + c_name);
        end
        c_folder=conditions(c).folder;
        cd(strcat(c_folder, "\", c_name))
        participants=dir(cd);
        for p=1:length(participants)
            p_name=participants(p).name;
            if ~contains(p_name, '.') && (specific_part(1)=="" || ~isempty(find(specific_part==string(p_name)))) %check that the file name p_name is a folder for the participant and not sparse files with .xxx extension + check that only the desired participants are selected
                if verbosity==1
                    fprintf("\n Processing participant: " + p_name);
                end
                p_folder=participants(p).folder;
                cd(strcat(p_folder, "\", p_name))
                tasktrials=dir(cd);
                for tt=1:length(tasktrials) %for each of the files contained
                    tt_name=tasktrials(tt).name;
                    if ~contains(tt_name, '.') && (specific_tasks(1)=="" || ~isempty(find(specific_tasks==string(tt_name)))) %check that the file name tt_name is a folder for the participant and not sparse files with .xxx extension + check that only the desired tasks and trials are selected
                        
                        %check if the task is a gait task
                        sum_pat=0;
                        for pat_idx=1:length(pattern_gait_tasks)
                            if contains(tt_name, pattern_gait_tasks(pat_idx))
                                sum_pat=sum_pat+1;
                            end
                        end
                        if sum_pat>0 %if the task is a gait task, proceed with the rest of the segmentation
                            
                            if verbosity==1
                                fprintf("\n Processing task and trial: " + tt_name);
                            end
                            tt_folder=tasktrials(tt).folder;
                            if isdir(strcat(tt_folder, "\", tt_name, "\Sensor Data\Xsens"))
                                cd(strcat(tt_folder, "\", tt_name, "\Sensor Data\Xsens"))
                            else cd(strcat(tt_folder, "\", tt_name, "\Xsens"))
                            end
                            sensors=dir(cd);
                            
                            %check for presence of the data file
                            if ~isfile(strcat(cd, "\", p_name, "_", tt_name,"_Extracted.mat"))
                                fprintf("\n Data not available");
                                
                            else
                                
                                ext     = load(strcat(cd, "\", p_name, "_", tt_name,"_Extracted.mat"));        	% Access to the trial field
                                ext=ext.xsens_ord;
                                clear temp
                                %                                 %                             % for 10MWT tests only select frames for 10 m after haved covered 2m
                                %                                 %                             if contains(trialslabel{t},'V')
                                %                                 positiontravel = vecnorm(ext.Pos(1,1:3)'-ext.Pos(:,1:3)');  % Compute the distance traveled from the pelvis sensor position
                                %                                 startframe  = find(positiontravel > (positiontravel(1)+2),1,'first');   % 10mwt starts after 2m
                                %                                 stopframe   = find(positiontravel > (positiontravel(1)+12),1,'first');  % ends detection of the test
                                %                                 if isempty(startframe)
                                %                                     startframe = 1;
                                %                                 end
                                %                                 if isempty(stopframe)
                                %                                     stopframe = length(positiontravel);
                                %                                 end
                                %                                 % Figure for check
                                %                                 % plot(positiontravel),hold on,
                                %                                 % mark(1)= plot(startframe,positiontravel(startframe),'go');
                                %                                 % mark(2)= plot(stopframe,positiontravel(stopframe),'ro');
                                %                                 % ylabel('Distance traveled (m)')
                                %                                 % legend(mark,{'Start test','End test'})
                                %                                 % title('Click to continue')
                                %                                 % waitforbuttonpress;
                                % close
                                frames      = 1:length(ext.time);
                                %                             else
                                %                                 continue
                                %                                 frames  = [1:size(ext.Pos,1)];   % Frames to be considered
                                %                             end
                                time    = frames / Hz;        	% Time vector
                                Pos     = ext.Pos(frames,:);   	% Positions of the sensors [cm]
                                JA      = ext.JA(frames,:);    	% Joint Angles [deg]
                                ACC     = ext.ACC(frames,:);   	% Accelerations
                                ACC_S   = ext.ACC_S(frames,:);	% Accelerations of the sensor
                                AV      = ext.AV(frames,:);    	% Angular velocities
                                Q       = ext.Q(frames,:);    	% Orientations
                                V       = ext.V(frames,:);    	% Velocity
                                
                                % Check if invert the axis
                                %select only one fifth of the signal if
                                %this is a 6mwt
                                if ~contains(tt_name, "6MWT")
                                    if contains(tt_name, "2MWT")
                                        rows=1:round(length(ext.time)/5);
                                    else rows=frames;
                                    end
                                    figure,hold on
                                    plot(AV(rows,23),'r'),plot(AV(rows,14),'b')
                                    legend('Left','Right', 'Location', 'southoutside')
                                    inversionflag = questdlg('To inver axis?','User input','Yes','No','Yes');
                                    if strcmp(inversionflag,'Yes')
                                        changecolumns = [1,2,4,5,7,8,10,11,13,14,16,17,19,20,22,23]; % Sensors x-y axis
                                        ACC(:,changecolumns)    = -ACC(:,changecolumns);
                                        AV(:,changecolumns)     = -AV(:,changecolumns);
                                    end
                                    close
                                end
                                % Detect single gait cycles events
                                Ts      = 1/Hz;
                                Tw      = 0.5;
                                
                                
                                % application of a high-pass filter to remove the drift from the vertical foot position
                                [b, a] = butter(5, cutoff_HPF/(Hz/2), 'high');
                                filtered_data_l = filtfilt(b, a, Pos(:,7));
                                filtered_data_r = filtfilt(b, a, Pos(:,4));
                                if plot_verbosity==1
                                    figure, hold on
                                    plot(Pos(:,7), 'r'), plot(Pos(:,4), 'b')
                                    title('x foot position: non-filtered signal')
                                    legend('Left', 'Right')
                                    figure, hold on
                                    plot(filtered_data_l, 'r'), plot(filtered_data_r, 'b')
                                    title('x foot position: filtered signal')
                                    legend('Left', 'Right')
                                    spreadfigures;
                                    waitforbuttonpress;
                                    close all
                                end
                                L_hs    = heelstrike(filtered_data_l,JA(:,3),Ts,Tw); 	% Left Heel Strike (HS) to Left HS
                                R_hs    = heelstrike(filtered_data_r,JA(:,3),Ts,Tw); 	% Right HS to HS
                                
                                L_hs=fix_peaks(L_hs);
                                R_hs=fix_peaks(R_hs);
                                % Display the segmentation
                                
                                
                                if contains(tt_name, "2MWT")  || contains(tt_name, "6MWT")
                                    
                                    % Right Foot
                                    figure(110)
                                    plot(filtered_data_r,'yellow');
                                    hold on
                                    plot(R_hs(:,1),filtered_data_r(R_hs(:,1)),'rx')
                                    plot(R_hs(:,2),filtered_data_r(R_hs(:,2)),'ro')
                                    %     xlim([0 frames(end)])
                                    title('Right Foot Traj.')
                                    ylabel('x- displacement (m)')
                                    
                                    spreadfigures;
                                    
                                    
                                    %prompt user to evaluate
                                    %segmentation
                                    segmentationflag = questdlg('Segmentation on the right is good?', 'User input', 'Yes', 'No', 'Yes');
                                    if strcmp(segmentationflag, 'No')
                                    while true % Infinite loop for adding or removing peaks
                                        % Prompt for action: Remove peaks, Add peaks, or exit
                                        action = questdlg('Select the action to take on the peaks', 'User input', ...
                                                          'Remove peaks', 'Add peaks', 'It looks good now', 'Remove peaks');

                                        % Break the loop if the user selects "It looks good now"
                                        if strcmp(action, 'It looks good now')
                                            break; % Exit the loop
                                        end

                                        % User input for a range (x1, x2) and y threshold by selecting two points
                                        [xs, ys] = ginput(2); % User selects two points
                                        x1 = round(min(xs));  % Ensure x1 is the smaller value
                                        x2 = round(max(xs));  % Ensure x2 is the larger value
                                        y_val = mean(ys);     % Use the average of the y-values as the threshold

                                        if strcmp(action, 'Remove peaks')
                                            % Calculate threshold from the average y-values of ginput
                                            y_val = mean(ys); 
                                            % Process column 1 of R_hs
                                            for col = 1:2
                                                % Find markers in the range [x1, x2]
                                            markers_in_range = R_hs(:, col) >= x1 & R_hs(:, col) <= x2;

                                            % Check amplitudes in filtered_data_r for these markers, processing in reverse order
                                            for i = flip(find(markers_in_range))' % Process from the last index to the first
                                                if filtered_data_r(R_hs(i, col)) < y_val
                                                    % Remove marker (shift values up in the column)
                                                    R_hs(i:end - 1, col) = R_hs(i + 1:end, col); % Shift column up
                                                    R_hs(end, col) = NaN; % Clear the last value
                                                end
                                            end

                                            % Remove any rows where both columns are NaN (completely empty row)
                                            R_hs = R_hs(~all(isnan(R_hs), 2), :);

                                            end

                                            % Fix overlaps between columns (ensure col 2 aligns with next in col 1)
                                            if ~isempty(R_hs)
                                                for i = 1:size(R_hs, 1) - 1
                                                    R_hs(i, 2) = R_hs(i + 1, 1);
                                                end
                                            end
                                        
                                        elseif strcmp(action, 'Add peaks')
                                            % Add peaks in the range [x1, x2] based on filtered_data_r
                                            filtered_segment = filtered_data_r(x1:x2); % Extract data in range
                                            [peaks, locs] = findpeaks(filtered_segment); % Find local maxima in range

                                            % Filter peaks above the threshold
                                            locs = locs(peaks >= y_val);
                                            locs = locs + x1 - 1; % Adjust locs to the original indices

                                            % Add new peaks to R_hs while preserving order
                                            for loc = locs'
                                                % Find the correct place to insert the new peak
                                                insertion_index = find(R_hs(:, 1) > loc, 1, 'first');

                                                if isempty(insertion_index) % If loc is greater than all existing values
                                                    R_hs = [R_hs; loc, loc]; % Add to the end
                                                else
                                                    % Insert the new peak in the correct position
                                                    R_hs = [R_hs(1:insertion_index - 1, :); loc, loc; R_hs(insertion_index:end, :)];
                                                end
                                            end
                                        end

                                        % Re-plot the updated signal and peaks
                                        figure(110);
                                        plot(filtered_data_r, 'yellow');
                                        hold on;
                                        plot(R_hs(:, 1), filtered_data_r(R_hs(:, 1)), 'rx'); % Plot markers for first column
                                        plot(R_hs(:, 2), filtered_data_r(R_hs(:, 2)), 'ro'); % Plot markers for second column
                                        title('Right Foot Traj.');
                                        ylabel('x-displacement (m)');
                                        hold off;
                                    end
                                    end
                                    % Close all figures after adjustments are complete
                                    close all;
                                    

                                                                        %                                     figure(150)
                                    %                                     hold on
                                    %                                     plot(JA(:,12), 'r');
                                    %                                     plot(JA(:,21), 'b');
                                    %                                     ylabel('y knee JA');
                                    %                                     legend('Right', 'Left', 'Location', 'southoutside');
                                    figure(100)
                                    % Left Foot
                                    plot(filtered_data_l,'green');
                                    hold on
                                    plot(L_hs(:,1),filtered_data_l(L_hs(:,1)),'bx')
                                    plot(L_hs(:,2),filtered_data_l(L_hs(:,2)),'bo')
                                    title('Left Foot Traj.')
                                    ylabel('x- displacement (m)')
                                    spreadfigures;
                                    segmentationflag = questdlg('Segmentation on the left is good?','User input','Yes','No','Yes');
                                    if strcmp(segmentationflag,'No')
                                        while true % Infinite loop for adding or removing peaks
                                        % Prompt for action: Remove peaks, Add peaks, or exit
                                        action = questdlg('Select the action to take on the peaks', 'User input', ...
                                                          'Remove peaks', 'Add peaks', 'It looks good now', 'Remove peaks');

                                        % Break the loop if the user selects "It looks good now"
                                        if strcmp(action, 'It looks good now')
                                            break; % Exit the loop
                                        end

                                        % User input for a range (x1, x2) and y threshold by selecting two points
                                        [xs, ys] = ginput(2); % User selects two points
                                        x1 = round(min(xs));  % Ensure x1 is the smaller value
                                        x2 = round(max(xs));  % Ensure x2 is the larger value
                                        y_val = mean(ys);     % Use the average of the y-values as the threshold

                                        if strcmp(action, 'Remove peaks')
                                            % Calculate threshold from the average y-values of ginput
                                            y_val = mean(ys); 
                                            % Process column 1 of R_hs
                                            for col = 1:2
                                                % Find markers in the range [x1, x2]
                                            markers_in_range = L_hs(:, col) >= x1 & L_hs(:, col) <= x2;

                                            % Check amplitudes in filtered_data_r for these markers, processing in reverse order
                                            for i = flip(find(markers_in_range))' % Process from the last index to the first
                                                if filtered_data_l(L_hs(i, col)) < y_val
                                                    % Remove marker (shift values up in the column)
                                                    L_hs(i:end - 1, col) = L_hs(i + 1:end, col); % Shift column up
                                                    L_hs(end, col) = NaN; % Clear the last value
                                                end
                                            end

                                            % Remove any rows where both columns are NaN (completely empty row)
                                            L_hs = L_hs(~all(isnan(L_hs), 2), :);

                                            end

                                            % Fix overlaps between columns (ensure col 2 aligns with next in col 1)
                                            if ~isempty(L_hs)
                                                for i = 1:size(L_hs, 1) - 1
                                                    L_hs(i, 2) = L_hs(i + 1, 1);
                                                end
                                            end
                                        
                                        elseif strcmp(action, 'Add peaks')
                                            % Add peaks in the range [x1, x2] based on filtered_data_r
                                            filtered_segment = filtered_data_l(x1:x2); % Extract data in range
                                            [peaks, locs] = findpeaks(filtered_segment); % Find local maxima in range

                                            % Filter peaks above the threshold
                                            locs = locs(peaks >= y_val);
                                            locs = locs + x1 - 1; % Adjust locs to the original indices

                                            % Add new peaks to R_hs while preserving order
                                            for loc = locs'
                                                % Find the correct place to insert the new peak
                                                insertion_index = find(L_hs(:, 1) > loc, 1, 'first');

                                                if isempty(insertion_index) % If loc is greater than all existing values
                                                    L_hs = [L_hs; loc, loc]; % Add to the end
                                                else
                                                    % Insert the new peak in the correct position
                                                    L_hs = [L_hs(1:insertion_index - 1, :); loc, loc; L_hs(insertion_index:end, :)];
                                                end
                                            end
                                        end
                                        

                                        % Re-plot the updated signal and peaks
                                        figure(100);
                                        plot(filtered_data_l, 'green');
                                        hold on;
                                        plot(L_hs(:, 1), filtered_data_l(L_hs(:, 1)), 'bx'); % Plot markers for first column
                                        plot(L_hs(:, 2), filtered_data_l(L_hs(:, 2)), 'bo'); % Plot markers for second column
                                        title('Right Foot Traj.');
                                        ylabel('x-displacement (m)');
                                        hold off;
                                        end
                                    end
                                    
                                    figure(150)
                                    hold on
                                    plot(JA(:,12), 'r');
                                    plot(JA(:,21), 'b');
                                    ylabel('y knee JA');
                                    legend('Right', 'Left', 'Location', 'southoutside');
                                    
                                    figure(100)
                                    % Left Foot
                                    pl(1) = plot(filtered_data_l,'green');
                                    hold on
                                    plot(L_hs(:,1),filtered_data_l(L_hs(:,1)),'bx')
                                    plot(L_hs(:,2),filtered_data_l(L_hs(:,2)),'bo')
                                    title('Left Foot Traj.')
                                    ylabel('x- displacement (m)')
                                    % Right Foot
                                    figure(110)
                                    pl(2) = plot(filtered_data_r,'yellow');
                                    hold on
                                    plot(R_hs(:,1),filtered_data_r(R_hs(:,1)),'rx')
                                    plot(R_hs(:,2),filtered_data_r(R_hs(:,2)),'ro')
                                    %     xlim([0 frames(end)])
                                    title('Right Foot Traj.')
                                    ylabel('x- displacement (m)')
                                    
                                    figure(150)
                                    hold on
                                    plot(JA(:,12), 'r');
                                    plot(JA(:,21), 'b');
                                    ylabel('y knee JA');
                                    legend('Right', 'Left', 'Location', 'southoutside');
                                    spreadfigures;
                                    waitforbuttonpress;
                                    close all
                                    
                                else
                                    figure(100)
                                    % Left Foot
                                    pl(1) = plot(filtered_data_l,'b');
                                    hold on
                                    plot(L_hs(:,1),filtered_data_l(L_hs(:,1)),'bx')
                                    plot(L_hs(:,2),filtered_data_l(L_hs(:,2)),'bo')
                                    % Right Foot
                                    pl(2) = plot(filtered_data_r,'r');
                                    plot(R_hs(:,1),filtered_data_r(R_hs(:,1)),'rx')
                                    plot(R_hs(:,2),filtered_data_r(R_hs(:,2)),'ro')
                                    %     xlim([0 frames(end)])
                                    title('Foot Traj.')
                                    ylabel('x- displacement (m)')
                                    legend(pl,'Left','Right',  'Location', 'southoutside')
                                    spreadfigures;
                                    % Evaluate the segmentation
                                    segmentationflag = questdlg('Segmentation on the right is good?','User input','Yes','No','Yes');
                                    if strcmp(segmentationflag,'No')
                                        action= questdlg('Select the action to take on the peaks','User input','Delete peaks','Add peaks', 'Select all peaks again', 'Delete peaks');
                                        %side = questdlg('Select the side to segment','User input','Left','Right','Left');
                                        
                                        if strcmp(action,'Select all peaks again')
                                            [locs,~] = ginput();        % Getting the new peaks
                                            locs = floor(locs);
                                            
                                            for i = 1:length(locs)-1
                                                locs2(i,1) = locs(i);
                                                locs2(i,2) = locs(i+1);
                                            end
                                            
                                            R_hs = locs2;
                                            R_hs=fix_peaks(R_hs);
                                            clear locs locs2
                                        elseif strcmp(action,'Add peaks')
                                            [locs,~] = ginput();
                                            locs = floor(locs);
                                            
                                            locs_all=[unique([R_hs(:,1); R_hs(:,2)]); locs];
                                            locs_all=sort(locs_all);
                                            
                                            for i = 1:length(locs_all)-1
                                                locs2(i,1) = locs_all(i);
                                                locs2(i,2) = locs_all(i+1);
                                            end
                                            R_hs = locs2;
                                            R_hs=fix_peaks(R_hs);
                                            clear locs locs2
                                        elseif strcmp(action,'Delete peaks')
                                            [locs,~] = ginput();
                                            locs = floor(locs);
                                            
                                            prev_locs=unique([R_hs(:,1); R_hs(:,2)]);
                                            for i =1:length(locs)
                                                diff = abs(prev_locs -locs(i));
                                                [~, ind] = min(diff);
                                                prev_locs(ind)=[];
                                            end
                                            for i = 1:length(prev_locs)-1
                                                locs2(i,1) = prev_locs(i);
                                                locs2(i,2) = prev_locs(i+1);
                                            end
                                            R_hs = locs2;
                                            R_hs=fix_peaks(R_hs);
                                            clear locs locs2
                                        end
                                    end
                                    segmentationflag = questdlg('Segmentation on the left is good?','User input','Yes','No','Yes');
                                    if strcmp(segmentationflag,'No')
                                        action= questdlg('Select the action to take on the peaks','User input','Delete peaks','Add peaks', 'Select all peaks again', 'Delete peaks');
                                        %side = questdlg('Select the side to segment','User input','Left','Right','Left');
                                        
                                        if strcmp(action,'Select all peaks again')
                                            [locs,~] = ginput();        % Getting the new peaks
                                            locs = floor(locs);
                                            
                                            for i = 1:length(locs)-1
                                                locs2(i,1) = locs(i);
                                                locs2(i,2) = locs(i+1);
                                            end
                                            
                                            L_hs = locs2;
                                            L_hs=fix_peaks(L_hs);
                                            clear locs locs2
                                        elseif strcmp(action,'Add peaks')
                                            [locs,~] = ginput();
                                            locs = floor(locs);
                                            
                                            locs_all=[unique([L_hs(:,1); L_hs(:,2)]); locs];
                                            locs_all=sort(locs_all);
                                            
                                            for i = 1:length(locs_all)-1
                                                locs2(i,1) = locs_all(i);
                                                locs2(i,2) = locs_all(i+1);
                                            end
                                            L_hs = locs2;
                                            L_hs=fix_peaks(L_hs);
                                            clear locs locs2
                                        elseif strcmp(action,'Delete peaks')
                                            [locs,~] = ginput();
                                            locs = floor(locs);
                                            
                                            prev_locs=unique([L_hs(:,1); L_hs(:,2)]);
                                            for i =1:length(locs)
                                                diff = abs(prev_locs -locs(i));
                                                [~, ind] = min(diff);
                                                prev_locs(ind)=[];
                                            end
                                            for i = 1:length(prev_locs)-1
                                                locs2(i,1) = prev_locs(i);
                                                locs2(i,2) = prev_locs(i+1);
                                            end
                                            L_hs = locs2;
                                            L_hs=fix_peaks(L_hs);
                                            clear locs locs2
                                        end
                                    end
                                    close all
                                    
                                    % Display the segmentation
                                    figure(101)
                                    % Left Foot
                                    pl(1) = plot(filtered_data_l,'b');
                                    hold on
                                    plot(L_hs(:,1),filtered_data_l(L_hs(:,1)),'bx')
                                    plot(L_hs(:,2),filtered_data_l(L_hs(:,2)),'bo')
                                    % Right Foot
                                    pl(2) = plot(filtered_data_r,'r');
                                    plot(R_hs(:,1),filtered_data_r(R_hs(:,1)),'rx')
                                    plot(R_hs(:,2),filtered_data_r(R_hs(:,2)),'ro')
                                    %     xlim([0 frames(end)])
                                    title('Foot Traj.')
                                    ylabel('x- displacement (m)')
                                    legend(pl,'Left','Right',  'Location', 'southoutside')
                                    
                                    figure(151)
                                    hold on
                                    plot(JA(:,12), 'r');
                                    plot(JA(:,21), 'b');
                                    ylabel('y knee JA');
                                    legend('Right','Left',  'Location', 'southoutside');
                                    spreadfigures;
                                    
                                    waitforbuttonpress;
                                    close all
                                end
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
                                for i = 1:72  %so we get all the columns
                                    % Stride segmentation based on the left heel strike
                                    if i<=size(JA,2)
                                        [int.Lseg.JA_mean(:,i),int.Lseg.JA_std(:,i),int.Lseg.JA_seg(:,:,i),seg.Lseg.SG_period,seg.Lseg.JA_seg(:,i)]	=...
                                            single_gait(JA(:,i),L_seg_frame,dt);  % Joint kinematics
                                    end
                                    if i<=size(AV,2)
                                        [int.Lseg.AV_mean(:,i),int.Lseg.AV_std(:,i),int.Lseg.AV_seg(:,:,i),~,seg.Lseg.AV_seg(:,i)]                 	=...
                                            single_gait(AV(:,i),L_seg_frame,dt);  % Angular velocity
                                    end
                                    if i<=size(ACC,2)
                                        [int.Lseg.ACC_mean(:,i),int.Lseg.ACC_std(:,i),int.Lseg.ACC_seg(:,:,i),~,seg.Lseg.ACC_seg(:,i)]             	=...
                                            single_gait(ACC(:,i),L_seg_frame,dt); % Acceleration
                                    end
                                    if i<=size(Q,2)
                                        [int.Lseg.Q_mean(:,i),int.Lseg.Q_std(:,i),int.Lseg.Q_seg(:,:,i),~,seg.Lseg.Q_seg(:,i)]             	=...
                                            single_gait(Q(:,i),L_seg_frame,dt); % Orientation
                                    end
                                    if i<=size(Pos,2)
                                        [int.Lseg.Pos_mean(:,i),int.Lseg.Pos_std(:,i),int.Lseg.Pos_seg(:,:,i),~,seg.Lseg.Pos_seg(:,i)]             	=...
                                            single_gait(Pos(:,i),L_seg_frame,dt); % Position
                                    end
                                    %                                     [int.Lseg.PosFiltered_mean(:,i),int.Lseg.PosFiltered_std(:,i),int.Lseg.PosFiltered_seg(:,:,i),~,seg.Lseg.PosFiltered_seg(:,i)]             	=...
                                    %                                         single_gait(filtfilt(b, a, Pos(:,i)),L_seg_frame,dt); % Position - filtered
                                    if i<=size(V,2)
                                        [int.Lseg.V_mean(:,i),int.Lseg.V_std(:,i),int.Lseg.V_seg(:,:,i),~,seg.Lseg.V_seg(:,i)]             	=...
                                            single_gait(V(:,i),L_seg_frame,dt); % Velocity
                                    end
                                    % Stride segmetation based on the right heel strike
                                    if i<=size(JA,2)
                                        [int.Rseg.JA_mean(:,i),int.Rseg.JA_std(:,i),int.Rseg.JA_seg(:,:,i),seg.Rseg.SG_period,seg.Rseg.JA_seg(:,i)]	=...
                                            single_gait(JA(:,i),R_seg_frame,dt);  % Joint kinematics
                                    end
                                    if i<=size(AV,2)
                                        [int.Rseg.AV_mean(:,i),int.Rseg.AV_std(:,i),int.Rseg.AV_seg(:,:,i),~,seg.Rseg.AV_seg(:,i)]                	=...
                                            single_gait(AV(:,i),R_seg_frame,dt);  % Angular velocity
                                    end
                                    if i<=size(ACC,2)
                                        [int.Rseg.ACC_mean(:,i),int.Rseg.ACC_std(:,i),int.Rseg.ACC_seg(:,:,i),~,seg.Rseg.ACC_seg(:,i)]           	=...
                                            single_gait(ACC(:,i),R_seg_frame,dt); % Acceleration
                                    end
                                    if i<=size(Q,2)
                                        [int.Rseg.Q_mean(:,i),int.Rseg.Q_std(:,i),int.Rseg.Q_seg(:,:,i),~,seg.Rseg.Q_seg(:,i)]             	=...
                                            single_gait(Q(:,i),R_seg_frame,dt); % Orientation
                                    end
                                    if i<=size(Pos,2)
                                        [int.Rseg.Pos_mean(:,i),int.Rseg.Pos_std(:,i),int.Rseg.Pos_seg(:,:,i),~,seg.Rseg.Pos_seg(:,i)]             	=...
                                            single_gait(Pos(:,i),R_seg_frame,dt); % Position
                                    end
                                    %                                     [int.Rseg.PosFiltered_mean(:,i),int.Rseg.PosFiltered_std(:,i),int.Rseg.PosFiltered_seg(:,:,i),~,seg.Rseg.PosFiltered_seg(:,i)]             	=...
                                    %                                         single_gait(filtfilt(b, a, Pos(:,i)),R_seg_frame,dt); % Position - filtered
                                    if i<=size(V,2)
                                        [int.Rseg.V_mean(:,i),int.Rseg.V_std(:,i),int.Rseg.V_seg(:,:,i),~,seg.Rseg.V_seg(:,i)]             	=...
                                            single_gait(V(:,i),R_seg_frame,dt); % Velocity
                                    end
                                    
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
                                
                                seg_noint.startframe      = frames(1);
                                seg_noint.stopframe       = frames(end);
                                seg_noint.Lseg.LHS_idx    = L_hs;
                                seg_noint.Rseg.RHS_idx    = R_hs;
                                seg_noint.Lseg.LHS_tim    = time(L_hs);
                                seg_noint.Rseg.RHS_tim    = time(R_hs);
                                seg_noint.Lseg.LTO_idx    = L_to;
                                seg_noint.Rseg.RTO_idx    = R_to;
                                seg_noint.Lseg.LTO_tim    = time(L_to);
                                seg_noint.Rseg.RTO_tim    = time(R_to);
                                
                                %I add here the secmented vector time too, in the same form as the other variables
                                time_segL={};
                                for i=1:size(L_hs,1)
                                    init=find(time==L_hs(i,1));
                                    fin=find(time==L_hs(i,2));
                                    time_segL{i}=time(init:fin);
                                end
                                seg.Lseg.time=time_segL;
                                
                                time_segR={};
                                for i=1:size(R_hs,1)
                                    init=find(time==R_hs(i,1));
                                    fin=find(time==R_hs(i,2));
                                    time_segR{i}=time(init:fin);
                                end
                                seg.Rseg.time=time_segR;
                                
                                if plot_verbosity==1
                                    % Plotting the segmentation - Left side HS
                                    gcf1 = plotdatasegmentedstrides(int.Lseg,'JA');     % Joint kinematics
                                    set(gcf1,'Name','Left HS Seg JA')
                                    gcf2 = plotdatasegmentedstrides(int.Lseg,'ACC');	% Accelerations
                                    set(gcf2,'Name','Left HS Seg ACC')
                                    gcf3 = plotdatasegmentedstrides(int.Lseg,'AV');     % Angular speed
                                    set(gcf3,'Name','Left HS Seg AV')
                                    title('Click to continue')
                                    spreadfigures
                                    waitforbuttonpress;
                                    
                                    % Plotting the segmentation - Right side HS
                                    gcf4 = plotdatasegmentedstrides(int.Rseg,'JA');     % Joint kinematics
                                    set(gcf4,'Name','Right HS Seg JA')
                                    gcf5 = plotdatasegmentedstrides(int.Rseg,'ACC');	% Accelerations
                                    set(gcf5,'Name','Right HS Seg ACC')
                                    gcf6 = plotdatasegmentedstrides(int.Rseg,'AV');     % Angular speed
                                    set(gcf6,'Name','Right HS Seg AV')
                                    title('Click to continue')
                                    spreadfigures
                                    waitforbuttonpress;
                                    close all
                                end
                                
                                % Adding field in the structure
                                %                                 subdata_out.SegmentedInterpolated  = seg;
                                subdata_out.Interpolated 	= int;
                                subdata_out.Segmented 	= seg;
                                lab=ext.Labels;
                                lab.PosFiltered=lab.Pos;
                                lab=rmfield(lab,'ACC_S');
                                lab.Other=[["LHS_idx"; "RHS_idx"; "LHS_tim"; "RHS_tim"; "LTO_idx"; "RTO_idx"; "LTO_tim"; "RTO_tim"], ...
                                    ["Left Heel Strike - Index"; "Right Heel Strike - Index"; "Left Heel Strike - Time"; "Right Heel Strike - Time"; ...
                                    "Left Toe Off - Index"; "Right Toe Off - Index"; "Left Toe Off - Time"; "Right Toe Off - Time"]];
                                subdata_out.Labels          = lab;
                                clear seg R_hs L_hs R_seg_frame L_hs_frame int L_to R_to
                                save((p_name+ "_"+ tt_name + "_Segmented_v2.mat"), 'subdata_out');
                                clear subdata_out
                            end
                        else fprintf('This task is not a gait task')
                        end
                        
                        
                    end
                end
            end
        end
    end
end

cd(folderanalysis)