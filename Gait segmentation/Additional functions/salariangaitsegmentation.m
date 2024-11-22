function [gaiteventsidx,gaiteventstime,validoutput] = salariangaitsegmentation(signal,time,figureflag,peak_thr)
% Gait segmentation based on the paper by Salarian et al. 2004. The
% algorithm identifies the timings of initial contact (IC) and final
% contact (TC) starting from the peak of the mid-swing (MS). Filtering is
% not introduced because the signal is low-sampled. 
%
% Version1 - Dec2021 - FLanotte
%--------------------------------------------------------------------------------
gaiteventsidx   = table(); 	% Table with indeces
gaiteventstime  = table();	% Table with timings
if isnan(signal) | length(signal)<30
    gaiteventsidx.InitialContact  	= nan;	% Initial contact
    gaiteventsidx.MidStance       	= nan;  % Mid-stance
    gaiteventsidx.TerminalContact 	= nan;  % Terminal contact
    gaiteventsidx.MidSwing       	= nan;  % Mid-Swing
    gaiteventsidx.FollowingContact	= nan;	% Initial following contact 
    
    gaiteventstime.InitialContact  	= nan;	% Initial contact
    gaiteventstime.MidStance       	= nan;  % Mid-stance
    gaiteventstime.TerminalContact 	= nan;  % Terminal contact
    gaiteventstime.MidSwing       	= nan;  % Mid-Swing
    gaiteventstime.FollowingContact	= nan;	% Initial following contact
    validoutput     = 0;
    return
end
%% STEP 0 - Identify the verse or rotation
mean_positive_peaks = abs(mean(findpeaks(signal,'MinPeakHeight',30)));
mean_negative_peaks = abs(mean(findpeaks(-signal,'MinPeakHeight',30)));

if abs(mean_positive_peaks-mean_negative_peaks) < 20 || any([isnan(mean_positive_peaks),isnan(mean_negative_peaks)])
    figure,plot(signal)
    changeflag = questdlg('Change sign of the signal?','User input','Yes','No','No');
    if strcmp(changeflag,'Yes')
        signal = -signal;
    end
    close
else
    signal  = (mean_positive_peaks > mean_negative_peaks)*signal -...
        (mean_positive_peaks < mean_negative_peaks)*signal;
end
%% STEP 1 - Mid swing identification
pkth            = max(signal)/3;                            % Find the maximum value in the signal to set the peak threshold to 1/3
vlth            = max(-20,min(signal)/3);
[pks, MS_idx]	= findpeaks(signal,'MinPeakHeight',pkth);	% Identify MS candidates
pkstiming       = time(MS_idx);                             % Timings of the peaks
Npks            = length(pks);                              % Number of peaks
% peak_thr        = 0.72;
for p = 1 : Npks
    if isnan(pks(p))
        continue
    end
    % Check if there are multiple adjacents peaks candidates
    min_window  = max([time(1) pkstiming(p)-peak_thr]);
    max_window  = min([time(end) pkstiming(p)+peak_thr]);
    pkspresence = find(pkstiming >= min_window & pkstiming <= max_window);
    if length(pkspresence) > 1
        [~, idxpk]              = max(pks(pkspresence));                    % Select the highest peak in the range
        pkstodelete             = setdiff(pkspresence,pkspresence(idxpk));	% Indeces of peaks not valid
        pks(pkstodelete)    	= nan;                                      % Deleting pks
        MS_idx(pkstodelete)   	= nan;                                      % Deleting locs
        pkstiming(pkstodelete)	= nan;                                      % Deleting timings
    end
