function [Exportparameters] = SSSD(data, bodyside, footcontact, Exportparameters)
    % Defining heel strike and toe off from each side 
    RightHS = footcontact{:, 6};
    RightTO = footcontact{:, 7};
    LeftHS = footcontact{:, 4};
    LeftTO = footcontact{:, 5};
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
            stridetime = (footcontacttime(idx_end) - footcontacttime(idx_start))/1000;
            
            % Calculate stance time (from idx_start to idx_change)
            stancetime = (footcontacttime(idx_change) - footcontacttime(idx_start))/1000;
            
            % Calculate swing time (from idx_change to idx_end)
            swingtime = (footcontacttime(idx_end) - footcontacttime(idx_change))/1000;
            
            % Calculate stance length (%GCT)
            Exportparameters{i, k+3} = stancetime / stridetime * 100;
            
            % Calculate swing length (%GCT)
            Exportparameters{i, k+6} = swingtime / stridetime * 100;
        end
    end
    
    % 2. After gathering the stance times for both sides, calculate terminal double support times
    for i = 1:size(leftStanceTimes, 1)
        % Extract left and right stance start and end times for the current stride
        left_start = footcontacttime(leftStanceTimes(i, 1));
        left_end = footcontacttime(leftStanceTimes(i, 2));
        right_start = footcontacttime(rightStanceTimes(i, 1));
        right_end = footcontacttime(rightStanceTimes(i, 2));
        
        % Calculate stride time (use the total time of the current stride)
        stride_start = min(left_start, right_start);
        stride_end = max(left_end, right_end);
        stridetime = stride_end - stride_start;
        
        % Identify terminal double support time for the left and right legs separately
        % - Terminal double support for the right leg happens when the right leg is
        %   ending its stance phase, and the left leg is already in stance.
        % - Similarly, terminal double support for the left leg happens at the end
        %   of its stance phase, with the right leg already in stance.

        % Calculate terminal double support for the right leg in the current stride
        if left_start < right_end  % Check if left leg has already started stance
            terminal_double_support_right = min(left_end, right_end) - right_end;
            terminal_double_support_right = max(0, terminal_double_support_right);  % Ensure non-negative
        else
            terminal_double_support_right = 0;
        end

        % Calculate terminal double support for the left leg in the current stride
        if right_start < left_end  % Check if right leg has already started stance
            terminal_double_support_left = min(left_end, right_end) - left_end;
            terminal_double_support_left = max(0, terminal_double_support_left);  % Ensure non-negative
        else
            terminal_double_support_left = 0;
        end

        % Store terminal double support times as percentages of the gait cycle time
        Exportparameters{i, 13} = (terminal_double_support_left / stridetime) * 100;  % Terminal Double Support L %GCT
        Exportparameters{i, 14} = (terminal_double_support_right / stridetime) * 100; % Terminal Double Support R %GCT
    end

    % Calculating asymmetries
    for i = 1:height(Exportparameters)
        % Stance Asymmetry
        if ~isnan(Exportparameters{i, 4}) && ~isnan(Exportparameters{i, 5})
            Exportparameters{i, 6} = (Exportparameters{i, 4}-Exportparameters{i,5}) / (0.5 * (Exportparameters{i, 4}+Exportparameters{i,5})) * 100;
        else
            Exportparameters{i, 6} = NaN; 
        end 
        % Swing Asymmetry
        if ~isnan(Exportparameters{i, 7}) && ~isnan(Exportparameters{i, 8})
            Exportparameters{i, 9} = (Exportparameters{i, 7}-Exportparameters{i,8}) / (0.5 * (Exportparameters{i, 7}+Exportparameters{i,8})) * 100;
        else
            Exportparameters{i, 9} = NaN; 
        end 
        % Single Support Asymmetry
        if ~isnan(Exportparameters{i, 10}) && ~isnan(Exportparameters{i, 11})
            Exportparameters{i, 12} = (Exportparameters{i, 10}-Exportparameters{i,11}) / (0.5 * (Exportparameters{i, 10}+Exportparameters{i,11})) * 100;
        else
            Exportparameters{i, 12} = NaN; 
        end 
        % Double Support Asymmetry
        if ~isnan(Exportparameters{i, 13}) && ~isnan(Exportparameters{i, 14})
            Exportparameters{i, 15} = (Exportparameters{i, 13}-Exportparameters{i,14}) / (0.5 * (Exportparameters{i, 13}+Exportparameters{i,14})) * 100;
        else
            Exportparameters{i, 15} = NaN; 
        end 
    end
end
