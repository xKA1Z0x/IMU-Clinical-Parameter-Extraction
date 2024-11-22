function [time,data,Pel,Thigh_L,Thigh_R,Shank_L,Shank_R,Foot_L,Foot_R] = openbionicprodata(filein)
file_id     = H5F.open(filein);
info        = h5info(filein);
h5disp(filein);
% Identifier of the first sensor useful for system identification
id_string   = info.Groups(1).Name;  

switch id_string
    case '/1a330134'
        % Data collected with System 1
%         str_time    = '/1a330134/ts_sec';
        str_data    = '/meta_data_json';
        str_pelvis  = '/la330134/acc_gyr_mag_quat';
        str_thigh_l = '/273f0133/acc_gyr_mag_quat';
        str_thigh_r = '/25460d34/acc_gyr_mag_quat';
        str_shank_l = '/30440530/acc_gyr_mag_quat';
        str_shank_r = '/37410e33/acc_gyr_mag_quat';
        str_foot_l  = '/2e291738/acc_gyr_mag_quat';
        str_foot_r  = '/32330d34/acc_gyr_mag_quat';
        
        tim_pelvis  = '/la330134/ts_sec';
        tim_thigh_l = '/273f0133/ts_sec';
        tim_thigh_r = '/25460d34/ts_sec';
        tim_shank_l = '/30440530/ts_sec';
        tim_shank_r = '/37410e33/ts_sec';
        tim_foot_l  = '/2e291738/ts_sec';
        tim_foot_r  = '/32330d34/ts_sec';   
    case '/25340c38'
        % Data collected with System 2
%         str_time    = '/273c0e31/ts_sec';
        str_data    = '/meta_data_json';
        str_pelvis  = '/273c0e31/acc_gyr_mag_quat';
        str_thigh_l = '/35430f31/acc_gyr_mag_quat';
        str_thigh_r = '/25340c38/acc_gyr_mag_quat';
        str_shank_l = '/39370c31/acc_gyr_mag_quat';
        str_shank_r = '/3f371031/acc_gyr_mag_quat';
        str_foot_l  = '/272d0d34/acc_gyr_mag_quat';
        str_foot_r  = '/2f2e0134/acc_gyr_mag_quat';
        
        tim_pelvis  = '/273c0e31/ts_sec';
        tim_thigh_l = '/35430f31/ts_sec';
        tim_thigh_r = '/25340c38/ts_sec';
        tim_shank_l = '/39370c31/ts_sec';
        tim_shank_r = '/3f371031/ts_sec';
        tim_foot_l  = '/272d0d34/ts_sec';
        tim_foot_r  = '/2f2e0134/ts_sec';
    case '/211e0534'
        % Data collected with System 3
%         str_time    = '/211e0534/ts_sec';
        str_data    = '/meta_data_json';
        str_pelvis  = '/37270d33/acc_gyr_mag_quat';
        str_thigh_l = '/211e0534/acc_gyr_mag_quat';
        str_thigh_r = '/2c321738/acc_gyr_mag_quat';
        str_shank_l = '/35380134/acc_gyr_mag_quat';
        str_shank_r = '/21400134/acc_gyr_mag_quat';
        str_foot_l  = '/40251738/acc_gyr_mag_quat';
        str_foot_r  = '/2f1b0530/acc_gyr_mag_quat'; 
        
        tim_pelvis  = '/37270d33/ts_sec';
        tim_thigh_l = '/211e0534/ts_sec';
        tim_thigh_r = '/2c321738/ts_sec';
        tim_shank_l = '/35380134/ts_sec';
        tim_shank_r = '/21400134/ts_sec';
        tim_foot_l  = '/40251738/ts_sec';
        tim_foot_r  = '/2f1b0530/ts_sec'; 
    case '/1b2b0930'
        % Data collected with System 4
%         str_time    = '/20280534/ts_sec';
        str_data    = '/meta_data_json';
        str_pelvis  = '/3d300730/acc_gyr_mag_quat';
        str_thigh_l = '/1b2b0930/acc_gyr_mag_quat';
        str_thigh_r = '/2a430134/acc_gyr_mag_quat';
        str_shank_l = '/2f250230/acc_gyr_mag_quat';
        str_shank_r = '/361c0d33/acc_gyr_mag_quat';
        str_foot_l  = '/27350230/acc_gyr_mag_quat';
        str_foot_r  = '/20280534/acc_gyr_mag_quat';  
        
        tim_pelvis  = '/3d300730/ts_sec';
        tim_thigh_l = '/1b2b0930/ts_sec';
        tim_thigh_r = '/2a430134/ts_sec';
        tim_shank_l = '/2f250230/ts_sec';
        tim_shank_r = '/361c0d33/ts_sec';
        tim_foot_l  = '/27350230/ts_sec';
        tim_foot_r  = '/20280534/ts_sec';
    case '/1a2d0230'
        % Data collected with System 5
