function [structout] = madgwickpipeline(Gyroscope,Accelerometer,fs,time,beta_ahrs,footflat_interval)
structout = struct();   % Output struct
if isnan(Gyroscope) | isnan(Accelerometer)
    structout.quaternions               = nan; 	% Quaternions
    structout.euler_angles              = nan; 	% Euler angles
    structout.acc_ext                   = nan;	% Acceleration in the external reference frame
    structout.acc_ext_Gfree             = nan; 	% Acceleration in the external reference frame without the G component
    structout.gyr_ext                   = nan; 	% Gyriscope in the external reference frame
    structout.speed_ext                 = nan;	% Linear speed in the external reference frame
    structout.speed_ext_nodrift         = nan; 	% Linear speed in the external reference frame - drift free
    structout.position_ext              = nan; 	% Position in the external reference frame
    structout.position_ext_nodrift      = nan; 	% Position in the external reference frame - drift free
    structout.rotation_matrix_ext_int	= nan;	% Rotation matrix from the external to the internal reference frame
    structout.position_int_nodrift      = nan;	% Positon in the internal reference frame - drift free
    structout.speed_int_nodrift         = nan;	% Positon in the internal reference frame - drift free
    return
end
%% Process sensor data through algorithm
AHRS        = MadgwickAHRS('SamplePeriod', 1/fs, 'Beta', beta_ahrs);
quaternion  = zeros(length(time), 4);
for t = 1:length(time)
    if sum(isnan(Gyroscope(t,:))) > 0 || sum(isnan(Accelerometer(t,:))) > 0
        quaternion(t,:) = [nan,nan,nan,nan];
    else
        AHRS.UpdateIMU(Gyroscope(t,:), Accelerometer(t,:));	% gyroscope units must be radians
        quaternion(t, :) = AHRS.Quaternion;
    end
end
euler = quatern2euler(quaternConj(quaternion)) * (180/pi);
%% Select convergence of the quaternions
figure, hold on,
plot(quaternion)
title('Select the point when the quaternion converged and the staring point')
[x,~]   = ginput(2);
x       = floor(x);
convergence_idx = 1 : x(1);
reset_idx       = floor(mean(footflat_interval,2));
reset_idx       = [x(2);reset_idx];
footflat_interval = [nan,nan;footflat_interval];
close
%% Acceleration estimation
dt              = 1/fs;                         % Sampling time
quaternion_conj = quaternConj(quaternion);      % Quaternion conjugate
reset_count     = 0;                            % Counter initialization
v_E_nodrift     = zeros(length(time),3);        % Initialization

for t = 1:length(time)
    % Accelerometer rotation through quaternions multiplication
    q1  = quaternion(t,:);                      % First term of multiplication
    q2  = [0 Accelerometer(t,:)];               % Second term of multiplication
    q3	= quaternion_conj(t,:);                 % Third term of multiplication 
    q12 = quaternProd(q1,q2);                   % First and second multiplication
    q123(t,:)           = quaternProd(q12,q3);  % q123 = q1 x q2 x q3
    acc_E(t,:)          = q123(t,2:end);        % Acceleration in the external frame
    acc_E_G_free(t,:)   = acc_E(t,:) - [0 0 1]; % G-free acceleration    
    % Linear speed in the external reference frame
    if ~ismember(t,convergence_idx)    % After convergence of quaternions
        if ~isnan(acc_E_G_free(t,:))
            if ~isnan(acc_E_G_free(t-1,:))
                % Numeric integration of the acceleration
                v_E(t,:)	= v_E(t-1,:) + 0.5*9.81*(acc_E_G_free(t,:)+acc_E_G_free(t-1,:))*dt;
            else
                % If the previous is NaN let's assume that is equal to the
                % current one
                v_E(t,:)	= v_E(t-1,:) + 0.5*9.81*(acc_E_G_free(t,:)*2)*dt;
            end
        else
            v_E(t,:)    = v_E(t-1,:);
        end
    else
        v_E(t,:)	= [0 0 0];
    end   
    % Numerical integration of the linear speed
    try
        if ~isnan(acc_E_G_free(t,:))
            p_E(t,:)	= p_E(t-1,:) + 0.5*(v_E(t,:)+v_E(t-1,:))*dt;
        else
            p_E(t,:)    = p_E(t-1,:);
        end
    catch
        p_E(t,:)	= [0 0 0];
    end    
    % Angular speed in the external reference frame
    % Gyroscope rotation through quaternions multiplication
    % q1 is the quaternion, q3 its conjugare
    q2              = [0 Gyroscope(t,:)];
    q12             = quaternProd(q1,q2);
    q123            = quaternProd(q12,q3);  % q123 = q1 x q2 x q3
    omega_E(t,:)    = deg2rad(q123(2:end)); % Gyroscope in the external frame   
    % Computation of the linear speed at the mid-stance time points under
    % the assumption of the inverted pendulum model
    acc_dir(t,:)    = acc_E(t,:)/(norm(acc_E(t,:)));    % Orientation of the local reference frame
    % Reset at the mid-stance points
    if ismember(t,reset_idx)
        reset_count = reset_count + 1;
        % Expcted speed from the foot flat assumption assumption
        v_E_hat(reset_count,:)      = [0 0 0];
        v_E_est(reset_count,:)      = v_E(t,:);     % Estimate speed
        time_reset(reset_count,:)   = t*dt;     
    end
