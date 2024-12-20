function xsens_ord = AMPsegmentation(file_path, xsens_ord)

    % If xsens_ord is not provided, initialize it as an empty structure
    if nargin < 2
        xsens_ord = struct();
    end

    sheetNames = {'Segment Position', 'Segment Orientation - Euler', 'Segment Velocity', ...
                  'Segment Acceleration', 'Segment Angular Velocity', 'Joint Angles XZY', ...
                  'Center of Mass'};
    % Corresponding structure field names (valid MATLAB names)
    validSheetNames = cellfun(@matlab.lang.makeValidName, sheetNames, 'UniformOutput', false);
    
    % Preload all sheets into memory
    dataSheets = struct();
    for i = 1:numel(sheetNames)
        dataSheets.(validSheetNames{i}) = table2array(readtable(file_path, 'Sheet', sheetNames{i}));
    end
    
    % Assign frequently used variables
    JointAnkle = dataSheets.JointAnglesXZY;
    Position = dataSheets.SegmentPosition;
    
    msg = "Choose your task";
    opts = ["Single Leg Standing Right", "Single Leg Standing Left", "Rigid Eyes Open", "Rigid Eyes Close", "Close"];
    
    while true
        choice = menu(msg, opts);
        if choice == 5 % Close
            disp('Exiting...');
            break;
        end
        
        % Determine the field name for the current choice
        taskName = matlab.lang.makeValidName(opts(choice));
        
        % Plot data
        figure;
        subplot(3, 1, 1);
        plot(JointAnkle(:, 52));
        hold on;
        plot(JointAnkle(:, 64));
        title('Joint Ankle Plantar Flexion');
        hold off;
    
        subplot(3, 1, 2);
        plot(Position(:, 34));
        hold on;
        plot(Position(:, 46));
        title("Hand Position y");
        hold off;
    
        subplot(3, 1, 3);
        plot(Position(:, 54));
        hold on;
        plot(Position(:, 66));
        title('Foot Position y');
        hold off;
    
        % Get user-selected range
        x_values = zeros(1, 2);
        for i = 1:2
            [x, ~] = ginput(1);
            x_values(i) = round(x);
            for subplot_idx = 1:3
                subplot(3, 1, subplot_idx);
                hold on;
                xline(x, 'r--', 'LineWidth', 2);
            end
        end
    
        % Extract data for the selected range and add it to xsens_ord
        for i = 1:numel(sheetNames)
            sheetData = dataSheets.(validSheetNames{i});
            
            % Add or overwrite data for the current task and sheet
            xsens_ord.(taskName).(validSheetNames{i}) = sheetData(x_values(1):x_values(2), :);
        end
    
        disp(['Task "' opts(choice) '" processed and data stored.']);
    end
end