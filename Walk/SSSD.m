function [Exportparameters] = SSSD(Exportparameters, finalTableL, finalTableR)

    for i = 1:height(finalTableL)
        stance1 = (finalTableL{i, 4} - finalTableL{i, 3}) / (finalTableL{i, 6} - finalTableL{i, 5}) * 100;
        swing1 = 100 - stance1;
        if stance1 <= 0
            Exportparameters{i, 4} = 0;
            Exportparameters{i, 7} = 0;
        else
            Exportparameters{i, 4} = stance1;
            Exportparameters{i, 7} = swing1;
        end
    end

    for i = 1:height(finalTableR)
        stance2 = (finalTableR{i, 4} - finalTableR{i, 3}) / (finalTableR{i, 6} - finalTableR{i, 5}) * 100;
        swing2 = 100 - stance2;
        if stance2 <= 0
            Exportparameters{i, 5} = 0;
            Exportparameters{i, 8} = 0;
        else
            Exportparameters{i, 5} = stance2;
            Exportparameters{i, 8} = swing2;
        end
    end

    for i = 1:min(height(finalTableL), height(finalTableR))
        strideStartL = finalTableL{i, 5};
        heelStrikeL = finalTableL{i, 3};
        toeOffL = finalTableL{i, 4};
        strideEndL = finalTableL{i, 6};

        strideStartR = finalTableR{i, 5};
        heelStrikeR = finalTableR{i, 3};
        toeOffR = finalTableR{i, 4};
        strideEndR = finalTableR{i, 6};
        
        if strideStartL<strideStartR
            correct_sequence = [heelStrikeL, heelStrikeR, toeOffL, toeOffR];
            if issorted(correct_sequence)
                
                single_support_L = (heelStrikeR - HeelStrideL) / (strideEndL - strideStartL) * 100; % Between 3R and 3L
                single_support_R = (toeOffR - toeOffL) / (strideEndR - strideStartR) * 100; % Between 4R and 4L
                double_support_L = (toeOffL - heelStrikeR) / (strideEndL - strideStartL) * 100; % Between 3L and 4R
                double_support_R = (toeOffL - heelStrikeR) / (strideEndR - strideStartR) * 100; % Between 3R and 4L
            else
                single_support_L = 0;
                single_support_R = 0;
                double_support_L = 0;
                double_support_R = 0;
            end
        else
            correct_sequence = [heelStrikeR, heelStrikeL, toeOffR, toeOffL];
            if issorted(correct_sequence)
                single_support_L = (toeOffL - toeOffR) / (strideEndL - strideStartL) * 100; % Between 3R and 3L
                single_support_R = (heelStrikeL - heelStrikeR) / (strideEndR - strideStartR) * 100; % Between 4R and 4L
                double_support_L = (toeOffR - heelStrikeL) / (strideEndL - strideStartL) * 100; % Between 3L and 4R
                double_support_R = (toeOffR - heelStrikeL) / (strideEndR - strideStartR) * 100; % Between 3R and 4L
            else
                single_support_L = 0;
                single_support_R = 0;
                double_support_L = 0;
                double_support_R = 0;
            end
        end
        Exportparameters{i, 10} = single_support_L;
        Exportparameters{i, 11} = single_support_R;
        Exportparameters{i, 13} = double_support_L;
        Exportparameters{i, 14} = double_support_R;
    end
    for i = 1: height(Exportparameters)
            if ~isnan(Exportparameters{i, 4}) && ~isnan(Exportparameters{i, 5})
                Exportparameters{i, 6} = (Exportparameters{i, 4} - Exportparameters{i, 5}) / (0.5 * (Exportparameters{i, 4} + Exportparameters{i, 5})) * 100;
            else
                Exportparameters{i, 6} = NaN; 
            end 

            if ~isnan(Exportparameters{i, 7}) && ~isnan(Exportparameters{i, 8})
                Exportparameters{i, 9} = (Exportparameters{i, 7} - Exportparameters{i, 8}) / (0.5 * (Exportparameters{i, 7} + Exportparameters{i, 8})) * 100;
            else
                Exportparameters{i, 9} = NaN; 
            end 

            if ~isnan(Exportparameters{i, 10}) && ~isnan(Exportparameters{i, 11})
                Exportparameters{i, 12} = (Exportparameters{i, 10} - Exportparameters{i, 11}) / (0.5 * (Exportparameters{i, 10} + Exportparameters{i, 11})) * 100;
            else
                Exportparameters{i, 12} = NaN; 
            end 

            if ~isnan(Exportparameters{i , 13}) && ~isnan(Exportparameters{i, 14})
                Exportparameters{i, 15} = (Exportparameters{i, 13} - Exportparameters{i, 14}) / (0.5 * (Exportparameters{i , 13} + Exportparameters{i, 14})) * 100;
            else
                Exportparameters{i, 15} = NaN;
            end
    end
end

        
        

    
    