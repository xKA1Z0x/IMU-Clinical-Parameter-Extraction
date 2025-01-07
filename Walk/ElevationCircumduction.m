function Exportparameters = ElevationCircumduction(data, bodyside, Exportparameters)
    LHS = data.segmented.new_seg.Segmented.Lseg.Contact{:, 1};
    RHS = data.segmented.new_seg.Segmented.Rseg.Contact{:, 1};
    LTO = data.segmented.new_seg.Segmented.Lseg.Contact{:, 2};
    RTO = data.segmented.new_seg.Segmented.Rseg.Contact{:, 2};
    
    for k = 1:numel(bodyside)
        s = data.segmented.new_seg.Segmented.(bodyside{k});
        for i = 1:size(s.Pos_seg, 1)
            if k == 1
                if LHS(i) - LTO(i) >= 0
                    swing = 0;
                    swingfilter = 0;
                else
                    swing = s.Pos_seg{i, 9};
                    swing(LHS(i):LTO(i)) = [];
                    swingfilter = s.PosFiltered_seg{i, 8};
                    swingfilter(LHS(i):LTO(i)) = [];
                end
            elseif k == 2
                if RHS(i) - RTO(i) >= 0
                    swing = 0;
                    swingfilter = 0;
                else
                swing = s.Pos_seg{i, 6};
                swing(RHS(i):RTO(i)) = [];
                swingfilter = s.PosFiltered_seg{i, 5};
                swingfilter(RHS(i):RTO(i)) = [];
                end
            end
            Exportparameters{i, k + 15} = max(swing)-min(swing);
            Exportparameters{i, k + 36} = max(swingfilter) - min(swingfilter);
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