function [ i_vec ] = heelstrike( p_vec, rot, Ts, Tw )
% Heelstrike detection algorithm
% p_vec --> whole foot trajectory in x- axis
% rot --> Pelvis Rotation trajectory
% Ts --> Sampling time (e.g., 60Hz for Xsens)
% Tw --> Window time range. Tipically 0.5-0.8 is fine. Could be larger if
% single gait cycle time period is larger (e.g., patients with slow gait speed). 


    ll = length(p_vec);
    window = round(1/Ts*Tw);
    
    [pks,locs] = findpeaks(p_vec);
    
% check range of window (+-Tw sec) to detect the actual heelstrike frame (max peak)   
    locs2 = 0;
    for i = 1:length(locs)
        tmp = locs(i);
        peak = max(p_vec(max(tmp-window,1):min(tmp+window,ll)));
        if peak == p_vec(tmp)
            locs2 = [locs2 locs(i)];
        end
    end
    locs2 = locs2(2:end);
    
    % Rearrange peak values
    for i = 1:length(locs2)-1
        locs3(i,1) = locs2(i);
        locs3(i,2) = locs2(i+1);
    end
    
    % To avoid turning detected by checking peak to peak range is larger than 45deg. 
    % t_step each step time has to be between 0.5 sec to 5 sec
    locs4 = [0 0];
    for i = 1:size(locs3,1)
        
        t_step = Ts*(locs3(i,2)-locs3(i,1));
        rotation = abs(rot(locs3(i,2))-rot(locs3(i,1)));
        
        if t_step>=0.3 && t_step<=5 && rotation<=45
            locs4 = [locs4; locs3(i,:)];
        end
        
    end
    locs4 = locs4(2:end,:);
    
    
    i_vec = locs4;

    
%     figure(1)
%     hold on
%     plot(p_vec)
%     plot(i_vec(:,1),p_vec(i_vec(:,1)),'*')
%     plot(i_vec(:,2),p_vec(i_vec(:,2)),'o')
    
end

