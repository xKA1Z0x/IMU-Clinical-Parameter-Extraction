function [Exportparameters] = Arm(data, Exportparameters)
    %calling the body side in a loop
        
        s = data.subdata_out.Segmented;
for i = 1:max(size(s.Lseg.Q_seg, 1), size(s.Rseg.Q_seg, 1))
    
    % Check and calculate for Exportparameters{i, 46}
    if i <= size(s.Lseg.AV_seg, 1) && i <= size(s.Rseg.AV_seg, 1) && ...
       ~isempty(s.Lseg.AV_seg{i, 58}) && ~isempty(s.Rseg.AV_seg{i, 58})
        Exportparameters{i, 46} = max(s.Lseg.AV_seg{i, 58}) - min(s.Rseg.AV_seg{i, 58});
    else
        Exportparameters{i, 46} = NaN;  % Set to NaN if data is missing or empty
    end
    
    % Check and calculate for Exportparameters{i, 47}
    if i <= size(s.Lseg.Q_seg, 1) && i <= size(s.Rseg.Q_seg, 1) && ...
       ~isempty(s.Lseg.Q_seg{i, 46}) && ~isempty(s.Rseg.Q_seg{i, 46})        
       Exportparameters{i, 47} = max(s.Lseg.AV_seg{i, 46}) - min(s.Rseg.AV_seg{i, 46});
    else
        Exportparameters{i, 47} = NaN;  % Set to NaN if data is missing or empty
    end
    
    % Check and calculate for Exportparameters{i, 49}
    if i <= size(s.Lseg.Q_seg, 1) && i <= size(s.Rseg.Q_seg, 1) && ...
       ~isempty(s.Lseg.Q_seg{i, 58}) && ~isempty(s.Rseg.Q_seg{i, 58})
        Exportparameters{i, 49} = max(s.Lseg.Q_seg{i, 58}) - min(s.Rseg.Q_seg{i, 58});
    else
        Exportparameters{i, 49} = NaN;  % Set to NaN if data is missing or empty
    end
    
    % Check and calculate for Exportparameters{i, 50}
    if i <= size(s.Lseg.Q_seg, 1) && i <= size(s.Rseg.Q_seg, 1) && ...
       ~isempty(s.Lseg.Q_seg{i, 46}) && ~isempty(s.Rseg.Q_seg{i, 46})
        Exportparameters{i, 50} = max(s.Lseg.Q_seg{i, 46}) - min(s.Rseg.Q_seg{i, 46});
    else
        Exportparameters{i, 50} = NaN;  % Set to NaN if data is missing or empty
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