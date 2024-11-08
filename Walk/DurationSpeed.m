function [Exportparameters] = DurationSpeed(data, bodyside, footcontact, Exportparameters)
    % Defining heel strike and toe off from each side 
    footcontacttime = footcontact{:, 2}; % Foot contact time array
      
    % 1. First, loop through both sides (left and right) to calculate stance and swing times
    for k = 1:numel(bodyside)
        % Extract the data for the body side
        s = data.subdata_out.Segmented.(bodyside{k});
        
        % Choosing heel strike times based on the body side (milliseconds)
        if k == 1
            HSTime = round(s.LHS_tim * 1000); % Left heel strike times
        elseif k == 2
            HSTime = round(s.RHS_tim * 1000); % Right heel strike times
        end
        
        % Loop through each stride
        for i = 1:length(HSTime)
            % Find closest beginning and end of stride time in footcontacttime 
            [~, idx_start] = min(abs(footcontacttime - HSTime(i, 1)));
            [~, idx_end] = min(abs(footcontacttime - HSTime(i, 2)));
            %calculating step duration
            Exportparameters{i, k+21} = (footcontacttime(idx_end) - footcontacttime(idx_start))/1000;
            %calculating step velocity
            Exportparameters{i, k+24} = Exportparameters{i, k+18}/Exportparameters{i, k+21};
        end
    end
    %calculating step duration assymetry
    for i = 1:height(Exportparameters)
       if ~isnan(Exportparameters{i, 22}) && ~isnan(Exportparameters{i, 23})
          Exportparameters{i, 24} = (Exportparameters{i, 22}-Exportparameters{i,23}) / (0.5 * (Exportparameters{i, 22}+Exportparameters{i,23})) * 100;
       else
          Exportparameters{i, 24} = NaN; 
       end
    end 
    %calculating step velocity assymetry
    for i = 1:height(Exportparameters)
       if ~isnan(Exportparameters{i, 25}) && ~isnan(Exportparameters{i, 26})
          Exportparameters{i, 27} = (Exportparameters{i, 25}-Exportparameters{i,26}) / (0.5 * (Exportparameters{i, 25}+Exportparameters{i,26})) * 100;
       else
          Exportparameters{i, 27} = NaN; 
       end
    end  
end
