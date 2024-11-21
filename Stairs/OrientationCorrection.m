function data = OrientationCorrection(data, columnIndices, minProminence, prominenceWindow)
    % Parameters:
    % data: the structure containing xsens_ord.Q matrix
    % columnIndices: Array of orientation column indices to process
    % minProminence: Minimum prominence for local extrema detection
    % prominenceWindow: Prominence window size for local extrema detection

    for x = columnIndices
        y = diff(data.xsens_ord.Q(:, x));
        maxIndices = find(islocalmax(y, 'MinProminence', minProminence, 'ProminenceWindow', prominenceWindow)); 
        minIndices = find(islocalmin(y, 'MinProminence', minProminence, 'ProminenceWindow', prominenceWindow));

        maxIndices(:, 2) = 1;
        minIndices(:, 2) = 0;
        peakIndices = sortrows([minIndices; maxIndices], 1);
        
        % Check if peakIndices is empty
        if isempty(peakIndices)
            disp(['Skipping x = ', num2str(x), ' because no local extrema were found.']);
            continue; % Skip to the next x in the loop
        end

        n = size(peakIndices, 1); 
        result = data.xsens_ord.Q(:, x);

        % Process the peaks
        for i = 1:n
            rangeStart = peakIndices(i, 1) + 1;
            rangeEND = peakIndices(n, 1);
            referenceIndex = peakIndices(i, 1);
            
            if peakIndices(i, 2) == 0
                result(rangeStart:rangeEND) = result(rangeStart:rangeEND) + abs((result(referenceIndex) - result(rangeStart)));
            elseif peakIndices(i, 2) == 1
                result(rangeStart:rangeEND) = result(rangeStart:rangeEND) - abs((result(referenceIndex) - result(rangeStart)));
            end
        end
        
        % Create and display the figure only once after processing all peaks
        fig = figure;
        
        % Subplots
        subplot(4, 1, 1)
        plot(y, "Color", "black")
        
        subplot(4, 1, 2)
        plot(y, "Color", "black")
        title("Packet Loss Markers")
        hold on
        plot(maxIndices(:, 1), y(maxIndices(:, 1)), "^", "Color", "r")
        plot(minIndices(:, 1), y(minIndices(:, 1)), "v", "Color", "r")
        hold off
        
        subplot(4, 1, 3)
        plot(data.xsens_ord.Q(:, x), "Color", "b")
        title("Original Orientation")
        
        subplot(4, 1, 4)
        plot(result, "Color", "b")
        title("Final Orientation")
        
        % General title for the figure
        sgtitle(['Orientation Column', num2str(x)]);
        
        % Pause execution until the figure is closed
        uiwait(fig);

        % Update the data structure
        data.xsens_ord.Q(:, x) = result;
    end
end