%         str_time    = '/1a2d0230/ts_sec';
        str_data    = '/meta_data_json';
        str_pelvis  = '/302b1738/acc_gyr_mag_quat';
        str_thigh_l = '/37410530/acc_gyr_mag_quat';
        str_thigh_r = '/2e311738/acc_gyr_mag_quat';
        str_shank_l = '/20290534/acc_gyr_mag_quat';
        str_shank_r = '/241a0d34/acc_gyr_mag_quat';
        str_foot_l  = '/1a2d0230/acc_gyr_mag_quat';
        str_foot_r  = '/37460530/acc_gyr_mag_quat';
        
        tim_pelvis  = '/302b1738/ts_sec';
        tim_thigh_l = '/37410530/ts_sec';
        tim_thigh_r = '/2e311738/ts_sec';
        tim_shank_l = '/20290534/ts_sec';
        tim_shank_r = '/241a0d34/ts_sec';
        tim_foot_l  = '/1a2d0230/ts_sec';
        tim_foot_r  = '/37460530/ts_sec';
    otherwise
        disp('Error - system not found')
        return
end
% Sensor reading
data    = h5read(filein, str_data);	% data information
% Pelvis IMU
try
    time_pe	= h5read(filein, tim_pelvis);	% time vector
    Pel     = h5read(filein, str_pelvis);
catch
    Pel	= zeros(4,4,length(time_pe));
end
% Foot Left
try
    time_lf	= h5read(filein, tim_foot_l);	% time vector
    Foot_L	= h5read(filein, str_foot_l);
catch
    Foot_L  = zeros(4,4,length(time_lf));
end
% Foot Right
try
    time_rf	= h5read(filein, tim_foot_r);	% time vector
    Foot_R	= h5read(filein, str_foot_r);
catch
    Foot_R  = zeros(4,4,length(time_rf));
end
% Thigh Left
try
    time_lt	= h5read(filein, tim_thigh_l);	% time vector
    Thigh_L	= h5read(filein, str_thigh_l);
catch
    Thigh_L = zeros(4,4,length(time_lt));
end
% Thigh Right
try
    time_rt	= h5read(filein, tim_thigh_r);	% time vector
    Thigh_R	= h5read(filein, str_thigh_r);
catch
    Thigh_R = zeros(4,4,length(time_rt));
end
% Shank Left
try
    time_ls	= h5read(filein, tim_shank_l);	% time vector
    Shank_L	= h5read(filein, str_shank_l); 
catch
    try % Alexian has 1 swapped sensor
        Shank_L	= h5read(filein, '/30440530/acc_gyr_mag_quat');
    catch
        Shank_L = zeros(4,4,length(time_ls));
    end
end
% Shank Right
try
    time_rs	= h5read(filein, tim_shank_r);	% time vector
    Shank_R	= h5read(filein, str_shank_r);
catch
    Shank_R = zeros(4,4,length(time_rs));
end
if isequal(time_pe,time_lt,time_rt,time_ls,time_rs,time_lf,time_rf)
    time = time_pe;
else
    time = [max([time_pe(1),time_lt(1),time_rt(1),time_rs(1),time_ls(1),time_rf(1),time_lf(1)]):0.002:...
        min([time_pe(end),time_lt(end),time_rt(end),time_rs(end),time_ls(end),time_rf(end),time_lf(end)])];
    % Resampling for time compitability
    for i = 1 : 4
        for j = 1 : 4
            if i == 4 & j < 4
                PE_res(i,j,:) = nan;
                RT_res(i,j,:) = nan;
                LT_res(i,j,:) = nan;
                RS_res(i,j,:) = nan;
                LS_res(i,j,:) = nan;
                RF_res(i,j,:) = nan;
                LF_res(i,j,:) = nan;
            else
                PE_res(i,j,:) = interp1(time_pe,squeeze(Pel(i,j,:)),time,'spline');
                RT_res(i,j,:) = interp1(time_rt,squeeze(Thigh_R(i,j,:)),time,'spline');
                LT_res(i,j,:) = interp1(time_lt,squeeze(Thigh_L(i,j,:)),time,'spline');
                RS_res(i,j,:) = interp1(time_rs,squeeze(Shank_R(i,j,:)),time,'spline');
                LS_res(i,j,:) = interp1(time_ls,squeeze(Shank_L(i,j,:)),time,'spline');
                RF_res(i,j,:) = interp1(time_rf,squeeze(Foot_R(i,j,:)),time,'spline');
                LF_res(i,j,:) = interp1(time_lf,squeeze(Foot_L(i,j,:)),time,'spline');
            end
        end
    end
    clear Pel Thigh_L Thigh_R Shank_L Shank_R Foot_L Foot_R
    Pel     = PE_res;
    Thigh_L = LT_res;
    Thigh_R = RT_res;
    Shank_L = LS_res;
    Shank_R = RS_res;
    Foot_L  = LF_res;
    Foot_R  = RF_res;
end
end