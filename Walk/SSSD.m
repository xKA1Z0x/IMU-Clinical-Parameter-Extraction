function [Exportparameters] = SSSD(data, bodyside, footcontact, Exportparameters)
    % Defining heel strike and toe off from each side 
    RightHS = footcontact{:, 6};  % Right heel strike times
    RightTO = footcontact{:, 7};  % Right toe-off times
    LeftHS = footcontact{:, 4};   % Left heel strike times
    LeftTO = footcontact{:, 5};   % Left toe-off times
    footcontacttime = footcontact{:, 2}; % Foot contact time array
    
    % Combine RightHS and RightTO, and LeftHS and LeftTO
    RightContact = (RightHS | RightTO);
    LeftContact = (LeftHS | LeftTO);
    
    % Initialize stance and swing time variables for both sides
    rightStanceTimes = [];
    leftStanceTimes = [];
    
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
            
            % Trim the stride from footcontacttime
            if k == 1
                trimmedstride = LeftContact(idx_start:idx_end);
            elseif k == 2
                trimmedstride = RightContact(idx_start:idx_end);
            end
                
            % Correct the stride with 0 and 1
            first_one = find(trimmedstride == 1, 1, 'first');
            if ~isempty(first_one) && first_one > 1
                % Set all elements before the first 1 to 1
                trimmedstride(1:first_one-1) = 1;
            end
            
            last_zero = find(trimmedstride == 0, 1, 'last');
            if ~isempty(last_zero) && last_zero < length(trimmedstride)
                % Set all elements after the last 0 to 0
                trimmedstride(last_zero+1:end) = 0;
            end
            
            % Find where 1 changes to 0 (stance to swing transition)
            idx_change = find(diff(trimmedstride) == -1) + idx_start;
            
            % Store stance start and stance-to-swing transition points
            if k == 1
                leftStanceTimes(i, :) = [idx_start, idx_change]; 
            elseif k == 2
                rightStanceTimes(i, :) = [idx_start, idx_change];
            end
            
            % Calculate stride time (from idx_start to idx_end)
            stridetime = (footcontacttime(idx_end) - footcontacttime(idx_start)) / 1000;
            
            % Calculate stance time (from idx_start to idx_change)
            stancetime = (footcontacttime(idx_change) - footcontacttime(idx_start)) / 1000;
            
            % Calculate swing time (from idx_change to idx_end)
            swingtime = (footcontacttime(idx_end) - footcontacttime(idx_change)) / 1000;
            
            % Calculate stance length (%GCT)
            Exportparameters{i, k+3} = (stancetime / stridetime) * 100;
            
            % Calculate swing length (%GCT)
            Exportparameters{i, k+6} = (swingtime / stridetime) * 100;
        end
    end
    
    % 2. After gathering the stance times for both sides, calculate single and double support times
    for i = 1:size(leftStanceTimes, 1)
        % Extract left and right stance start and end times for current stride
        left_start_idx = leftStanceTimes(i, 1);
        left_end_idx = leftStanceTimes(i, 2);
        right_start_idx = rightStanceTimes(i, 1);
        right_end_idx = rightStanceTimes(i, 2);
        
        % Calculate double support time by identifying overlapping indices
        double_support_start_idx = max(left_start_idx, right_start_idx);  % When both legs are in stance
        double_support_end_idx = min(left_end_idx, right_end_idx);        % When one leg leaves stance
        double_support_time = max(0, footcontacttime(double_support_end_idx) - footcontacttime(double_support_start_idx)) / 1000;
        
        % Calculate stride time as reference for percentages
        stride_start = min(footcontacttime(left_start_idx), footcontacttime(right_start_idx));
        stride_end = max(footcontacttime(left_end_idx), footcontacttime(right_end_idx));
        stridetime = (stride_end - stride_start) / 1000;
        
        % Calculate stance time as a percentage of gait cycle time for each leg
        left_stance_pct = Exportparameters{i, 4};  % Already calculated as (stancetime / stridetime) * 100 for left leg
        right_stance_pct = Exportparameters{i, 5}; % Already calculated as (stancetime / stridetime) * 100 for right leg
        
        % Calculate double support %GCT
        double_support_pct = (double_support_time / stridetime) * 100;
        Exportparameters{i, 13} = double_support_pct;  % Double Support L %GCT
        Exportparameters{i, 14} = double_support_pct;  % Double Support R %GCT
        
        % Calculate single support %GCT as difference between stance %GCT and double support %GCT
        left_single_support_pct = left_stance_pct - double_support_pct;
        right_single_support_pct = right_stance_pct - double_support_pct;
        
        % Store single support times as percentages of the gait cycle time
        Exportparameters{i, 10} = left_single_support_pct;  % Single Support L %GCT
        Exportparameters{i, 11} = right_single_support_pct; % Single Support R %GCT
    end
    
    % 3. Calculating asymmetries
    for i = 1:height(Exportparameters)
        % Stance Asymmetry
        if ~isnan(Exportparameters{i, 4}) && ~isnan(Exportparameters{i, 5})
            Exportparameters{i, 6} = (Exportparameters{i, 4} - Exportparameters{i, 5}) / (0.5 * (Exportparameters{i, 4} + Exportparameters{i, 5})) * 100;
        else
            Exportparameters{i, 6} = NaN; 
        end 
        
        % Swing Asymmetry
        if ~isnan(Exportparameters{i, 7}) && ~isnan(Exportparameters{i, 8})
            Exportparameters{i, 9} = (Exportparameters{i, 7} - Exportparameters{i, 8}) / (0.5 * (Exportparameters{i, 7} + Exportparameters{i, 8})) * 100;
        else
            Exportparameters{i, 9} = NaN; 
        end 
        
        % Single Support Asymmetry
        if ~isnan(Exportparameters{i, 10}) && ~isnan(Exportparameters{i, 11})
            Exportparameters{i, 12} = (Exportparameters{i, 10} - Exportparameters{i, 11}) / (0.5 * (Exportparameters{i, 10} + Exportparameters{i, 11})) * 100;
        else
            Exportparameters{i, 12} = NaN; 
        end 
        
        % Double Support Asymmetry (set to 0 since values are identical)
        Exportparameters{i, 15} = 0;
    end
end
