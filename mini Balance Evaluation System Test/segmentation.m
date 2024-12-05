function xsens_ord = segmentation(file_path, xsens_ord, k)
    % Read specific sheets for visualization
    JointAnkle = table2array(readtable(file_path, 'Sheet', 'Joint Angles XZY'));
    Position = table2array(readtable(file_path, 'Sheet', 'Segment Position'));
    
    % Original sheet names in the Excel file
    sheetNames = {'Segment Position', 'Segment Orientation - Euler', 'Segment Velocity', ...
                  'Segment Acceleration', 'Segment Angular Velocity', 'Joint Angles XZY', ...
                  'Center of Mass'};
    
    % Corresponding structure field names (valid MATLAB names)
    validSheetNames = cellfun(@matlab.lang.makeValidName, sheetNames, 'UniformOutput', false);

    % Structure names
    structnames = {'Toe', 'SingleLeftLeg', 'SingleRightLeg', 'REO', 'FEC', 'Incline'};

    % Visualization for selecting points
    figure;

    % Joint Ankle Subplot
    subplot(3, 1, 1);
    plot(JointAnkle(:, 52));
    hold on;
    plot(JointAnkle(:, 64));
    title('Joint Ankle Plantar Flexion');
    hold off;

    % Hand Position Subplot
    subplot(3, 1, 2);
    plot(Position(:, 34));
    hold on;
    plot(Position(:, 46));
    title('Hand Position y');
    hold off;

    % Foot Position Subplot
    subplot(3, 1, 3);
    plot(Position(:, 54));
    hold on;
    plot(Position(:, 66));
    title('Foot Position y');
    hold off;

    % Collect six points using ginput
    selected_x_values = zeros(1, 6);
    for i = 1:6
        [x, ~] = ginput(1); % Get user input
        selected_x_values(i) = round(x); % Round to nearest integer for indexing
        for subplot_idx = 1:3
            subplot(3, 1, subplot_idx);
            hold on;
            xline(x, 'r--', 'LineWidth', 1); % Add vertical line
        end
    end
    
    % Process each sheet and store trimmed data
    for i = 1:numel(sheetNames)
        % Read the current sheet into a matrix using the original sheet name
        o = table2array(readtable(file_path, 'Sheet', sheetNames{i}));

        % Assign trimmed data to the output structure using valid sheet name
        xsens_ord.(structnames{(3*k)-2}).(validSheetNames{i}) = o(selected_x_values(1):selected_x_values(2), :);
        xsens_ord.(structnames{(3*k)-1}).(validSheetNames{i}) = o(selected_x_values(3):selected_x_values(4), :);
        xsens_ord.(structnames{3*k}).(validSheetNames{i}) = o(selected_x_values(5):selected_x_values(6), :);
    end
end
