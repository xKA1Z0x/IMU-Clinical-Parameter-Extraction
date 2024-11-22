function [vec_Mod] = fix_peaks(vec)
%this is a function that should check the correct formatting of the peaks.
%Specifically, each array should be structured as [n1, n2; n2, n3;, n3, n4]
second_col=vec(1:end-1,2);
first_col=vec(2:end,1);

diff=second_col-first_col;

while ~isempty(find(diff<0))
    ind=find(diff<0);
    ind=ind(1);
    vec=[vec(1:ind, :); [vec(ind,2), vec(ind+1,1)] ; vec(ind+1:end, :)];
    second_col=vec(1:end-1,2);
    first_col=vec(2:end,1);

    diff=second_col-first_col;
end
vec_Mod=vec;

end

