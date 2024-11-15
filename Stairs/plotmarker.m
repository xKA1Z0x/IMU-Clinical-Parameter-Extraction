function [ascendingLeft, descendingLeft, ascendingRight, descendingRight] = plotmarker(data)
    % Initialize variables for storing peaks
    ascendingLeft = [];
    descendingLeft = [];
    ascendingRight = [];
    descendingRight = [];
    
    % List of actions and titles for sequential plotting
    actions = {'Ascending Left', 'Descending Left', 'Ascending Right', 'Descending Right'};
    peaksData = {ascendingLeft, descendingLeft, ascendingRight, descendingRight};
    yDataIndex = [21, 21, 12, 12];  % Columns for left/right knee angles in JA
    posDataIndex = [9, 9, 6, 6];     % Columns for left/right foot positions in Pos
    
    % Loop through each action
    for i = 1:4
        % Create a new figure for each action
        mainFig = figure('Name', ['Select Peaks for ', actions{i}], 'Position', [100, 100, 800, 600]);

        % Plot the knee joint angle for the current action in subplot 1
        ax1 = subplot(2, 1, 1);  % Get axis handle for subplot 1
        plot(ax1, data.xsens_ord.JA(:, 21), 'r');  % Left knee joint angle
        hold(ax1, 'on');
        plot(ax1, data.xsens_ord.JA(:, 12), 'b');  % Right knee joint angle
        hold(ax1, 'off');
        title(ax1, 'Knee Joint Angle');
        legend(ax1, 'Left Knee Angle', 'Right Knee Angle', 'Location', 'bestoutside', 'Orientation', 'horizontal');
        grid(ax1, 'on');
        set(ax1, 'YGrid', 'off', 'XGrid', 'on');
        
        % Lock x- and y-axis limits for the knee joint angle plot
        xlim(ax1, [1, length(data.xsens_ord.JA(:, 21))]);
        yRangeJA = [min([data.xsens_ord.JA(:, 21); data.xsens_ord.JA(:, 12)]) - 5, ...
                    max([data.xsens_ord.JA(:, 21); data.xsens_ord.JA(:, 12)]) + 5];
        ylim(ax1, yRangeJA);

        % Plot the foot position for the current action in subplot 2
        ax2 = subplot(2, 1, 2);  % Get axis handle for subplot 2
        plot(ax2, data.xsens_ord.Pos(:, 9), 'r');  % Left foot position
        hold(ax2, 'on');
        plot(ax2, data.xsens_ord.Pos(:, 6), 'b');  % Right foot position

        % Calculate y-range of LeftPosition and RightPosition for normalization
        yMin = min([data.xsens_ord.Pos(:, 9); data.xsens_ord.Pos(:, 6)]);
        yMax = max([data.xsens_ord.Pos(:, 9); data.xsens_ord.Pos(:, 6)]);
        trunkData = data.xsens_ord.Q(:, 6);
        trunkMin = min(trunkData);
        trunkMax = max(trunkData);

        % Normalize trunk orientation data and add it to the plot
        normalizedTrunkData = (trunkData - trunkMin) / (trunkMax - trunkMin) * (yMax - yMin) + yMin;
        plot(ax2, normalizedTrunkData, 'k');  % Trunk orientation
        hold(ax2, 'off');
        title(ax2, 'Reference');
        legend(ax2, 'Left Foot Position Z', 'Right Foot Position Z', 'Trunk Orientation Z', 'Location', 'bestoutside', 'Orientation', 'horizontal');
        grid(ax2, 'on');
        set(ax2, 'YGrid', 'off', 'XGrid', 'on');
        
        % Set x-axis and calculated y-axis limits for subplot 2
        xlim(ax2, [1, length(data.xsens_ord.Pos(:, 9))]);
        yRangePos = [yMin - 0.25, yMax + 0.25];  % Add padding to y-axis limits
        ylim(ax2, yRangePos);  % Apply calculated y-limits

        % Link x-axes of the two subplots
        linkaxes([ax1, ax2], 'x');

        % Add instructions
        annotation('textbox', [0.15, 0.95, 0.7, 0.05], 'String', ...
            ['Select peaks for ' actions{i} ' (press Enter to finish)'], ...
            'HorizontalAlignment', 'center', 'FontSize', 12, 'FontWeight', 'bold', ...
            'EdgeColor', 'none');

        % Initialize peak storage
        peaksData{i} = [];

        % Loop to select points
        while true
            % Wait for a click on the plot or press Enter to stop
            [clickX, ~, button] = ginput(1);
            
            % If Enter is pressed, exit the loop
            if isempty(button)
                break;
            end
            
            % Find the closest data point index
            [~, dataIndex] = min(abs(round(clickX) - (1:length(data.xsens_ord.JA(:, yDataIndex(i))))));
            
            % Adjust to the nearest peak within a ±10 range
            range = max(1, dataIndex - 10):min(length(data.xsens_ord.JA(:, yDataIndex(i))), dataIndex + 10);
            yData = data.xsens_ord.JA(:, yDataIndex(i));
            [~, peakIndex] = max(yData(range));
            peakX = range(peakIndex);
            
            % Store the peak location
            peaksData{i} = [peaksData{i}, peakX];
            
            % Plot the selected point on the figure
            hold(ax1, 'on');
            plot(ax1, peakX, yData(peakX), 'ko', 'MarkerSize', 6, 'MarkerFaceColor', 'none', 'HandleVisibility', 'off');
            hold(ax1, 'off');
        end
        
        % Close the figure after selection is done
        close(mainFig);
    end

    % Assign peaks data to output variables
    ascendingLeft = peaksData{1};
    descendingLeft = peaksData{2};
    ascendingRight = peaksData{3};
    descendingRight = peaksData{4};
end
