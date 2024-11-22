function featureout = automationfeatures_sensor_allrec_v3(pelvis_data,alldata_as,alldata_us,sensorstr,dt,Hz)
% This function compute features using all the recording of the signal
if strcmp(sensorstr,'ac') | strcmp(sensorstr,'av')
    Axesnames 	= strcat({'Pe_x','Pe_y','Pe_z','Pe_n','Th_x','Th_y','Th_z','Th_n',...
        'Sh_x','Sh_y','Sh_z','Sh_n','Fo_x','Fo_y','Fo_z','Fo_n'},['_' sensorstr]);
else
    Axesnames 	= strcat({'H_x','H_y','H_z','K_x','K_y','K_z','T_x','T_y','T_z'},['_' sensorstr]);
end
Sidename    = {'_P_','_A_','_U_'};

% Pelvis features
if ~isempty(pelvis_data)
    featlabel = strcat(Sidename{1},Axesnames);
    for a = 1 : size(pelvis_data,2)
        data	= pelvis_data(:,a);
        T       = length(data);     % Number of samples - iteration
        % Traditional features
        if strcmp(sensorstr,'av')
            feat_all.(['Feat01',featlabel{a}])	= sum(abs(data))*dt/T;% Feature 01: amount of motion
        end
        feat_all.(['Feat02',featlabel{a}])	= mean(data);     	% Feature 02: mean
        feat_all.(['Feat03',featlabel{a}])	= range(data);    	% Feature 03: range of values
        feat_all.(['Feat04',featlabel{a}])	= rms(data);      	% Feature 04: root mean squared value
        feat_all.(['Feat05',featlabel{a}])	= std(data);       	% Feature 05: std
        feat_all.(['Feat06',featlabel{a}])	= median(data);  	% Feature 06: median
        feat_all.(['Feat07',featlabel{a}])	= iqr(data);       	% Feature 07: inter-quartile range
        feat_all.(['Feat08',featlabel{a}])	= skewness(data); 	% Feature 08: skewness
        feat_all.(['Feat09',featlabel{a}])	= kurtosis(data);	% Feature 09: kurtosis
        feat_all.(['Feat10',featlabel{a}])	= sampen(data,1,.2,'chebychev'); 	% Feature 10: sample entropy
        
        % Frequency domains features
        ffdata	= FFeatures(data,Hz);
        feat_all.(['Feat11',featlabel{a}])	= ffdata(1);	% Feature 11: Dominant power magnitude
        feat_all.(['Feat12',featlabel{a}])	= ffdata(2);  	% Feature 12: dominant frequency
        feat_all.(['Feat13',featlabel{a}])	= ffdata(3); 	% Feature 13: mean of PSD
        feat_all.(['Feat14',featlabel{a}])	= ffdata(4); 	% Feature 14: std of PSD
        feat_all.(['Feat15',featlabel{a}])	= ffdata(5); 	% Feature 15: skewness of PSD
        feat_all.(['Feat16',featlabel{a}])	= ffdata(6);  	% Feature 16: kurtosis of PSD
        
        % Maximum and minimum values and locations
        [Mvalue,Midx]  = max(data);
        feat_all.(['Feat17',featlabel{a}])	= Mvalue;               % Feature 17: maximum value
        feat_all.(['Feat18',featlabel{a}])	= 100*Midx/T;        	% Feature 18: maximum value location (%)
        [mvalue,midx]  = min(data);
        feat_all.(['Feat19',featlabel{a}])  = mvalue;               % Feature 19: minimum value
        feat_all.(['Feat20',featlabel{a}])	= 100*midx/T;         	% Feature 20: minimum value location (%)
        feat_all.(['Feat21',featlabel{a}])	= 100*(Midx-midx)/T;	% Feature 21: max-min time distance (%)
        
        % Interaxis correlation
        if (mod(a,4) == 2 && contains(sensorstr,'a')) || (mod(a,3) == 2 && strcmp(sensorstr,'jt'))
            feat_all.(['Feat22',featlabel{a}([1:6,end-1,end]),'_xy'])	= corr(alldata_as(:,a-1),alldata_as(:,a));  	% Feature 22: x-y Pearson correlation
            feat_all.(['Feat23',featlabel{a}([1:6,end-1,end]),'_xz'])	= corr(alldata_as(:,a-1),alldata_as(:,a+1));	% Feature 23: x-z Pearson correlation
            feat_all.(['Feat24',featlabel{a}([1:6,end-1,end]),'_zy'])	= corr(alldata_as(:,a+1),alldata_as(:,a));      % Feature 24: z-y Pearson correlation
        end
    end
end

% Paretic side features
if strcmp(sensorstr,'jt')
    featlabel = strcat(Sidename{2},Axesnames);
else
    % Skip the pelvis
    featlabel = strcat(Sidename{2},Axesnames(5:end));
