function [Exportparameters] = SSSD(data, bodyside, Exportparameters)

for k = 1:numel(bodyside)
    
    s = data.segmented.new_seg.Segmented.(bodyside{k});
    if k == 1
        stridestart = s.LHS_idx(:, 1);
        stridelength = s.LHS_idx(:, 2) - s.LHS_idx(:, 1) + 1;
    else
        stridestart = s.RHS_idx(:, 1);
        stridelength = s.RHS_idx(:, 2) - s.RHS_idx(:, 1) + 1;
    end
    
    for i = 1:length(stridestart)
        stance = (s.Contact{i, 2} - s.Contact{i, 1}) / stridelength(i, 1) * 100;
        swing = 100 - stance;
        if stance <= 0
            stance = 0;
            swing = 0;
        end
        Exportparameters{i, k + 3} = stance;
        Exportparameters{i, k + 6} = swing;
    end
end

for i = 1: min(length(data.segmented.new_seg.Segmented.Lseg.LHS_idx(:, 1)), length(data.segmented.new_seg.Segmented.Rseg.RHS_idx(:, 1)))
    stridelengthL = data.segmented.new_seg.Segmented.Lseg.LHS_idx(:, 2) - data.segmented.new_seg.Segmented.Lseg.LHS_idx(:, 1) + 1;
    stridelengthR = data.segmented.new_seg.Segmented.Rseg.RHS_idx(:, 2) - data.segmented.new_seg.Segmented.Rseg.RHS_idx(:, 1) + 1;
    if Exportparameters{i, k + 3} == 0 || Exportparameters{i, k + 6} == 0
       Exportparameters{i, 13} = 0;
       Exportparameters{i, 14} = 0;
       Exportparameters{i, 10} = 0;
       Exportparameters{i, 11} = 0;        
    else
       supportIdx = [data.segmented.new_seg.Segmented.Lseg.Contact{i, 3}, data.segmented.new_seg.Segmented.Lseg.Contact{i, 4}, data.segmented.new_seg.Segmented.Rseg.Contact{i, 3}, data.segmented.new_seg.Segmented.Rseg.Contact{i, 4}];
       [sorted_values, sorted_indices] = sort(supportIdx);
       A = sorted_values(1);
       B = sorted_values(2);
       C = sorted_values(3);
       D = sorted_values(4);
       
       if ismember(A, data.segmented.new_seg.Segmented.Lseg.Contact{i, :})
           double_support = C - B;
           single_support_L = B - A;
           single_support_R = D - C;
       else
           double_support = C - B;
           single_support_L = D - C;
           single_support_R = B - A;
       end
        Exportparameters{i, 10} = single_support_L / stridelengthL(i) * 100;
        Exportparameters{i, 11} = single_support_R / stridelengthR(i) * 100;
        Exportparameters{i, 13} = double_support / stridelengthL(i) * 100;
        Exportparameters{i, 14} = double_support / stridelengthR(i) * 100;
    end

end

for i = 1: height(Exportparameters)
        if ~isnan(Exportparameters{i, 4}) && ~isnan(Exportparameters{i, 5})
            Exportparameters{i, 6} = (Exportparameters{i, 4} - Exportparameters{i, 5}) / (0.5 * (Exportparameters{i, 4} + Exportparameters{i, 5})) * 100;
        else
            Exportparameters{i, 6} = NaN; 
        end 
        
        if ~isnan(Exportparameters{i, 7}) && ~isnan(Exportparameters{i, 8})
            Exportparameters{i, 9} = (Exportparameters{i, 7} - Exportparameters{i, 8}) / (0.5 * (Exportparameters{i, 7} + Exportparameters{i, 8})) * 100;
        else
            Exportparameters{i, 9} = NaN; 
        end 
        
        if ~isnan(Exportparameters{i, 10}) && ~isnan(Exportparameters{i, 11})
            Exportparameters{i, 12} = (Exportparameters{i, 10} - Exportparameters{i, 11}) / (0.5 * (Exportparameters{i, 10} + Exportparameters{i, 11})) * 100;
        else
            Exportparameters{i, 12} = NaN; 
        end 
        
        if ~isnan(Exportparameters{i , 13}) && ~isnan(Exportparameters{i, 14})
            Exportparameters{i, 15} = (Exportparameters{i, 13} - Exportparameters{i, 14}) / (0.5 * (Exportparameters{i , 13} + Exportparameters{i, 14})) * 100;
        else
            Exportparameters{i, 15} = NaN;
        end
end
end

        
        

    
    