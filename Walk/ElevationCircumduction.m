function Exportparameters = ElevationCircumduction(data, bodyside, Exportparameters)
    %calling the body side in a loop 
    for k = 1:numel(bodyside)
        s = data.subdata_out.Segmented.(bodyside{k});
        %loop through each stride for the current body side
        for i = 1:size(s.Pos_seg, 1)
            %calculating midswing elevation using the original Pos
                Exportparameters{i, k + 15} = max(s.Pos_seg{i,((-3*k)+12)}) - min(s.Pos_seg{i, ((-3*k)+12)});
                %calculating circumduction using the filtered Pos
                Exportparameters{i, k + 36} = max(s.PosFiltered_seg{i, ((-3*k)+11)}) - min(s.PosFiltered_seg{i, (-3*k)+11}); 

        end
    end
    %calculating midswing elevation assymetry
       for i = 1:height(Exportparameters)
           if ~isnan(Exportparameters{i, 16}) && ~isnan(Exportparameters{i, 17})
              Exportparameters{i, 18} = (Exportparameters{i, 16}-Exportparameters{i,17}) / (0.5 * (Exportparameters{i, 16}+Exportparameters{i,17})) * 100;
           else
              Exportparameters{i, 18} = NaN; 
           end
       end
     %calculating circumduction assymetry
       for i = 1:height(Exportparameters)
           if ~isnan(Exportparameters{i, 37}) && ~isnan(Exportparameters{i, 38})
              Exportparameters{i, 39} = (Exportparameters{i, 37}-Exportparameters{i,38}) / (0.5 * (Exportparameters{i, 37}+Exportparameters{i,38})) * 100;
           else
              Exportparameters{i, 39} = NaN; 
           end
       end
end