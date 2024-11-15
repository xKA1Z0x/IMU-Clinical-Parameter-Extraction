function ExportparametersSTAIRS = Elevation(processedData, bodyside, ExportparametersSTAIRS)
    %Calling the bodyside
    for k = 1:numel(bodyside)
        s = processedData.(bodyside{k});
        
        %loop through each bodyside and stride
        for i = 1:size(s.Pos, 1)
            %calculating midswing elevation
            if k == 1 || k == 2
                ExportparametersSTAIRS{i, k+18} = max(s.Pos{i, ((-3 * k)+12)})-min(s.Pos{i, ((-3 * k)+12)});
            elseif k == 3 || k == 4
                ExportparametersSTAIRS{i, k+18} = max(s.Pos{i, ((-3 * k)+18)})-min(s.Pos{i, ((-3 * k)+18)});
            end
        end
    end
        %Calculating Asymmetry
        for i = 1:height(ExportparametersSTAIRS)
            if ~isnan(ExportparametersSTAIRS{i, 19}) && ~isnan(ExportparametersSTAIRS{i, 20})
                  ExportparametersSTAIRS{i, 23} = (ExportparametersSTAIRS{i, 19}-ExportparametersSTAIRS{i,20}) / (0.5 * (ExportparametersSTAIRS{i, 19}+ExportparametersSTAIRS{i,20})) * 100;
            else
                  ExportparametersSTAIRS{i, 23} = NaN; 
            end
            if ~isnan(ExportparametersSTAIRS{i, 21}) && ~isnan(ExportparametersSTAIRS{i, 22})
                  ExportparametersSTAIRS{i, 24} = (ExportparametersSTAIRS{i, 21}-ExportparametersSTAIRS{i,22}) / (0.5 * (ExportparametersSTAIRS{i, 21}+ExportparametersSTAIRS{i,22})) * 100;
            else
                  ExportparametersSTAIRS{i, 24} = NaN; 
            end
        end
    
end
        