end
for a = 1 : size(alldata_as,2)
    data	= alldata_as(:,a);
    T       = length(data);     % Number of samples - iteration
    % Traditional features
    if strcmp(sensorstr,'av')
        feat_all.(['Feat01',featlabel{a}])	= sum(abs(data))*dt/T;% Feature 01: amount of motion
    end
    feat_all.(['Feat02',featlabel{a}])	= mean(data);     	% Feature 02: mean
    feat_all.(['Feat03',featlabel{a}])	= range(data);    	% Feature 03: range of values
    feat_all.(['Feat04',featlabel{a}])	= rms(data);      	% Feature 04: root mean squared value
    feat_all.(['Feat05',featlabel{a}])	= std(data);       	% Feature 05: std
    feat_all.(['Feat06',featlabel{a}])	= median(data);  	% Feature 06: median
    feat_all.(['Feat07',featlabel{a}])	= iqr(data);       	% Feature 07: inter-quartile range
    feat_all.(['Feat08',featlabel{a}])	= skewness(data); 	% Feature 08: skewness
    feat_all.(['Feat09',featlabel{a}])	= kurtosis(data);	% Feature 09: kurtosis
    feat_all.(['Feat10',featlabel{a}])	= sampen(data,1,.2,'chebychev'); 	% Feature 10: sample entropy
    
    % Frequency domains features
    ffdata	= FFeatures(data,Hz);
    feat_all.(['Feat11',featlabel{a}])	= ffdata(1);	% Feature 11: Dominant power magnitude
    feat_all.(['Feat12',featlabel{a}])	= ffdata(2);  	% Feature 12: dominant frequency
    feat_all.(['Feat13',featlabel{a}])	= ffdata(3); 	% Feature 13: mean of PSD
    feat_all.(['Feat14',featlabel{a}])	= ffdata(4); 	% Feature 14: std of PSD
    feat_all.(['Feat15',featlabel{a}])	= ffdata(5); 	% Feature 15: skewness of PSD
    feat_all.(['Feat16',featlabel{a}])	= ffdata(6);  	% Feature 16: kurtosis of PSD
    
    % Maximum and minimum values and locations
    [Mvalue,Midx]  = max(data);
    feat_all.(['Feat17',featlabel{a}])	= Mvalue;               % Feature 17: maximum value
    feat_all.(['Feat18',featlabel{a}])	= 100*Midx/T;        	% Feature 18: maximum value location (%)
    [mvalue,midx]  = min(data);
    feat_all.(['Feat19',featlabel{a}])  = mvalue;               % Feature 19: minimum value
    feat_all.(['Feat20',featlabel{a}])	= 100*midx/T;         	% Feature 20: minimum value location (%)
    feat_all.(['Feat21',featlabel{a}])	= 100*(Midx-midx)/T;	% Feature 21: max-min time distance (%)
    
    % Interaxis correlation
    if (mod(a,4) == 2 && contains(sensorstr,'a')) || (mod(a,3) == 2 && strcmp(sensorstr,'jt'))
        feat_all.(['Feat22',featlabel{a}([1:6,end-1,end]),'_xy'])	= corr(alldata_as(:,a-1),alldata_as(:,a));  	% Feature 22: x-y Pearson correlation
        feat_all.(['Feat23',featlabel{a}([1:6,end-1,end]),'_xz'])	= corr(alldata_as(:,a-1),alldata_as(:,a+1));	% Feature 23: x-z Pearson correlation
        feat_all.(['Feat24',featlabel{a}([1:6,end-1,end]),'_zy'])	= corr(alldata_as(:,a+1),alldata_as(:,a));      % Feature 24: z-y Pearson correlation
    end
end

% Not-Paretic side features
if strcmp(sensorstr,'jt')
    featlabel = strcat(Sidename{3},Axesnames);
else
    % Skip the pelvis
    featlabel = strcat(Sidename{3},Axesnames(5:end));
