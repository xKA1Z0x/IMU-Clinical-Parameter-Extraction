function ExportparametersSTAIRS = TrunkROM(processedData, ExportparametersSTAIRS)
    %Extract Trunk Orientation Signals
    TOxRightAsc = processedData.AscendingRight.Q{:, 31};
    TOyRightAsc = processedData.AscendingRight.Q{:, 32};
    TOzRightAsc = processedData.AscendingRight.Q{:, 33};
    TOxLeftAsc = processedData.AscendingLeft.Q{:, 31};
    TOyLeftAsc = processedData.AscendingLeft.Q{:, 32};
    TOzLeftAsc = processedData.AscendingLeft.Q{:, 33};
    TOxRightDsc = processedData.DescendingRight.Q{:, 31};
    TOyRightDsc = processedData.DescendingRight.Q{:, 32};
    TOzRightDsc = processedData.DescendingRight.Q{:, 33};
    TOxLeftDsc = processedData.DescendingLeft.Q{:, 31};
    TOyLeftDsc = processedData.DescendingLeft.Q{:, 32};
    TOzLeftDsc = processedData.DescendingLeft.Q{:, 33};
    
    %Determine the number of strides for right and left, ascending and
    %descending
    numRightStridesAsc = size(processedData.AscendingRight.Q, 1);
    numLeftStridesAsc = size(processedData.AscendingLeft.Q, 1);
    numRightStridesDsc = size(processedData.DescendingRight.Q, 1);
    numLeftStridesDsc = size(processedData.DescendingLeft.Q, 1);
    
    %Number of full gait cycles (pairs of right and left strides)
    numFullGaitsAsc = min(numRightStridesAsc, numLeftStridesAsc);
    numFullGaitsDsc = min(numRightStridesDsc, numLeftStridesDsc);
    
    %Ascending Trunk ROM
    for i = 1:numFullGaitsAsc
        trunkROM_X = max([TOxRightAsc(i); TOxLeftAsc(i)]) - min([TOxRightAsc(i); TOxLeftAsc(i)]);
        trunkROM_Y = max([TOyRightAsc(i); TOyLeftAsc(i)]) - min([TOyRightAsc(i); TOyLeftAsc(i)]);
        trunkROM_Z = max([TOzRightAsc(i); TOzLeftAsc(i)]) - min([TOzRightAsc(i); TOzLeftAsc(i)]);
        %store the results in ExportparametersSTAIRS
        ExportparametersSTAIRS{i, 37} = trunkROM_X;
        ExportparametersSTAIRS{i, 38} = trunkROM_Y;
        ExportparametersSTAIRS{i, 39} = trunkROM_Z;
    end
    %Handle extra half gaits
    if numRightStridesAsc > numLeftStridesAsc
        for i = numFullGaitsAsc + 1:numRightStridesAsc
            ExportparametersSTAIRS{i,37:39}  = NaN;
        end
    elseif numLeftStridesAsc > numRightStridesAsc
        for i = numFullGaitsAsc + 1:numLeftStridesAsc
            ExportparametersSTAIRS{i, 37:39} = NaN;
        end
    end
    for i = 1:numFullGaitsDsc
        trunkROM_X = max([TOxRightDsc(i); TOxLeftDsc(i)]) - min([TOxRightDsc(i); TOxLeftDsc(i)]);
        trunkROM_Y = max([TOyRightDsc(i); TOyLeftDsc(i)]) - min([TOyRightDsc(i); TOyLeftDsc(i)]);
        trunkROM_Z = max([TOzRightDsc(i); TOzLeftDsc(i)]) - min([TOzRightDsc(i); TOzLeftDsc(i)]);
        %store the results in ExportparametersSTAIRS
        ExportparametersSTAIRS{i, 40} = trunkROM_X;
        ExportparametersSTAIRS{i, 41} = trunkROM_Y;
        ExportparametersSTAIRS{i, 42} = trunkROM_Z;
    end
    %Handle extra half gaits
    if numRightStridesDsc > numLeftStridesDsc
        for i = numFullGaitsDsc + 1:numRightStridesDsc
            ExportparametersSTAIRS{i,40:42}  = NaN;
        end
    elseif numLeftStridesDsc > numRightStridesDsc
        for i = numFullGaitsDsc + 1:numLeftStridesDsc
            ExportparametersSTAIRS{i, 40:42} = NaN;
        end
    end
end
        