function ExportparametersSTAIRS = Cadence(processedData, bodyside, Alternate, ExportparametersSTAIRS)
    %Calling the body side in a loop
    for k = 1:numel(bodyside)
        s = processedData.(bodyside{k});
        %loop through each stride for the current body side and climbing
        %phase
        for i = 1:size(s.ACC,1)
            ExportparametersSTAIRS{i, k} = length(s.ACC{i, 1})/60;
            if Alternate == 1
                ExportparametersSTAIRS{i, k+6} = 2*(60 ^ 2)/length(s.ACC{i, 1});
            elseif Alternate == 0
                ExportparametersSTAIRS{i, k+6} = (60 ^ 2)/length(s.ACC{i, 1});
            end
        end
    end
    
    %Calculating cadence asymmetry
   for i = 1:height(ExportparametersSTAIRS)
       if ~isnan(ExportparametersSTAIRS{i, 1}) && ~isnan(ExportparametersSTAIRS{i, 2})
          ExportparametersSTAIRS{i, 5} = (ExportparametersSTAIRS{i, 1}-ExportparametersSTAIRS{i,2}) / (0.5 * (ExportparametersSTAIRS{i, 1}+ExportparametersSTAIRS{i,2})) * 100;
       else
          ExportparametersSTAIRS{i, 5} = NaN; 
       end
   end
   for i = 1:height(ExportparametersSTAIRS)
       if ~isnan(ExportparametersSTAIRS{i, 3}) && ~isnan(ExportparametersSTAIRS{i, 4})
          ExportparametersSTAIRS{i, 6} = (ExportparametersSTAIRS{i, 3}-ExportparametersSTAIRS{i,4}) / (0.5 * (ExportparametersSTAIRS{i, 3}+ExportparametersSTAIRS{i,4})) * 100;
       else
          ExportparametersSTAIRS{i, 6} = NaN; 
       end
   end
   for i = 1:height(ExportparametersSTAIRS)
       if ~isnan(ExportparametersSTAIRS{i, 7}) && ~isnan(ExportparametersSTAIRS{i, 8})
          ExportparametersSTAIRS{i, 11} = (ExportparametersSTAIRS{i, 7}-ExportparametersSTAIRS{i,8}) / (0.5 * (ExportparametersSTAIRS{i, 7}+ExportparametersSTAIRS{i,8})) * 100;
       else
          ExportparametersSTAIRS{i, 11} = NaN; 
       end
   end
   for i = 1:height(ExportparametersSTAIRS)
       if ~isnan(ExportparametersSTAIRS{i, 9}) && ~isnan(ExportparametersSTAIRS{i, 10})
          ExportparametersSTAIRS{i, 12} = (ExportparametersSTAIRS{i, 9}-ExportparametersSTAIRS{i,10}) / (0.5 * (ExportparametersSTAIRS{i, 9}+ExportparametersSTAIRS{i,10})) * 100;
       else
          ExportparametersSTAIRS{i, 12} = NaN; 
       end
   end
end
   
   
            