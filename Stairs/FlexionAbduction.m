function ExportparametersSTAIRS = FlexionAbduction(processedData, bodyside, ExportparametersSTAIRS)
    %Calling the bodyside and climb status
    for k = 1:numel(bodyside)
        s = processedData.(bodyside{k});
        
        %loop through each bodyside, climbstatus and stride
        for i = 1:size(s.JA, 1)
            %calculating knee flexion ROM (degrees)
            if k == 1 || k == 2
                    ExportparametersSTAIRS{i, k + 24} = max(s.JA{i, ((-9 * k)+30)}) - min(s.JA{i, ((-9 * k)+30)});
            elseif k == 3 || k == 4
                    ExportparametersSTAIRS{i, k + 24} = max(s.JA{i, ((-9 * k)+48)}) - min(s.JA{i, ((-9 * k)+48)});
            end
            %calculating Hip abduction ROM (degrees)
            if k == 1 || k == 2
                    ExportparametersSTAIRS{i, k + 30} = max(s.JA{i, ((-9 * k)+27)}) - min(s.JA{i, ((-9 * k)+27)});
            elseif k == 3 || k == 4
                    ExportparametersSTAIRS{i, k + 30} = max(s.JA{i, ((-9 * k)+45)}) - min(s.JA{i, ((-9 * k)+45)});
            end
        end
    end
        %Calculating Asymmetry
        for i = 1:height(ExportparametersSTAIRS)
            if ~isnan(ExportparametersSTAIRS{i, 25}) && ~isnan(ExportparametersSTAIRS{i, 26})
                  ExportparametersSTAIRS{i, 29} = (ExportparametersSTAIRS{i, 25}-ExportparametersSTAIRS{i,26}) / (0.5 * (ExportparametersSTAIRS{i, 25}+ExportparametersSTAIRS{i,26})) * 100;
            else
                  ExportparametersSTAIRS{i, 29} = NaN; 
            end
            if ~isnan(ExportparametersSTAIRS{i, 27}) && ~isnan(ExportparametersSTAIRS{i, 28})
                  ExportparametersSTAIRS{i, 30} = (ExportparametersSTAIRS{i, 27}-ExportparametersSTAIRS{i,28}) / (0.5 * (ExportparametersSTAIRS{i, 27}+ExportparametersSTAIRS{i,28})) * 100;
            else
                  ExportparametersSTAIRS{i, 30} = NaN; 
            end
            if ~isnan(ExportparametersSTAIRS{i, 31}) && ~isnan(ExportparametersSTAIRS{i, 32})
                  ExportparametersSTAIRS{i, 35} = (ExportparametersSTAIRS{i, 31}-ExportparametersSTAIRS{i,32}) / (0.5 * (ExportparametersSTAIRS{i, 31}+ExportparametersSTAIRS{i,32})) * 100;
            else
                  ExportparametersSTAIRS{i, 35} = NaN; 
            end
            if ~isnan(ExportparametersSTAIRS{i, 33}) && ~isnan(ExportparametersSTAIRS{i, 34})
                  ExportparametersSTAIRS{i, 36} = (ExportparametersSTAIRS{i, 33}-ExportparametersSTAIRS{i,34}) / (0.5 * (ExportparametersSTAIRS{i, 33}+ExportparametersSTAIRS{i,34})) * 100;
            else
                  ExportparametersSTAIRS{i, 36} = NaN; 
            end
        end
end
        
