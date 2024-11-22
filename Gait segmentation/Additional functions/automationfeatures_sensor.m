function featureout = automationfeatures_sensor(datain_right,datain_left,sensorstr,dt,Hz)
Axesnames 	= strcat({'Pe_x','Pe_y','Ph_z','Th_x','Th_y','Th_z','Sh_x','Sh_y','Sh_z','Fo_x','Fo_y','Fo_z'},['_' sensorstr]);
NumStepsR  	= size(datain_right,2);             % Number of right steps
NumStepsL 	= size(datain_left,2);              % Number of left steps
data_all 	= cat(2,datain_right,datain_left);  % All profiles togetehr
% feat     	= nan(size(data_all,2),22,size(data_all,3)); % Initialization

for s = 1 : size(data_all,2)        % Stride
    for a = 1 : size(data_all,3)	% Sensor axis
        data            = data_all(:,s,a);
        feat(s,1).(['Feat1',Axesnames{a}])	= sum(abs(data))*dt;    % Feature 1: amount of motion
        feat(s,1).(['Feat2',Axesnames{a}]) 	= mean(data);           % Feature 2: mean
        feat(s,1).(['Feat3',Axesnames{a}]) 	= range(data);          % Feature 3: range of values
        feat(s,1).(['Feat4',Axesnames{a}]) 	= rms(data);            % Feature 4: root mean squared value
        feat(s,1).(['Feat5',Axesnames{a}]) 	= std(data);            % Feature 5: std
        feat(s,1).(['Feat6',Axesnames{a}])	= median(data);         % Feature 6: median
        feat(s,1).(['Feat7',Axesnames{a}]) 	= iqr(data);            % Feature 7: inter-quartile range
        feat(s,1).(['Feat8',Axesnames{a}]) 	= skewness(data);       % Feature 8: skewness
        feat(s,1).(['Feat9',Axesnames{a}]) 	= kurtosis(data);       % Feature 9: kurtosis
        feat(s,1).(['Feat10',Axesnames{a}])	= sampen(data,1,.2); 	% Feature 10: sample entropy
        ffdata          = FFeatures(data,Hz);	% Frequency domains features
        feat(s,1).(['Feat11',Axesnames{a}])	= ffdata(1);            % Feature 11: Dominant power magnitude
        feat(s,1).(['Feat12',Axesnames{a}])	= ffdata(2);            % Feature 12: dominant frequency
        feat(s,1).(['Feat13',Axesnames{a}])	= ffdata(3);            % Feature 13: mean of PSD
        feat(s,1).(['Feat14',Axesnames{a}])	= ffdata(4);            % Feature 14: std of PSD
        feat(s,1).(['Feat15',Axesnames{a}])	= ffdata(5);            % Feature 15: skewness of PSD
        feat(s,1).(['Feat16',Axesnames{a}])	= ffdata(6);            % Feature 16: kurtosis of PSD
        % Maximum and minimum values and locations
        [Mvalue,Midx]  = max(data);
        feat(s,1).(['Feat17',Axesnames{a}]) = Mvalue;               % Feature 17: maximum value
        feat(s,1).(['Feat18',Axesnames{a}])	= Midx;                 % Feature 18: maximum value location
        [mvalue,midx]  = min(data);
        feat(s,1).(['Feat19',Axesnames{a}]) = mvalue;               % Feature 19: minimum value
        feat(s,1).(['Feat20',Axesnames{a}])	= midx;                 % Feature 20: minimum value location
        feat(s,1).(['Feat21',Axesnames{a}])	= Midx-midx;            % Feature 21: max-min time distance
        
        if mod(a,3) == 2 % One time features computation
            feat(s,1).(['Feat22',Axesnames{a}([1:3,6,7]),'_xy'])	= corr(data_all(:,s,a-1),data_all(:,s,a));      % Feature 22: x-y Pearson correlation
            feat(s,1).(['Feat23',Axesnames{a}([1:3,6,7]),'_xz'])	= corr(data_all(:,s,a-1),data_all(:,s,a+1));   	% Feature 23: x-z Pearson correlation
            feat(s,1).(['Feat24',Axesnames{a}([1:3,6,7]),'_zy'])	= corr(data_all(:,s,a+1),data_all(:,s,a));      % Feature 24: z-y Pearson correlation
        end
        
        if s <= min(NumStepsL,NumStepsR)
            feat(s,1).(['Feat25',Axesnames{a}])	= corr(datain_right(:,s,a),datain_left(:,s,a));	% Feature 25: left-right Pearson correlation
        else
            feat(s,1).(['Feat25',Axesnames{a}])	= nan;
        end
        
        % Axis Specific features
        switch a + 12*(strcmp(sensorstr,'acc'))
            case 8  % Shank Gyroscope around y-axis
                [swpk_val,swpk_idx] = max(data(50:end));
                feat(s,1).(['Feat26',Axesnames{a}]) = swpk_val;             % Feature 26: maximum value during swing
                feat(s,1).(['Feat27',Axesnames{a}]) = swpk_idx;             % Feature 27: maximum value timing during swing
            case 9  % Foot Gyroscope around y-axis
                [topk_val,topk_idx] = min(data(40:70));
                feat(s,1).(['Feat28',Axesnames{a}]) = topk_val;             % Feature 28: Toe-off Gyro value
                feat(s,1).(['Feat29',Axesnames{a}]) = topk_idx+40;          % Feature 29: Toe-off timing
                [fosw_val,fosw_idx] = max(data(40+topk_idx:end));
                feat(s,1).(['Feat30',Axesnames{a}]) = fosw_val;             % Feature 30: Max Gyro value in swing
                feat(s,1).(['Feat31',Axesnames{a}]) = fosw_idx+topk_idx+40;	% Feature 31: Max Gyro value in swing timing            
        end
    end   
end
featureout = varfun(@nanmean, struct2table(feat), 'InputVariables', @isnumeric);
return
end