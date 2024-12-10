function [Exportparameters] = ToeAngles(data, bodyside, footcontact, Exportparameters)
    RightHS = footcontact{:, 6}; %Heel contact time array: Right
    RightTO = footcontact{:, 7}; %Toe contact time array: Right
    LeftHS = footcontact{:, 4}; %Heel contact time array: Left
    LeftTO = footcontact{:, 5}; %Toe contact time array: Left
    footcontacttime = footcontact{:, 2}; %Foot contact time array
    
    RightContact = (RightHS | RightTO); %Combine toe and heel contact
    LeftContact = (LeftHS | LeftTO); %Combine toe and heel contact
    
    for k = 1:numel(bodyside)   %Loop through body side
        s = data.subdata_out.Segmented.(bodyside{k});  %Select the bodyside
        if k == 1  
            HSTime = round(s.LHS_tim * 1000); %Convert to millisecond
        elseif k == 2
            HSTime = round(s.RHS_tim * 1000); %Convert to millisecond
        end
        for i = 1:length(HSTime) %Loop through each stride
            %Extract start and end index
            [~, idx_start] = min(abs(footcontacttime - HSTime(i, 1))); 
            [~, idx_end] = min(abs(footcontacttime - HSTime(i, 2)));
            
            %Trim the stride from footcontacttime
            if k == 1
                trimmedstride = LeftContact(idx_start:idx_end);
            elseif k == 2
                trimmedstride = RightContact(idx_start:idx_end);
            end
            
            %Correct the stride with 0 and 1
            first_one = find(trimmedstride == 1, 1, 'first');
            if ~isempty (first_one) && first_one > 1
                trimmedstride(1:first_one-1) = 1;
            end
            last_zero = find(trimmedstride ==0, 1, 'last');
            if ~isempty(last_zero) && last_zero < length(trimmedstride)
                trimmedstride(last_zero+1:end) = 0;
            end
            
            idx_change = find(diff(trimmedstride) == -1) + idx_start;
            if isempty(idx_change)
                idx_change = 0;
                Exportparameters{i, k+33} = 0;
                Exportparameters{i, k+27} = 0;
                Exportparameters{i, k+30} = 0;
            else
                idx_change = idx_change(end);
                idx_end = idx_end - idx_start;
                idx_change = idx_change - idx_start;
                idx_start = 1;
                %Heel Strike
                Exportparameters{i, k+33} = s.Q_seg{i, (-9*k + 29)}(idx_start);
                %Toe Off 
                Exportparameters{i, k+27} = s.Q_seg{i, (-9*k + 29)}(idx_change);
                %Toe Out
                Exportparameters{i, k+30} = mean(s.Q_seg{i, (-9*k + 30)}(idx_start:idx_change));
            end
        end
    end
    for i = 1:height(Exportparameters)
        if ~isnan(Exportparameters{i, 28}) && ~isnan(Exportparameters{i, 29})
            Exportparameters{i, 30} = (Exportparameters{i, 28}-Exportparameters{i,29}) / (0.5 * (Exportparameters{i, 28}+Exportparameters{i,29})) * 100;
        else
            Exportparameters{i, 30} = NaN;
        end
        if ~isnan(Exportparameters{i, 31}) && ~isnan(Exportparameters{i, 32})
            Exportparameters{i, 33} = (Exportparameters{i, 31}-Exportparameters{i,32}) / (0.5 * (Exportparameters{i, 31}+Exportparameters{i,32})) * 100;
        else
            Exportparameters{i, 33} = NaN;
        end
        if ~isnan(Exportparameters{i, 34}) && ~isnan(Exportparameters{i, 35})
            Exportparameters{i, 36} = (Exportparameters{i, 34}-Exportparameters{i,35}) / (0.5 * (Exportparameters{i, 34}+Exportparameters{i,35})) * 100;
        else
            Exportparameters{i, 36} = NaN;
        end
    end
end

            