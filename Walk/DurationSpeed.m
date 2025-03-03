function [Exportparameters] = DurationSpeed(data, bodyside, Exportparameters, sf, finalTableL, finalTableR)
    % 1. First, loop through both sides (left and right) to calculate stance and swing times
    for k = 1:numel(bodyside)
        % Extract the data for the body side
        s = data.segmented.new_seg.Segmented.(bodyside{k});
        
        if k == 1
           startstride = finalTableL(:, 5:6);
        else
           startstride = finalTableR(:, 5:6);
        end
        for i = 1: height(startstride)
            duration = (startstride{i, 2} - startstride{i, 1})/sf;
            if k == 1
                Exportparameters{i, 22} = duration;
                Exportparameters{i, 25} = Exportparameters{i, 19}/Exportparameters{i, 22};
            elseif k == 2
                Exportparameters{i, 23} = duration;
                Exportparameters{i, 26} = Exportparameters{i, 20}/Exportparameters{i, 23};
            end
        end
    end   
    %calculating step duration assymetry
    for i = 1:height(Exportparameters)
       if ~isnan(Exportparameters{i, 22}) && ~isnan(Exportparameters{i, 23})
          Exportparameters{i, 24} = (Exportparameters{i, 22}-Exportparameters{i,23}) / (0.5 * (Exportparameters{i, 22}+Exportparameters{i,23})) * 100;
       else
          Exportparameters{i, 24} = NaN; 
       end
    end 
    %calculating step velocity assymetry
    for i = 1:height(Exportparameters)
       if ~isnan(Exportparameters{i, 25}) && ~isnan(Exportparameters{i, 26})
          Exportparameters{i, 27} = (Exportparameters{i, 25}-Exportparameters{i,26}) / (0.5 * (Exportparameters{i, 25}+Exportparameters{i,26})) * 100;
       else
          Exportparameters{i, 27} = NaN; 
       end
    end  
end
