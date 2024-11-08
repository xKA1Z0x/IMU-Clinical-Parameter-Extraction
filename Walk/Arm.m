function [Exportparameters] = Arm(data, bodyside, Exportparameters)
    %calling the body side in a loop
    for k = 1:numel(bodyside)
        s = data.subdata_out.Segmented.(bodyside{k});
        for i = 1:size(s.AV_seg, 1)
            Exportparameters{i, k+45} = max(s.AV_seg{i, (-12 * k + 71)}) - min(s.AV_seg{i, (-12 * k + 71)});
            Exportparameters{i, k+48} = max(s.Q_seg{i, (-12 * k + 71)}) - min(s.Q_seg{i, (-12 * k + 71)});
        end
    end
   for i = 1:height(Exportparameters)
       if ~isnan(Exportparameters{i, 46}) && ~isnan(Exportparameters{i, 47})
          Exportparameters{i, 48} = (Exportparameters{i, 46}-Exportparameters{i,47}) / (0.5 * (Exportparameters{i, 46}+Exportparameters{i,47})) * 100;
       else
          Exportparameters{i, 48} = NaN; 
       end
   end
      for i = 1:height(Exportparameters)
       if ~isnan(Exportparameters{i, 49}) && ~isnan(Exportparameters{i, 50})
          Exportparameters{i, 51} = (Exportparameters{i, 49}-Exportparameters{i,50}) / (0.5 * (Exportparameters{i, 49}+Exportparameters{i,50})) * 100;
       else
          Exportparameters{i, 51} = NaN; 
       end
      end
end