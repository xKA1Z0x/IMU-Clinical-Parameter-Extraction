function [Exportparameters] = LumbarTrunk(data, Exportparameters)
    %Extract Lumbar Orientation Signals 
    LOxRight = data.segmented.new_seg.Segmented.Rseg.Q_seg(:, 25);
    LOyRight = data.segmented.new_seg.Segmented.Rseg.Q_seg(:, 26);
    LOzRight = data.segmented.new_seg.Segmented.Rseg.Q_seg(:, 27);
    LOxLeft = data.segmented.new_seg.Segmented.Lseg.Q_seg(:, 25);
    LOyLeft = data.segmented.new_seg.Segmented.Lseg.Q_seg(:, 26);
    LOzLeft = data.segmented.new_seg.Segmented.Lseg.Q_seg(:, 27);
    %Extract Trunk Orientation Signals
    TOxRight = data.segmented.new_seg.Segmented.Rseg.Q_seg(:, 31);
    TOyRight = data.segmented.new_seg.Segmented.Rseg.Q_seg(:, 32);
    TOzRight = data.segmented.new_seg.Segmented.Rseg.Q_seg(:, 33);
    TOxLeft = data.segmented.new_seg.Segmented.Lseg.Q_seg(:, 31);
    TOyLeft = data.segmented.new_seg.Segmented.Lseg.Q_seg(:, 32);
    TOzLeft = data.segmented.new_seg.Segmented.Lseg.Q_seg(:, 33);
    
    %Determine the number of strides for right and left
    numRightStrides = size(data.segmented.new_seg.Segmented.Rseg.Q_seg, 1);
    numLeftStrides = size(data.segmented.new_seg.Segmented.Lseg.Q_seg, 1);
    
    %Number of full gait cycles (pairs of right and left strides)
    numFullGaits = min(numRightStrides, numLeftStrides);
    
    %Initialize Exportparameters
    for i = 1:numFullGaits
        %Calculate lumbar ROM (X, Y, Z) for both right and left strides
        lumbarROM_X = max(max(LOxRight{i}), max(LOxLeft{i})) - min(min(LOxRight{i}), min(LOxLeft{i}));
        lumbarROM_Y = max(max(LOyRight{i}), max(LOyLeft{i})) - min(min(LOyRight{i}), min(LOyLeft{i}));
        lumbarROM_Z = max(max(LOzRight{i}), max(LOzLeft{i})) - min(min(LOzRight{i}), min(LOzLeft{i}));
        
        % Calculate trunk ROM (X, Y, Z) for both right and left strides
        trunkROM_X = max(max(TOxRight{i}), max(TOxLeft{i})) - min(min(TOxRight{i}), min(TOxLeft{i}));
        trunkROM_Y = max(max(TOyRight{i}), max(TOyLeft{i})) - min(min(TOyRight{i}), min(TOyLeft{i}));
        trunkROM_Z = max(max(TOzRight{i}), max(TOzLeft{i})) - min(min(TOzRight{i}), min(TOzLeft{i}));

        %store the results in Exportparameters
        Exportparameters{i, 40} = lumbarROM_X;
        Exportparameters{i, 41} = lumbarROM_Y;
        Exportparameters{i, 42} = lumbarROM_Z;
        Exportparameters{i, 43} = trunkROM_X;
        Exportparameters{i, 44} = trunkROM_Y;
        Exportparameters{i, 45} = trunkROM_Z;
    end
    %Handle extra half gaits
    if numRightStrides > numLeftStrides
        for i = numFullGaits + 1:numRightStrides
            Exportparameters{i, 43:48} = NaN;
        end
    elseif numLeftStrides > numRightStrides
        for i = numFullGaits+1:numLeftStrides
            Exportparameters{i, 43:48} = NaN;
        end
    end
end

            
        
        