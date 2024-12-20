function data = OrientationCorrection(data, bodyside, columnIndices, minProminence, prominenceWindow)
    % Parameters:
    % data: the structure containing xsens_ord.Q matrix
    % columnIndices: Array of orientation column indices to process
    % minProminence: Minimum prominence for local extrema detection
    % prominenceWindow: Prominence window size for local extrema detection

    for bs = 1:2
        for x = columnIndices
            % Extract the column of cells
            cellArray = data.segmented.new_seg.Segmented.(bodyside{bs}).Q_seg(:, x);
            
            % Loop through each cell in the column
            for cellIndex = 1:length(cellArray)
                % Extract the numeric array from the current cell
                numericArray = cellArray{cellIndex};
                
                % Compute the difference for the numeric array
                y = diff(numericArray);
                
                % Find local maxima and minima indices
                maxIndices = find(islocalmax(y, 'MinProminence', minProminence, 'ProminenceWindow', prominenceWindow)); 
                minIndices = find(islocalmin(y, 'MinProminence', minProminence, 'ProminenceWindow', prominenceWindow));

                % Mark maxima and minima
                maxIndices(:, 2) = 1;
                minIndices(:, 2) = 0;
                peakIndices = sortrows([minIndices; maxIndices], 1);
                
                % Check if peakIndices is empty
                if isempty(peakIndices)
                    disp(['Skipping cell ', num2str(cellIndex), ' in column ', num2str(x), ' because no local extrema were found.']);
                    continue; % Skip to the next cell in the loop
                end

                % Initialize result array
                n = size(peakIndices, 1);
                result = numericArray;

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
                
                % Plot the results
                fig = figure;

                subplot(4, 1, 1)
                plot(y, "Color", "black")
                title("Difference Array")

                subplot(4, 1, 2)
                plot(y, "Color", "black")
                title("Packet Loss Markers")
                hold on
                plot(maxIndices(:, 1), y(maxIndices(:, 1)), "^", "Color", "r")
                plot(minIndices(:, 1), y(minIndices(:, 1)), "v", "Color", "r")
                hold off

                subplot(4, 1, 3)
                plot(numericArray, "Color", "b")
                title("Original Array")

                subplot(4, 1, 4)
                plot(result, "Color", "b")
                title("Final Corrected Array")

                sgtitle(['Body Side: ', bodyside{bs}, ', Column ', num2str(x), ', Cell ', num2str(cellIndex)]);

                % Pause execution until the figure is closed
                uiwait(fig);

                % Update the original numeric array in the cell
                cellArray{cellIndex} = result;
            end
            
            % Update the data structure with the modified cell array
            data.segmented.new_seg.Segmented.(bodyside{bs}).Q_seg(:, x) = cellArray;
        end
    end
end
