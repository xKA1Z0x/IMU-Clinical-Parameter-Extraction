function featureout = automationfeatures_sensor_hc_v2(datain_right,datain_left,sensorstr,template,dt,Hz,rhs,rto,lhs,lto)
if strcmp(sensorstr,'ac') | strcmp(sensorstr,'av')
    Axesnames 	= strcat({'Pe_x','Pe_y','Ph_z','Th_x','Th_y','Th_z','Sh_x','Sh_y','Sh_z','Fo_x','Fo_y','Fo_z'},['_' sensorstr]);
else
    Axesnames 	= strcat({'H_x','H_y','H_z','K_x','K_y','K_z','A_x','A_y','A_z'},['_' sensorstr]);
end
Sidename    = {'_R_','_L_'};
NumStepsR  	= size(datain_right,1);             % Number of right steps
NumStepsL 	= size(datain_left,1);              % Number of left steps
data_all 	= cat(1,datain_right,datain_left);  % All profiles togetehr
% feat     	= nan(size(data_all,2),22,size(data_all,3)); % Initialization
TO_idx      = [rto'-rhs(:,1)+1;lto'-lhs(:,1)+1];
for s = 1 : size(data_all,1)        % Stride
    for a = 1 : size(data_all,2)	% Sensor axis
        data	= data_all{s,a}; 
        T       = length(data);     % Number of samples - iteration
        if s <= NumStepsR
            featlabel = strcat(Sidename{1},Axesnames);
        else
            featlabel = strcat(Sidename{2},Axesnames);
        end
        
        % Traditional features
        if strcmp(sensorstr,'av')
            feat(s,1).(['Feat01',featlabel{a}])	= sum(abs(data))*dt;% Feature 1: amount of motion
        end
        feat(s,1).(['Feat02',featlabel{a}])	= mean(data);           % Feature 2: mean
        feat(s,1).(['Feat03',featlabel{a}])	= range(data);          % Feature 3: range of values
        feat(s,1).(['Feat04',featlabel{a}])	= rms(data);            % Feature 4: root mean squared value
        feat(s,1).(['Feat05',featlabel{a}])	= std(data);            % Feature 5: std
        feat(s,1).(['Feat06',featlabel{a}])	= median(data);         % Feature 6: median
        feat(s,1).(['Feat07',featlabel{a}])	= iqr(data);            % Feature 7: inter-quartile range
        feat(s,1).(['Feat08',featlabel{a}])	= skewness(data);       % Feature 8: skewness
        feat(s,1).(['Feat09',featlabel{a}])	= kurtosis(data);       % Feature 9: kurtosis
        feat(s,1).(['Feat10',featlabel{a}])	= sampen(data,1,.2,'chebychev');	% Feature 10: sample entropy
        
        % Frequency domains features
        ffdata	= FFeatures(data,Hz);	
        feat(s,1).(['Feat11',featlabel{a}])	= ffdata(1);            % Feature 11: Dominant power magnitude
        feat(s,1).(['Feat12',featlabel{a}])	= ffdata(2);            % Feature 12: dominant frequency
        feat(s,1).(['Feat13',featlabel{a}])	= ffdata(3);            % Feature 13: mean of PSD
        feat(s,1).(['Feat14',featlabel{a}])	= ffdata(4);            % Feature 14: std of PSD
        feat(s,1).(['Feat15',featlabel{a}])	= ffdata(5);            % Feature 15: skewness of PSD
        feat(s,1).(['Feat16',featlabel{a}])	= ffdata(6);            % Feature 16: kurtosis of PSD
        
        % Maximum and minimum values and locations
        [Mvalue,Midx]  = max(data);
        feat(s,1).(['Feat17',featlabel{a}]) = Mvalue;               % Feature 17: maximum value
        feat(s,1).(['Feat18',featlabel{a}])	= 100*Midx/T;         	% Feature 18: maximum value location (%)
        [mvalue,midx]  = min(data);
        feat(s,1).(['Feat19',featlabel{a}]) = mvalue;               % Feature 19: minimum value
        feat(s,1).(['Feat20',featlabel{a}])	= 100*midx/T;          	% Feature 20: minimum value location (%)
        feat(s,1).(['Feat21',featlabel{a}])	= 100*(Midx-midx)/T;  	% Feature 21: max-min time distance (%)
        
        % Interaxis correlation
        if mod(a,3) == 2 
            feat(s,1).(['Feat22',featlabel{a}([1:6,end-1,end]),'_xy'])	= corr(data_all{s,a-1},data_all{s,a});      % Feature 22: x-y Pearson correlation
            feat(s,1).(['Feat23',featlabel{a}([1:6,end-1,end]),'_xz'])	= corr(data_all{s,a-1},data_all{s,a+1});   	% Feature 23: x-z Pearson correlation
            feat(s,1).(['Feat24',featlabel{a}([1:6,end-1,end]),'_zy'])	= corr(data_all{s,a+1},data_all{s,a});      % Feature 24: z-y Pearson correlation
        end
        
        % Left-right correlation
        if s <= min(NumStepsL,NumStepsR)            
            right_int_data  = set_frame(datain_right{s,a},1,100);
            left_int_data   = set_frame(datain_left{s,a},1,100);
            feat(s,1).(['Feat25',Axesnames{a}])	= corr(right_int_data,left_int_data);	% Feature 25: left-right Pearson correlation
            if strcmp(sensorstr,'jt')   % Joint symmetry measures
                MvalueL = max(datain_left{s,a});
                mvalueL = min(datain_left{s,a});
                rangeL  = range(datain_left{s,a});
                meanL   = mean(datain_left{s,a});
                MvalueR = max(datain_right{s,a});
                mvalueR = min(datain_right{s,a});
                rangeR  = range(datain_right{s,a});
                meanR   = mean(datain_right{s,a});
                feat(s,1).(['Feat26',Axesnames{a}]) = abs(MvalueL-MvalueR)/(0.5*(MvalueL+MvalueR));	% Feature 26: difference of the maximum values
                feat(s,1).(['Feat27',Axesnames{a}]) = abs(mvalueL-mvalueR)/(0.5*(mvalueL+mvalueR));	% Feature 27: difference of the minimum values
                feat(s,1).(['Feat28',Axesnames{a}]) = abs(rangeL-rangeR)/(0.5*(rangeL+rangeR));    	% Feature 28: difference of the rom
                feat(s,1).(['Feat29',Axesnames{a}]) = abs(meanL-meanR)/(0.5*(meanL+meanR));         % Feature 29: difference of the means
                feat(s,1).(['Feat30',Axesnames{a}]) = mean(abs(left_int_data-right_int_data)./...
                    (0.5*(left_int_data+right_int_data)));     % Feature 30: mean point to point error
            end
        end
        
        % Axis Specific features
        switch a + 12*(strcmp(sensorstr,'ac')) + 24*(strcmp(sensorstr,'jt'))
            case 8  % Shank Gyroscope around y-axis
                [swpk_val,swpk_idx] = max(data(TO_idx(s):end));
                feat(s,1).(['Feat31',featlabel{a}]) = swpk_val;                     % Feature 31: maximum value during swing
                feat(s,1).(['Feat32',featlabel{a}]) = 100*swpk_idx/T;               % Feature 32: maximum value timing during swing (%)
            case 9  % Foot Gyroscope around y-axis
                [topk_val,topk_idx] = min(data(TO_idx(s)-5:TO_idx(s)+5));
                feat(s,1).(['Feat33',featlabel{a}]) = topk_val;                     % Feature 33: Toe-off Gyro value
                feat(s,1).(['Feat34',featlabel{a}]) = 100*(topk_idx+TO_idx(s)-6)/T;	% Feature 34: Toe-off Gyro timing (%)
                [fosw_val,fosw_idx] = max(data(topk_idx+TO_idx(s)-6:end));
                feat(s,1).(['Feat35',featlabel{a}]) = fosw_val;                    	% Feature 35: Max Gyro value in swing
                feat(s,1).(['Feat36',featlabel{a}]) = 100*(fosw_idx+topk_idx+TO_idx(s)-5)/T;    % Feature 36: Max Gyro value in swing timing (%)
            case 30 % Knee Flexion/Extension angle
                stanceknee 	= data(1:TO_idx(s)-1);
                feat(s,1).(['Feat37',featlabel{a}])	= max(stanceknee);              % Feature 37: maximum value during stance
                feat(s,1).(['Feat38',featlabel{a}]) = min(stanceknee);              % Feature 38: minimum value during swing
                feat(s,1).(['Feat39',featlabel{a}]) = range(stanceknee);            % Feature 39: rom during stance
                swingknee 	= data(TO_idx(s):end);
                feat(s,1).(['Feat40',featlabel{a}])	= max(swingknee);               % Feature 40: maximum value during stance
                feat(s,1).(['Feat41',featlabel{a}]) = min(swingknee);               % Feature 41: minimum value during swing
                feat(s,1).(['Feat42',featlabel{a}]) = range(swingknee);             % Feature 42: rom during swing
        end
        
        % Correlation with normative profile
        if strcmp(sensorstr,'jt') && mod(a,3) == 0 
            data_int = set_frame(data,1,100);
            feat(s,1).(['Feat43',featlabel{a}]) = corr(data_int,template(:,a/3));       % Feature 43: Pearson correlation with healthy
            feat(s,1).(['Feat44',featlabel{a}]) = sqrt(immse(data_int,template(:,a/3)));% Feature 44: RMSE with healthy
            temp_xcorr = xcorr(data_int,template(:,a/3),'normalized');
            feat(s,1).(['Feat45',featlabel{a}]) = max(temp_xcorr);                      % Feature 45: maximum of cross-correlation
            temp_dtw = dtw(rescale(data,0,1),rescale(template(:,a/3),0,1));
            feat(s,1).(['Feat46',featlabel{a}]) = temp_dtw;                             % Feature 46: Dynamic Time Wrapping distance
        end
    end   
end
feat        = struct2table(feat);
temp_feat   = table2cell(feat);
temp_feat(cellfun(@isempty,temp_feat)) = {nan};
feat_new    = cell2table(temp_feat);
feat_new.Properties.VariableNames = feat.Properties.VariableNames;
featureout = varfun(@nanmean, feat_new, 'InputVariables', @isnumeric);
return
end