function [Exportparameters] = LumbarTrunk(data, Exportparameters)
    %Extract Lumbar Orientation Signals 
    LOxRight = data.subdata_out.Segmented.Rseg.Q_seg{:, 25};
    LOyRight = data.subdata_out.Segmented.Rseg.Q_seg{:, 26};
    LOzRight = data.subdata_out.Segmented.Rseg.Q_seg{:, 27};
    LOxLeft = data.subdata_out.Segmented.Lseg.Q_seg{:, 25};
    LOyLeft = data.subdata_out.Segmented.Lseg.Q_seg{:, 26};
    LOzLeft = data.subdata_out.Segmented.Lseg.Q_seg{:, 27};
    %Extract Trunk Orientation Signals
    TOxRight = data.subdata_out.Segmented.Rseg.Q_seg{:, 31};
    TOyRight = data.subdata_out.Segmented.Rseg.Q_seg{:, 32};
    TOzRight = data.subdata_out.Segmented.Rseg.Q_seg{:, 33};
    TOxLeft = data.subdata_out.Segmented.Lseg.Q_seg{:, 31};
    TOyLeft = data.subdata_out.Segmented.Lseg.Q_seg{:, 32};
    TOzLeft = data.subdata_out.Segmented.Lseg.Q_seg{:, 33};
    
    %Determine the number of strides for right and left
    numRightStrides = size(data.subdata_out.Segmented.Rseg.Q_seg, 1);
    numLeftStrides = size(data.subdata_out.Segmented.Lseg.Q_seg, 1);
    
    %Number of full gait cycles (pairs of right and left strides)
    numFullGaits = min(numRightStrides, numLeftStrides);
    
    %Initialize Exportparameters
    for i = 1:numFullGaits
        %Calculate lumbar ROM (X, Y, Z) for both right and left strides
        lumbarROM_X = max([LOxRight(i); LOxLeft(i)]) - min([LOxRight(i); LOxLeft(i)]);
        lumbarROM_Y = max([LOyRight(i); LOyLeft(i)]) - min([LOyRight(i); LOyLeft(i)]);
        lumbarROM_Z = max([LOzRight(i); LOzLeft(i)]) - min([LOzRight(i); LOzLeft(i)]);
        %Calculate trunk ROM (X, Y, Z) for both right and left strides
        trunkROM_X = max([TOxRight(i); TOxLeft(i)]) - min([TOxRight(i); TOxLeft(i)]);
        trunkROM_Y = max([TOyRight(i); TOyLeft(i)]) - min([TOyRight(i); TOyLeft(i)]);
        trunkROM_Z = max([TOzRight(i); TOzLeft(i)]) - min([TOzRight(i); TOzLeft(i)]);
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

            
        
        