end
MS_idx(isnan(pks))        	= [];
pks(isnan(pks))             = [];
pkstiming(isnan(pkstiming)) = [];
%% STEP 2 - Finding Initial and Terminal contacts
Npks	= length(pks);     % Number of peaks corrected
for p = 1 : Npks
    % Initial contact, first local minimun under -20deg/s after the MS
    if p > 1
        incr = max([0.8,0.20*(pkstiming(p)-pkstiming(p-1))]);
    else
        incr = 0.8;
    end
    windowidx   = find(time >= pkstiming(p) & time <= (pkstiming(p) + incr));
    if sum(ismember(MS_idx,windowidx)) > 1
        windowidx = find(time >= pkstiming(p) & time < (pkstiming(p+1)));
    end
    icidx       = windowidx(islocalmin(signal(windowidx)));
    IC_idx(p)	= nan;  % Sarlarian initial contact index
    if ~isempty(icidx)
        tmpidx = find(signal(icidx)<-20,1,'first');
        if ~isempty(tmpidx)
            IC_idx(p) = icidx(tmpidx);
            % Robustness to flat regions
            if tmpidx < length(icidx)
                cond1 = signal(icidx(tmpidx+1))<signal(icidx(tmpidx));
                cond2 = sum(signal(icidx(tmpidx):icidx(tmpidx+1))>signal(icidx(tmpidx))) == 0;
                if cond1 && cond2
                    IC_idx(p) = icidx(tmpidx+1);
                end
            end
        end
    end
        
    % Final contact, first local minimun under -10deg/s before the MS
    windowidx   = find(time <= pkstiming(p) & time >= (pkstiming(p) - 0.7));
    tcidx       = windowidx(islocalmin(signal(windowidx))); 
    TC_idx(p)   = nan;
    if ~isempty(tcidx)
        tmpidx = find(signal(tcidx)<vlth,1,'last');
        if ~isempty(tmpidx)
            TC_idx(p) = tcidx(tmpidx);
            % Robustness to flat regions
            if tmpidx > 1
                cond1 = signal(tcidx(tmpidx-1))<signal(tcidx(tmpidx));
                cond2 = sum(signal(tcidx(tmpidx-1):tcidx(tmpidx))>signal(tcidx(tmpidx))) == 0;
                if cond1 && cond2
                    TC_idx(p) = tcidx(tmpidx-1);
                end
            end
        end
    end
end
TC_idx(isnan(TC_idx))	= [];
IC_idx(isnan(IC_idx))	= [];
%% STEP 3 - Plotting
if figureflag
    figure,hold on,
    plot(time,signal,'DisplayName','Signal','Color','k','LineWidth',1)
    plot(time(MS_idx),signal(MS_idx),'o','DisplayName','Mid-Swing','Color','r','LineWidth',1.2)
    plot(time(IC_idx),signal(IC_idx),'x','DisplayName','Initial contact','Color',[0 0.6 0],'LineWidth',1.2)
    try
        plot(time(TC_idx),signal(TC_idx),'d','DisplayName','Terminal contact','Color','b','LineWidth',1.2)
    end
    xlabel('Time (s)'),ylabel('Transversal Angular velocity (dps)')
    legend('Color','none','EdgeColor','none')
%     waitforbuttonpress;
%     close
end
%% STEP 4 - Matrix organization
% Sorting the events as a nx4 matrix IC - TC - MS - IC
NumIC = length(MS_idx);     % Number of initial contacts
for s = 2 : NumIC 
    % Initial contact
    try 
        idx_ic = find((IC_idx>MS_idx(s-1))&(IC_idx<MS_idx(s)),1,'last');
    catch
        idx_ic = find((IC_idx<MS_idx(s)),1,'last');
    end
    % Terminal contact
    try 
        idx_tc = find((TC_idx>MS_idx(s-1))&(TC_idx<MS_idx(s)),1,'last');
    catch
        idx_tc = find((TC_idx<MS_idx(s)),1,'last');
    end
    % Following contact
    try 
        idx_fc = find((IC_idx>MS_idx(s))&(IC_idx<MS_idx(s+1)),1,'last');
    catch
        idx_fc = find(IC_idx>MS_idx(s),1,'last');
    end
   
    % Matrix with indeces and timings
    if ~isempty(idx_ic)
        gaiteventsidx.InitialContact(s-1)  	= IC_idx(idx_ic);	% Initial contact
        gaiteventstime.InitialContact(s-1) 	= time(IC_idx(idx_ic));	% Initial contact
    else
        gaiteventsidx.InitialContact(s-1)  	= nan;	% Initial contact
        gaiteventstime.InitialContact(s-1) 	= nan;	% Initial contact
    end
    
    if ~isempty(idx_tc)
        gaiteventsidx.TerminalContact(s-1)	= TC_idx(idx_tc);	% Terminal contact
        gaiteventstime.TerminalContact(s-1)	= time(TC_idx(idx_tc));	% Terminal contact
    else
        gaiteventsidx.TerminalContact(s-1) 	= nan;	% Terminal contact
        gaiteventstime.TerminalContact(s-1)	= nan;	% Terminal contact
    end

    gaiteventsidx.MidSwing(s-1)        	= MS_idx(s);        % Mid-Swing
    gaiteventstime.MidSwing(s-1)     	= time(MS_idx(s));      % Mid-Swing
    
    if ~isempty(idx_fc)
        gaiteventsidx.FollowingContact(s-1)     = IC_idx(idx_fc);	% Terminal contact
        gaiteventstime.FollowingContact(s-1)	= time(IC_idx(idx_fc));	% Terminal contact
    else
        gaiteventsidx.FollowingContact(s-1) 	= nan;	% Terminal contact
        gaiteventstime.FollowingContact(s-1)	= nan;	% Terminal contact
    end 
    
end
validoutput = 1;
end



