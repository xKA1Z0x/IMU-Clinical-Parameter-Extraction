function ExportparametersSTAIRS = StepLength(processedData, bodyside, ExportparametersSTAIRS)
    for k = 1:numel(bodyside)
        s = processedData.(bodyside{k});
        for i = 1:size(s.Pos,1)
            if k == 1 || k == 2 
                ExportparametersSTAIRS{i, 12+k} = max(s.Pos{i, ((-3 * k) + 10)}) - min(s.Pos{i, ((-3 * k) + 10)}); 
            elseif k == 3 || k ==4
                ExportparametersSTAIRS{i, 12+k} = max(s.Pos{i, ((-3 * k) + 16)}) - min(s.Pos{i, ((-3 * k) + 16)}); 
            end
        end
    end
    for i = 1:height(ExportparametersSTAIRS)
       if ~isnan(ExportparametersSTAIRS{i, 13}) && ~isnan(ExportparametersSTAIRS{i, 14})
          ExportparametersSTAIRS{i, 17} = (ExportparametersSTAIRS{i, 13}-ExportparametersSTAIRS{i,14}) / (0.5 * (ExportparametersSTAIRS{i, 13}+ExportparametersSTAIRS{i,14})) * 100;
       else
          ExportparametersSTAIRS{i, 17} = NaN; 
       end
       if ~isnan(ExportparametersSTAIRS{i, 15}) && ~isnan(ExportparametersSTAIRS{i, 16})
          ExportparametersSTAIRS{i, 18} = (ExportparametersSTAIRS{i, 15}-ExportparametersSTAIRS{i,16}) / (0.5 * (ExportparametersSTAIRS{i, 15}+ExportparametersSTAIRS{i,16})) * 100;
       else
          ExportparametersSTAIRS{i, 18} = NaN; 
       end
    end
end