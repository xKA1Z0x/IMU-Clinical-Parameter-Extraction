function Exportparameters = StepLength(data, bodyside, Exportparameters)
    for k = 1:numel(bodyside)
        s = data.segmented.new_seg.Segmented.(bodyside{k});
        for i = 1:size(s.Pos_seg, 1)
            Exportparameters{i, k + 18} = max(s.Pos_seg{i, (k*3)+1}) - min(s.Pos_seg{i, (k*3)+1});
        end
    end
    for i = 1:height(Exportparameters)
       if ~isnan(Exportparameters{i, 19}) && ~isnan(Exportparameters{i, 20})
          Exportparameters{i, 21} = (Exportparameters{i, 19}-Exportparameters{i,20}) / (0.5 * (Exportparameters{i, 19}+Exportparameters{i,20})) * 100;
       else
          Exportparameters{i, 21} = NaN; 
       end
    end
end