end
%% Loop for post-hoc drift compensation
for i = 1 : reset_count-1
    idx = find(reset_idx(i)>footflat_interval(:,1) & reset_idx(i)<footflat_interval(:,2),1,'first');
    if isempty(idx)
        idx = 1;
        start_idx   = reset_idx(i);
        stop_idx    = footflat_interval(2,1);
    else
        start_idx   = footflat_interval(idx,2);
        stop_idx    = footflat_interval(idx+1,1);
    end
    % Correction of the linear speed substracting the estimated error
    v_E_nodrift(footflat_interval(idx+1,1):footflat_interval(idx+1,2),:)	=...
        v_E(footflat_interval(idx+1,1):footflat_interval(idx+1,2),:) -...
        median(v_E(footflat_interval(idx+1,1):footflat_interval(idx+1,2),:));
    
    % Drift compensation - Linear drift assumption
    beta(i,:)       = v_E(start_idx,:) - v_E_nodrift(start_idx,:);  % Offset computation
    % Linear term computation - linear error from two mid-stance timepoints
    try
        alfa_num    = (v_E(stop_idx,:) - v_E_nodrift(stop_idx,:)) - ...
            (v_E(start_idx,:) - v_E_nodrift(start_idx,:));
        alfa_den    = time(stop_idx) - time(start_idx);
        alfa(i,:)   = alfa_num/alfa_den;
    catch
        alfa(i,:)   = [0 0 0];
    end
    % Correction of the linear speed substracting the estimated error
    for j = start_idx:stop_idx      
        error(j,:)          = alfa(i,:)*(dt*(j-start_idx))+beta(i,:);
        v_E_nodrift(j,:)    = v_E(j,:) - error(j,:);
    end
         
    % Drift compensation - Linear drift assumption
%     beta(i,:)       = v_E_est(i,:) - v_E_hat(i,:);  % Offset computation
%     % Linear term computation - linear error from two mid-stance timepoints
%     try
%         alfa_num    = (v_E_est(i+1,:) - v_E_hat(i+1,:)) - ...
%             (v_E_est(i,:) - v_E_hat(i,:));
%         alfa_den    = time_reset(i+1,:) - time_reset(i,:);
%         alfa(i,:)   = alfa_num/alfa_den;
%     catch
%         alfa(i,:)   = [0 0 0];
%     end
%     % Correction of the linear speed substracting the estimated error
%     for j = reset_idx(i):reset_idx(i+1)
%         error(j,:)          = alfa(i,:)*(j*dt-time_reset(i,:))+beta(i,:);
%         v_E_nodrift(j,:)    = v_E(j,:) - error(j,:);
%     end
end
close all,figure,plot(v_E_nodrift),waitforbuttonpress
%% Position in the external reference frame
for k = 1 : length(time)
    % Numerical integration of the linear speed
    try
        p_E_nodrift(k,:)	= p_E_nodrift(k-1,:) + 0.5*(v_E_nodrift(k,:)+v_E_nodrift(k-1,:))*dt;
    catch
        p_E_nodrift(k,:)	= [0 0 0];
    end
end
% Rotation of the reference frame in a a system aligned with the direction
% of walking
p_P     = zeros(length(time),3);    % Init of the vector
I_mat   = eye(3);                   % Identity matrix
for i = 2 : reset_count
    % X axis is aligned with direction of walking
    x_E(i,:) = (p_E_nodrift(reset_idx(i),:)-p_E_nodrift(reset_idx(i-1),:))./norm(p_E_nodrift(reset_idx(i),:)-p_E_nodrift(reset_idx(i-1),:));
    % Y axis is external
    y_E(i,:) = cross(x_E(i,:),[0 0 1])./norm(cross(x_E(i,:),[0 0 1]));
    % Z axis is vertical
    z_E(i,:) = cross(y_E(i,:),x_E(i,:))./norm(cross(y_E(i,:),x_E(i,:)));
    % Matrix of the external reference frame
    P_E{i}  = [x_E(i,:)' y_E(i,:)' z_E(i,:)'];
    % Matrix of rotation in the new reference frame
    R_EP{i}  = I_mat*inv(P_E{i});
    % Rotation of the position vector
    for j = reset_idx(i-1):reset_idx(i)
        p_P(j,:) = R_EP{i}*p_E_nodrift(j,:)';
        v_P(j,:) = R_EP{i}*v_E_nodrift(j,:)';
    end
end
%% Data saving in the output structure
structout.quaternions           = quaternion;       % Quaternions
structout.euler_angles          = euler;            % Euler angles
structout.acc_ext               = acc_E;            % Acceleration in the external reference frame
structout.acc_ext_Gfree         = acc_E_G_free;     % Acceleration in the external reference frame without the G component
structout.gyr_ext               = omega_E;          % Gyriscope in the external reference frame
structout.speed_ext             = v_E;              % Linear speed in the external reference frame
structout.speed_ext_nodrift     = v_E_nodrift;      % Linear speed in the external reference frame - drift free
structout.position_ext          = p_E;              % Position in the external reference frame
structout.position_ext_nodrift	= p_E_nodrift;   	% Position in the external reference frame - drift free
structout.rotation_matrix_ext_int   = R_EP;         % Rotation matrix from the external to the internal reference frame
structout.position_int_nodrift  = p_P;              % Positon in the internal reference frame - drift free
structout.speed_int_nodrift     = v_P;              % Positon in the internal reference frame - drift free

end