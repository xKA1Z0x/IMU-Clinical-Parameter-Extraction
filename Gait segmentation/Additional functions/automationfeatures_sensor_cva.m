function featureout = automationfeatures_sensor_cva(datain_as,datain_us,sensorstr,template,dt,Hz,ahs,ato,uhs,uto)
if strcmp(sensorstr,'ac') | strcmp(sensorstr,'av')
    Axesnames 	= strcat({'Pe_x','Pe_y','Ph_z','Th_x','Th_y','Th_z','Sh_x','Sh_y','Sh_z','Fo_x','Fo_y','Fo_z'},['_' sensorstr]);
else
    Axesnames 	= strcat({'H_x','H_y','H_z','K_x','K_y','K_z','A_x','A_y','A_z'},['_' sensorstr]);
end
Sidename    = {'_A_','_U_'};
NumStepsA  	= size(datain_as,1);          	% Number of steps Affected side
NumStepsU 	= size(datain_us,1);         	% Number of steps Unaffected side
data_all 	= cat(1,datain_as,datain_us);	% All profiles togetehr

TO_idx      = [ato'-ahs(:,1)+1;uto'-uhs(:,1)+1];
for s = 1 : size(data_all,1)        % Stride
    for a = 1 : size(data_all,2)	% Sensor axis
        data            = data_all{s,a};  
        if s <= NumStepsA
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
        feat(s,1).(['Feat10',featlabel{a}])	= sampen(data,1,.2); 	% Feature 10: sample entropy
        
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
        feat(s,1).(['Feat18',featlabel{a}])	= Midx;                 % Feature 18: maximum value location
        [mvalue,midx]  = min(data);
        feat(s,1).(['Feat19',featlabel{a}]) = mvalue;               % Feature 19: minimum value
        feat(s,1).(['Feat20',featlabel{a}])	= midx;                 % Feature 20: minimum value location
        feat(s,1).(['Feat21',featlabel{a}])	= Midx-midx;            % Feature 21: max-min time distance
        
        % Interaxis correlation
        if mod(a,3) == 2 
            feat(s,1).(['Feat22',featlabel{a}([1:6,end-1,end]),'_xy'])	= corr(data_all{s,a-1},data_all{s,a});      % Feature 22: x-y Pearson correlation
            feat(s,1).(['Feat23',featlabel{a}([1:6,end-1,end]),'_xz'])	= corr(data_all{s,a-1},data_all{s,a+1});   	% Feature 23: x-z Pearson correlation
            feat(s,1).(['Feat24',featlabel{a}([1:6,end-1,end]),'_zy'])	= corr(data_all{s,a+1},data_all{s,a});      % Feature 24: z-y Pearson correlation
        end
        
        % AS-US correlation
        if s <= min(NumStepsA,NumStepsU)            
            as_int_data	= set_frame(datain_as{s,a},1,100);
            us_int_data	= set_frame(datain_us{s,a},1,100);
            feat(s,1).(['Feat25',Axesnames{a}])	= corr(as_int_data,us_int_data);	% Feature 25: US-AS Pearson correlation
            if strcmp(sensorstr,'jt')   % Joint symmetry measures
                MvalueA = max(datain_as{s,a});
                mvalueA = min(datain_as{s,a});
                rangeA  = range(datain_as{s,a});
                meanA   = mean(datain_as{s,a});
                MvalueU = max(datain_us{s,a});
                mvalueU = min(datain_us{s,a});
                rangeU  = range(datain_us{s,a});
                meanU   = mean(datain_us{s,a});
                feat(s,1).(['Feat39',Axesnames{a}]) = abs(MvalueA-MvalueU)/(0.5*(MvalueA+MvalueU));	% Feature 39: difference of the maximum values
                feat(s,1).(['Feat40',Axesnames{a}]) = abs(mvalueA-mvalueU)/(0.5*(mvalueA+mvalueU));	% Feature 40: difference of the minimum values
                feat(s,1).(['Feat41',Axesnames{a}]) = abs(rangeA-rangeU)/(0.5*(rangeA+rangeU));    	% Feature 41: difference of the rom
                feat(s,1).(['Feat42',Axesnames{a}]) = abs(meanA-meanU)/(0.5*(meanA+meanU));         % Feature 42: difference of the means
                feat(s,1).(['Feat43',Axesnames{a}]) = mean(abs(as_int_data-us_int_data)./...
                    (0.5*(as_int_data+us_int_data)));     % Feature 43: mean point to point error
            end
        end
        
        % Axis Specific features
        switch a + 12*(strcmp(sensorstr,'ac')) + 24*(strcmp(sensorstr,'jt'))
            case 8  % Shank Gyroscope around y-axis
                [swpk_val,swpk_idx] = max(data(TO_idx(s):end));
                feat(s,1).(['Feat26',featlabel{a}]) = swpk_val;                     % Feature 26: maximum value during swing
                feat(s,1).(['Feat27',featlabel{a}]) = swpk_idx;                     % Feature 27: maximum value timing during swing
            case 9  % Foot Gyroscope around y-axis
                startidx    = max([TO_idx(s)-5,1]);
                stopidx     = min([TO_idx(s)+5,length(data)]);
                [topk_val,topk_idx] = min(data(startidx:stopidx));
                feat(s,1).(['Feat28',featlabel{a}]) = topk_val;                     % Feature 28: Toe-off Gyro value
                feat(s,1).(['Feat29',featlabel{a}]) = topk_idx+startidx-1;          % Feature 29: Toe-off Gyro timing
                [fosw_val,fosw_idx] = max(data(topk_idx+startidx-1:end));
                feat(s,1).(['Feat30',featlabel{a}]) = fosw_val;                    	% Feature 30: Max Gyro value in swing
                feat(s,1).(['Feat31',featlabel{a}]) = fosw_idx+topk_idx+startidx;   % Feature 31: Max Gyro value in swing timing
            case 30 % Knee Flexion/Extension angle
                stanceknee 	= data(1:max([TO_idx(s)-5,1]));
                feat(s,1).(['Feat32',featlabel{a}])	= max(stanceknee);              % Feature 32: maximum value during stance
                feat(s,1).(['Feat33',featlabel{a}]) = min(stanceknee);              % Feature 33: minimum value during stance
                feat(s,1).(['Feat34',featlabel{a}]) = range(stanceknee);            % Feature 34: rom during stance
                swingknee 	= data(TO_idx(s):end);
                feat(s,1).(['Feat35',featlabel{a}])	= max(swingknee);               % Feature 35; maximum value during swing
                feat(s,1).(['Feat36',featlabel{a}]) = min(swingknee);               % Feature 36: minimum value during swing
                feat(s,1).(['Feat37',featlabel{a}]) = range(swingknee);             % Feature 37: rom during swing
        end
        
        % Correlation with normative profile
        if strcmp(sensorstr,'jt') && mod(a,3) == 0 
            data_int = set_frame(data,1,100);
            feat(s,1).(['Feat38',featlabel{a}]) = corr(data_int,template(:,a/3));   % Feature 38: correlation with healthy        
            if a == 9 %& feat(s,1).(['Feat38',featlabel{a}]) >0.8 
                figure('Name',featlabel{a})
%                 feat(s,1).(['Feat38',featlabel{a}]) =  dtw(data,template(:,a/3));
                title(featlabel{a})
                dtw((data),(template(:,a/3))),feat(s,1).(['Feat38',featlabel{a}])
                waitforbuttonpress
                close all
            end
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