end
for a = 1 : size(alldata_us,2)
    data	= alldata_us(:,a);
    T       = length(data);     % Number of samples - iteration
    % Traditional features
    if strcmp(sensorstr,'av')
        feat_all.(['Feat01',featlabel{a}])	= sum(abs(data))*dt/T;% Feature 01: amount of motion
    end
    feat_all.(['Feat02',featlabel{a}])	= mean(data);     	% Feature 02: mean
    feat_all.(['Feat03',featlabel{a}])	= range(data);    	% Feature 03: range of values
    feat_all.(['Feat04',featlabel{a}])	= rms(data);      	% Feature 04: root mean squared value
    feat_all.(['Feat05',featlabel{a}])	= std(data);       	% Feature 05: std
    feat_all.(['Feat06',featlabel{a}])	= median(data);  	% Feature 06: median
    feat_all.(['Feat07',featlabel{a}])	= iqr(data);       	% Feature 07: inter-quartile range
    feat_all.(['Feat08',featlabel{a}])	= skewness(data); 	% Feature 08: skewness
    feat_all.(['Feat09',featlabel{a}])	= kurtosis(data);	% Feature 09: kurtosis
    feat_all.(['Feat10',featlabel{a}])	= sampen(data,1,.2,'chebychev'); 	% Feature 10: sample entropy
    
    % Frequency domains features
    ffdata	= FFeatures(data,Hz);
    feat_all.(['Feat11',featlabel{a}])	= ffdata(1);	% Feature 11: Dominant power magnitude
    feat_all.(['Feat12',featlabel{a}])	= ffdata(2);  	% Feature 12: dominant frequency
    feat_all.(['Feat13',featlabel{a}])	= ffdata(3); 	% Feature 13: mean of PSD
    feat_all.(['Feat14',featlabel{a}])	= ffdata(4); 	% Feature 14: std of PSD
    feat_all.(['Feat15',featlabel{a}])	= ffdata(5); 	% Feature 15: skewness of PSD
    feat_all.(['Feat16',featlabel{a}])	= ffdata(6);  	% Feature 16: kurtosis of PSD
    
    % Maximum and minimum values and locations
    [Mvalue,Midx]  = max(data);
    feat_all.(['Feat17',featlabel{a}])	= Mvalue;               % Feature 17: maximum value
    feat_all.(['Feat18',featlabel{a}])	= 100*Midx/T;        	% Feature 18: maximum value location (%)
    [mvalue,midx]  = min(data);
    feat_all.(['Feat19',featlabel{a}]) 	= mvalue;            	% Feature 19: minimum value
    feat_all.(['Feat20',featlabel{a}])	= 100*midx/T;         	% Feature 20: minimum value location (%)
    feat_all.(['Feat21',featlabel{a}])	= 100*(Midx-midx)/T;	% Feature 21: max-min time distance (%)
    
    % Interaxis correlation
    if (mod(a,4) == 2 && contains(sensorstr,'a')) || (mod(a,3) == 2 && strcmp(sensorstr,'jt'))
        feat_all.(['Feat22',featlabel{a}([1:6,end-1,end]),'_xy'])	= corr(alldata_us(:,a-1),alldata_us(:,a));  	% Feature 22: x-y Pearson correlation
        feat_all.(['Feat23',featlabel{a}([1:6,end-1,end]),'_xz'])	= corr(alldata_us(:,a-1),alldata_us(:,a+1));	% Feature 23: x-z Pearson correlation
        feat_all.(['Feat24',featlabel{a}([1:6,end-1,end]),'_zy'])	= corr(alldata_us(:,a+1),alldata_us(:,a));      % Feature 24: z-y Pearson correlation
    end
end

% Inter-side features
for a = 1 : size(alldata_as,2)
    as_int_data	= set_frame(alldata_as(:,a),1,1000);
    us_int_data	= set_frame(alldata_us(:,a),1,1000);
    as_int_data	= set_frame(alldata_as(:,a),1,1000);
    feat_all.(['Feat25_C_',Axesnames{a}])	= corr(as_int_data,us_int_data);	% Feature 25: US-AS Pearson correlation
    if strcmp(sensorstr,'jt')   % Joint symmetry measures
        MvalueA = max(alldata_as(:,a));
        mvalueA = min(alldata_as(:,a));
        rangeA  = range(alldata_as(:,a));
        meanA   = mean(alldata_as(:,a));
        MvalueU = max(alldata_us(:,a));
        mvalueU = min(alldata_us(:,a));
        rangeU  = range(alldata_us(:,a));
        meanU   = mean(alldata_us(:,a));
        feat_all.(['Feat26_C_',Axesnames{a}]) = abs(MvalueA-MvalueU)/(0.5*(MvalueA+MvalueU));	% Feature 26: difference of the maximum values
        feat_all.(['Feat27_C_',Axesnames{a}]) = abs(mvalueA-mvalueU)/(0.5*(mvalueA+mvalueU));	% Feature 27: difference of the minimum values
        feat_all.(['Feat28_C_',Axesnames{a}]) = abs(rangeA-rangeU)/(0.5*(rangeA+rangeU));    	% Feature 28: difference of the rom
        feat_all.(['Feat29_C_',Axesnames{a}]) = abs(meanA-meanU)/(0.5*(meanA+meanU));          % Feature 29: difference of the means
        feat_all.(['Feat30_C_',Axesnames{a}]) = mean(abs(as_int_data-us_int_data)./...
            (0.5*(as_int_data+us_int_data)));     % Feature 30: mean point to point error
    end
end

try
    feat        = struct2table(feat);
    temp_feat   = table2cell(feat);
    temp_feat(cellfun(@isempty,temp_feat)) = {nan};
    feat_new    = cell2table(temp_feat);
    feat_new.Properties.VariableNames = feat.Properties.VariableNames;
    featureout = [struct2table(feat_all),  varfun(@nanmean, feat_new, 'InputVariables', @isnumeric)];
catch
    featureout = struct2table(feat_all);
end
return
end