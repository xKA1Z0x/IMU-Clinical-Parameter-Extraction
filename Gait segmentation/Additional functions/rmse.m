function dif = rmse(x,y)
dif = sqrt(sum((x-y).^2) / numel(x));
