function processedData = segmentation(data, ascendingLeft, ascendingRight, descendingLeft, descendingRight)
    % Initialize the new structure with tabs and copy Labels
    processedData = struct('AscendingLeft', [], 'AscendingRight', [], ...
                           'DescendingLeft', [], 'DescendingRight', [], ...
                           'Labels', data.xsens_ord.Labels);

    % Define the step intervals for each condition
    stepIntervals.AscendingLeft = createSteps(ascendingLeft);
    stepIntervals.AscendingRight = createSteps(ascendingRight);
    stepIntervals.DescendingLeft = createSteps(descendingLeft);
    stepIntervals.DescendingRight = createSteps(descendingRight);

    % List of matrix fields to be processed
    matrixFields = {'Pos', 'JA', 'ACC', 'ACC_S', 'AV', 'V', 'Q'};

    % Process each condition tab
    conditions = {'AscendingLeft', 'AscendingRight', 'DescendingLeft', 'DescendingRight'};

    for condIdx = 1:length(conditions)
        condition = conditions{condIdx};
        steps = stepIntervals.(condition);  % Get the intervals for current condition

        % Initialize a substructure for each field in this condition
        for fieldIdx = 1:length(matrixFields)
            field = matrixFields{fieldIdx};
            originalMatrix = data.xsens_ord.(field);
            nSteps = size(steps, 1);
            nCols = size(originalMatrix, 2);
            
            % Initialize the processed matrix with cell arrays
            processedMatrix = cell(nSteps, nCols);
            
            for stepIdx = 1:nSteps
                startIdx = steps(stepIdx, 1);
                endIdx = steps(stepIdx, 2);
                
                for colIdx = 1:nCols
                    % Store the vector for this step and column
                    processedMatrix{stepIdx, colIdx} = originalMatrix(startIdx:endIdx, colIdx);
                end
            end
            
            % Store the processed matrix in the new structure
            processedData.(condition).(field) = processedMatrix;
        end
    end
end

% Helper function to create step intervals
function steps = createSteps(indices)
    nSteps = length(indices) - 1;
    steps = zeros(nSteps, 2);
    for i = 1:nSteps
        steps(i, :) = [indices(i), indices(i + 1) - 1];
    end
end
