function [gait_mean, gait_std, gait_re, single_frames, gait] = single_gait(data,cut_frame,dt)

% Single Gait Cycle Extract Algorithm

k = cut_frame;

n = 0;
for i = 1:2:length(k)
    n = n+1;
    gait{n} = data(cut_frame(i):cut_frame(i+1));
    single_frames(n) = (length(gait{n})*dt)';
end

tf = 1;
SGframe = 100;
for i = 1:1:n
    gait_re(:,i) = set_frame(gait{i},1,SGframe);
end

gait_mean = mean(gait_re')';
gait_std = std(gait_re')';