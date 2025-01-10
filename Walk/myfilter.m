function [data] = filter(data, sf)

[b, a] = butter(4, 1/(sf/2), 'high');

for i = 1:size(data.segmented.new_seg.Segmented.Lseg.Pos_seg, 1)
    for j = 1:size(data.segmented.new_seg.Segmented.Lseg.Pos_seg, 2)
        if ~isempty(data.segmented.new_seg.Segmented.Lseg.Pos_seg{i, j})
            filterdata = filtfilt(b, a, data.segmented.new_seg.Segmented.Lseg.Pos_seg{i, j});
            data.segmented.new_seg.Segmented.Lseg.PosFiltered_seg{i, j} = filterdata;
        end
    end
end

for i = 1:size(data.segmented.new_seg.Segmented.Rseg.Pos_seg, 1)
    for j = 1:size(data.segmented.new_seg.Segmented.Rseg.Pos_seg, 2)
        if ~isempty(data.segmented.new_seg.Segmented.Rseg.Pos_seg{i, j})
            filterdata = filtfilt(b, a, data.segmented.new_seg.Segmented.Rseg.Pos_seg{i, j});
            data.segmented.new_seg.Segmented.Rseg.PosFiltered_seg{i, j} = filterdata;
        end
    end
end
end