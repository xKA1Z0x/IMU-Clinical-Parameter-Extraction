function [Exportparameters] = ToeAngles(data, bodyside, Exportparameters)
    LHS = data.segmented.new_seg.Segmented.Lseg.Contact{:, 1};
    RHS = data.segmented.new_seg.Segmented.Rseg.Contact{:, 1};
    LTO = data.segmented.new_seg.Segmented.Lseg.Contact{:, 2};
    RTO = data.segmented.new_seg.Segmented.Lseg.Contact{:, 2};

    for k = 1:numel(bodyside)   %Loop through body side
        s = data.segmented.new_seg.Segmented.(bodyside{k});  %Select the bodyside
        if k == 1
            for i = 1:length(LHS)
                if LHS(i) >= LTO(i)
                    Exportparameters{i, 34} = 0;
                    Exportparameters{i, 28} = 0;
                    Exportparameters{i, 31} = 0;
                else
                %Heel Strike Angle
                Exportparameters{i, 34} = s.Q_seg{i, 20}(LHS(i));
                %Toe Off Angle
                Exportparameters{i, 28} = s.Q_seg{i, 20}(LTO(i));
                %Toe Out
                Exportparameters{i, 31} = mean(s.Q_seg{i, 21}(LHS(i):LTO(i)));
                end
            end
        elseif k == 2
            for i = 1:length(RHS)
                if RHS(i) >= RTO(i)
                    Exportparameters{i, 35} = 0;
                    Exportparameters{i, 29} = 0;
                    Exportparameters{i, 32} = 0;
                else
                %Heel Strike
                Exportparameters{i, 35} = s.Q_seg{i, 11}(RHS(i));
                %Toe Off
                Exportparameters{i, 29} = s.Q_seg{i, 11}(RTO(i));
                %Toe Out
                Exportparameters{i, 32} = mean(s.Q_seg{i, 12}(RHS(i): RTO(i)));
                end
            end
        end
    end
    for i = 1:height(Exportparameters)
        if Exportparameters{i, 28} == 0 || Exportparameters{i, 29} == 0
            Exportparameters{i, 30} = 0;
        elseif ~isnan(Exportparameters{i, 28}) && ~isnan(Exportparameters{i, 29})
            Exportparameters{i, 30} = (Exportparameters{i, 28}-Exportparameters{i,29}) / (0.5 * (Exportparameters{i, 28}+Exportparameters{i,29})) * 100;
        else 
            Exportparameters{i, 30} = NaN;
        end
        if Exportparameters{i, 31} == 0 || Exportparameters{i, 32} == 0
            Exportparameters{i, 33} = 0;
        elseif ~isnan(Exportparameters{i, 31}) && ~isnan(Exportparameters{i, 32})
            Exportparameters{i, 33} = (Exportparameters{i, 31}-Exportparameters{i,32}) / (0.5 * (Exportparameters{i, 31}+Exportparameters{i,32})) * 100;
        else
            Exportparameters{i, 33} = NaN;
        end
        if Exportparameters{i, 34} == 0 || Exportparameters{i, 35} == 0
            Exportparameters{i, 36} = 0;
        elseif ~isnan(Exportparameters{i, 34}) && ~isnan(Exportparameters{i, 35})
            Exportparameters{i, 36} = (Exportparameters{i, 34}-Exportparameters{i,35}) / (0.5 * (Exportparameters{i, 34}+Exportparameters{i,35})) * 100;
        else
            Exportparameters{i, 36} = NaN;
        end
    end
end

            