function [finalTableL, finalTableR] = findSequenceIndices(dataL, dataR, datanonsegmented, ContactL, ContactR)
    large_vector = datanonsegmented.xsens_ord.Pos(:, 1)';

    num_sequencesL = height(dataL.Pos_seg);
    num_sequencesR = height(dataR.Pos_seg);

    index_matrixL = NaN(num_sequencesL, 2);
    index_matrixR = NaN(num_sequencesR, 2);

    for i = 1:num_sequencesL
        sequenceL = dataL.Pos_seg{i, 1}; 
        first_indexL = strfind(large_vector, sequenceL'); 

        if ~isempty(first_indexL)
            first_idx = first_indexL(1);
            last_idx = first_idx + length(sequenceL)-2;
        else
            first_idx = NaN;
            last_idx = NaN;
        end
        
        index_matrixL(i, :) = [first_idx, last_idx];
    end

    for i = 1:num_sequencesR
        sequenceR = dataR.Pos_seg{i, 1}; 
        first_indexR = strfind(large_vector, sequenceR'); 

        if ~isempty(first_indexR)
            first_idx = first_indexR(1);
            last_idx = first_idx + length(sequenceR)-2;
        else
            first_idx = NaN;
            last_idx = NaN;
        end
        
        index_matrixR(i, :) = [first_idx, last_idx];
    end

    indexTableL = array2table(index_matrixL, 'VariableNames', {'GaitStartIdx', 'GaitEndIdx'});
    indexTableR = array2table(index_matrixR, 'VariableNames', {'GaitStartIdx', 'GaitEndIdx'});

    finalTableL = [ContactL, indexTableL];
    finalTableR = [ContactR, indexTableR];
    
    if ismember('GaitStartIdx', finalTableL.Properties.VariableNames)
        finalTableL{:, 3} = finalTableL{:, 3} + finalTableL{1, 5}-2;
        finalTableL{:, 4} = finalTableL{:, 4} + finalTableL{1, 5}-2;
    else
        warning('GaitStartIdx not found in finalTableL');
    end

    if ismember('GaitStartIdx', finalTableR.Properties.VariableNames)
        finalTableR{:, 3} = finalTableR{:, 3} + finalTableL{1, 5}-2;
        finalTableR{:, 4} = finalTableR{:, 4} + finalTableL{1, 5}-2;
    else
        warning('GaitStartIdx not found in finalTableR');
    end

end
