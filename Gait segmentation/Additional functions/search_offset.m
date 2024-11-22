function [offset,data1,data2] = search_offset(data1, data2)

range_rmse = rmse(data1,data2);

lower = -2*range_rmse;
upper = 2*range_rmse;

i = 1;
delta = 0.01;
for range = lower:delta:upper
    offset(i) = range;
    rmse_val(i) = rmse(data1+offset(i),data2);
    i = i + 1;
end

[min_val, index] = min(rmse_val)

offset = offset(index);
data1 = data1+offset;
data2 = data2;

% figure(100)
% plot(rmse_val)
% hold on
% plot(index,rmse_val(index),'rx')
% plot(index,min_val,'ko')



