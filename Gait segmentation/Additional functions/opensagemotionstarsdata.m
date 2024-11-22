function [Pel,Thigh_L,Thigh_R,Shank_L,Shank_R,Foot_L,Foot_R] = opensagemotionstarsdata(filein)
% This function reads the cvs file from sagemotion sensors and save them in
% mat files. Sensors are assigned according the following standard:
% Sensor 1 is Pelvis, 2 Right Thigh, 3 Left Thigh, 4 Right Shank, 5 Left
% Shank, 6 Right Foot, 7 Left foot.
% Additional processing is added for resampling and checking
% Version 1 - Jun 2023, FL

opts = delimitedTextImportOptions("NumVariables", 112);
opts.VariableNames = ["SensorIndex_1", "AccelX_1", "AccelY_1", "AccelZ_1", "GyroX_1", "GyroY_1", "GyroZ_1", "MagX_1", "MagY_1", "MagZ_1", "Quat1_1", "Quat2_1", "Quat3_1", "Quat4_1", "Sampletime_1", "Package_1", "SensorIndex_2", "AccelX_2", "AccelY_2", "AccelZ_2", "GyroX_2", "GyroY_2", "GyroZ_2", "MagX_2", "MagY_2", "MagZ_2", "Quat1_2", "Quat2_2", "Quat3_2", "Quat4_2", "Sampletime_2", "Package_2", "SensorIndex_3", "AccelX_3", "AccelY_3", "AccelZ_3", "GyroX_3", "GyroY_3", "GyroZ_3", "MagX_3", "MagY_3", "MagZ_3", "Quat1_3", "Quat2_3", "Quat3_3", "Quat4_3", "Sampletime_3", "Package_3", "SensorIndex_4", "AccelX_4", "AccelY_4", "AccelZ_4", "GyroX_4", "GyroY_4", "GyroZ_4", "MagX_4", "MagY_4", "MagZ_4", "Quat1_4", "Quat2_4", "Quat3_4", "Quat4_4", "Sampletime_4", "Package_4", "SensorIndex_5", "AccelX_5", "AccelY_5", "AccelZ_5", "GyroX_5", "GyroY_5", "GyroZ_5", "MagX_5", "MagY_5", "MagZ_5", "Quat1_5", "Quat2_5", "Quat3_5", "Quat4_5", "Sampletime_5", "Package_5", "SensorIndex_6", "AccelX_6", "AccelY_6", "AccelZ_6", "GyroX_6", "GyroY_6", "GyroZ_6", "MagX_6", "MagY_6", "MagZ_6", "Quat1_6", "Quat2_6", "Quat3_6", "Quat4_6", "Sampletime_6", "Package_6", "SensorIndex_7", "AccelX_7", "AccelY_7", "AccelZ_7", "GyroX_7", "GyroY_7", "GyroZ_7", "MagX_7", "MagY_7", "MagZ_7", "Quat1_7", "Quat2_7", "Quat3_7", "Quat4_7", "Sampletime_7", "Package_7"];
opts.VariableTypes = ["double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double"];
opts.ExtraColumnsRule = "ignore";
opts.EmptyLineRule = "read";
opts.DataLines = [2 Inf];
data_load = readtable(filein,opts);

% Pelvis IMU
try
    Pel	= data_load(:,1:16);
    Pel.Properties.VariableNames = erase(Pel.Properties.VariableNames,"_1");
    Pel = timecorrectionresampling(Pel);
catch
    % TO BE DEFINED
    Pel	= zeros(4,4,length(time));
end
% Foot Left
try
    Foot_L	= data_load(:,97:112);
    Foot_L.Properties.VariableNames = erase(Foot_L.Properties.VariableNames,"_7");
    Foot_L = timecorrectionresampling(Foot_L);
catch
    % TBD
    Foot_L  = zeros(4,4,length(time));
end
% Foot Right
try
    Foot_R	= data_load(:,81:96);
    Foot_R.Properties.VariableNames = erase(Foot_R.Properties.VariableNames,"_6");
    Foot_R = timecorrectionresampling(Foot_R);
catch
    Foot_R  = zeros(4,4,length(time));
end
% Thigh Left
try
    Thigh_L	= data_load(:,33:48);
    Thigh_L.Properties.VariableNames = erase(Thigh_L.Properties.VariableNames,"_3");
    Thigh_L = timecorrectionresampling(Thigh_L);
catch
    Thigh_L = zeros(4,4,length(time));
end
% Thigh Right
try
    Thigh_R	= data_load(:,17:32);
    Thigh_R.Properties.VariableNames = erase(Thigh_R.Properties.VariableNames,"_2");
    Thigh_R = timecorrectionresampling(Thigh_R);
catch
    %TBF
    Thigh_R = zeros(4,4,length(time));
end
% Shank Left
try
    Shank_L	= data_load(:,65:80);
    Shank_L.Properties.VariableNames = erase(Shank_L.Properties.VariableNames,"_5");
    Shank_L = timecorrectionresampling(Shank_L);
catch
    %TBD
    return
end
% Shank Right
try
    Shank_R	= data_load(:,49:64);
    Shank_R.Properties.VariableNames = erase(Shank_R.Properties.VariableNames,"_4");
    Shank_R = timecorrectionresampling(Shank_R);
catch
    % TBD
    Shank_R = zeros(4,4,length(time));
end
end

function tbl_out = timecorrectionresampling(tbl_in)
tbl_out	= tbl_in;
tbl_out(isnan(tbl_out.Sampletime),:) = [];
% Part 1 - Adjust the time vector
time    = tbl_in.Sampletime;
Time    = time - time(1);
dt      = [0;diff(Time)];
for t = 2 : numel(Time)
    if (dt(t) < 0) & abs(dt(t)) > 2^15
        dt(t)	= dt(t) + 2^16;
    end     
    Time(t)  = Time(t-1) + dt(t);
end

% Part 2 - resample the data
% time_true = [0:10:length(time)*10-1]';
time_true   = [0:10:Time(end)-10]';
% arr_out     = table2array(tbl_out);
% arr_out(:,15) = time_true;
tbl_out.Sampletime(1:length(time_true)) = time_true/1000;   % Time in seconds
tbl_out.Package(tbl_out.Package+1)      = tbl_out.Package;  % Time in seconds
for i = 2:14
    y_in    = tbl_in.(i);
    try
        y_out   = interp1(Time,y_in,time_true,'spline');
        % Check for big jumps in time -i.e. disconnection (just one disconnection)
        if ~isempty(find(diff(Time)>300))
            idx        	= find(diff(Time)>300);
            for j = 1 : numel(idx)
                %             length_nan      = ceil((Time(idx(j)+1)-Time(idx(j)))/10);
                [~,start_idx]   = min(abs(time_true-Time(idx(j))));
                [~,stop_idx]    = min(abs(time_true-Time(idx(j)+1)));
                y_out(start_idx:stop_idx) = nan;
            end
        end
    catch
        y_out = y_in;
    end
    tbl_out.(i)(1:length(y_out)) = y_out;
end
% Remove last sample to avoid extrapolation
tbl_out(end,:) = [];
end