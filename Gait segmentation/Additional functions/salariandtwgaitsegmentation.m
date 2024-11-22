function [gaiteventsidx,gaiteventstime,validoutput] = salariandtwgaitsegmentation(signal,gyr_norm,acc_norm,time,template,figureflag,peak_thr)
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

if abs(mean_positive_peaks-mean_negative_peaks) < 25 || any([isnan(mean_positive_peaks),isnan(mean_negative_peaks)])
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
[pks, MS_idx,w_pks]	= findpeaks(signal,'MinPeakHeight',pkth);	% Identify MS candidates
pkstiming       = time(MS_idx);                                 % Timings of the peaks
Npks            = length(pks);                                  % Number of peaks
% FFT analysis
% [spectrum, freq] = FFT_data(signal,500,0);
% waitforbuttonpress
% close
% [freq_peak, fpeakidx] = findpeaks(spectrum,'MinPeakProminence',max(spectrum)/3,'MinPeakDistance',8,'MinPeakheight',max(spectrum)/2);
% peak_thr    = 1/freq(fpeakidx(1))-0.3;
% peak_thr    = 0.72;
for p = 1 : Npks
    if isnan(pks(p))
        continue
    end
    % Check if there are multiple adjacents peaks candidates
    min_window  = max([time(1) pkstiming(p)-peak_thr]);
    max_window  = min([time(end) pkstiming(p)+peak_thr]);
    pkspresence = find(pkstiming >= min_window & pkstiming <= max_window);
    if length(pkspresence) > 1
        w_th                    = mean(w_pks(pkspresence));
        idxpk                   = find(w_pks(pkspresence) > w_th);
        if length(idxpk) > 1
            [~, idxpk_2]    	= max(pks(pkspresence(idxpk)));     % Select the highest peak in the range
            [~, idxpk_3]    	= min(w_pks(pkspresence(idxpk)));   % Peak with the lowest width
            if idxpk_2 == idxpk_3 % Discard if the highest has the min prominence
                idxpk(idxpk_2)  = [];
                [~, idxpk_2]   	= max(pks(pkspresence(idxpk)));
            end
            idxpk             	= idxpk(idxpk_2);
        end
        pkstodelete             = setdiff(pkspresence,pkspresence(idxpk));	% Indeces of peaks not valid
        pks(pkstodelete)    	= nan;                                      % Deleting pks
        MS_idx(pkstodelete)   	= nan;                                      % Deleting locs
        pkstiming(pkstodelete)	= nan;                                      % Deleting timings
        w_pks(pkstodelete)      = nan;                                      % Deleting widths
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
    IC_idx_S(p)	= nan;  % Sarlarian initial contact index
    if ~isempty(icidx)
        tmpidx = find(signal(icidx)<-20,1,'first');
        if ~isempty(tmpidx)
            IC_idx_S(p) = icidx(tmpidx);
            % Robustness to flat regions
            if tmpidx < length(icidx)
                cond1 = signal(icidx(tmpidx+1))<signal(icidx(tmpidx));
                cond2 = sum(signal(icidx(tmpidx):icidx(tmpidx+1))>signal(icidx(tmpidx))) == 0;
                if cond1 && cond2
                    IC_idx_S(p) = icidx(tmpidx+1);
                end
            end
        end
    end
    
    % Initial contact, the peak of the norm of the acc
    IC_idx_N(p) = nan;  % norm-based initial contact
    icidx       = windowidx(islocalmin(acc_norm(windowidx)));
    if ~isempty(icidx)
        negidx = find(signal(icidx) <= 0,1,'first');
        if isempty(negidx)
            [~, negidx] = min(signal(icidx));
        end
        IC_idx_N(p) = icidx(negidx);	% The first local minima
    else
        [~, minidx] = min(acc_norm(windowidx));
        IC_idx_N(p) = windowidx(minidx);
    end
        
    % Final contact, first local minimun under -10deg/s before the MS
    TC_idx(p)   = nan;
    while isnan(TC_idx(p))
        windowidx   = find(time <= pkstiming(p) & time >= (pkstiming(p) - incr));
        tcidx       = windowidx(islocalmin(signal(windowidx)));
        [~,temp_idx,~,tcpr] = findpeaks(-signal(windowidx),'MinPeakHeight',vlth);
        tcpk        = windowidx(temp_idx);
        if ~isempty(tcidx)
            tmpidx = find(signal(tcidx)<vlth,1,'last');
            if ~isempty(tmpidx)
                TC_idx(p) = tcidx(tmpidx);
                % Robustness to flat regions
                if tmpidx > 1
                    cond1 = signal(tcidx(tmpidx-1))<signal(tcidx(tmpidx));
                    cond2 = sum(signal(tcidx(tmpidx-1):tcidx(tmpidx))>signal(tcidx(tmpidx))) == 0;
                    if ismember(tcidx(tmpidx),tcpk) % Select the peak with highest prominence
                        [~,p_loc] = ismember(tcidx(tmpidx),tcpk);
                        if numel(p_loc) == 1
                            cond2 = 0;  % The location found is the only peak
                        else
                            cond2 = tcpr(p_loc-1) > tcpr(p_loc);
                        end
                    end                   
                    if cond1 && cond2
                        TC_idx(p) = tcidx(tmpidx-1);
                    end
                end
            end
        end
        if isnan(TC_idx(p))
            % Terminal contact, the peak of the norm of the gyro
            %         icidx       = windowidx(islocalmax(acc_norm(windowidx)));
            %         if ~isempty(icidx)
            %             [~,tempidx] = max(acc_norm(icidx));
            %             TC_idx(p)   = icidx(tempidx);	% The hishest local maxima
            %         end
            % Terminal contact, based on the quantity of motion
            icidx       = windowidx(islocalmax(gyr_norm(windowidx)));
            if ~isempty(icidx)
                tempidx = find(signal(icidx)<0 & gyr_norm(icidx)>median(gyr_norm(icidx)),1,'last');
                if ~isempty(tempidx)
                    TC_idx(p)   = icidx(tempidx);
                else
                    [~,tempidx] = min(signal(icidx));
                    TC_idx(p)   = icidx(tempidx);
                end
            end
        end
        if isnan(TC_idx(p))
            incr = incr+0.1;
            if pkstiming(p) - incr < 0
                % Timing has not been recorded
                break
            end
        end
    end
end
TC_idx(isnan(TC_idx))       = [];
%% STEP 3 - DTW-based checking
%% STEP 3a - find the candidates of initial contacts
for p = 2 : Npks
    previouscontactidx_S    = find((IC_idx_S <= MS_idx(p) & IC_idx_S >= MS_idx(p-1)),1,'last');  % Previous contact Salarian-based
    previouscontactidx_N    = find((IC_idx_N <= MS_idx(p) & IC_idx_N >= MS_idx(p-1)),1,'last');  % Previous contact Norm-based
    nanmask     = [isempty(previouscontactidx_S),isempty(previouscontactidx_N)];
    if nanmask == [1 0]
        IC_range{p-1} = IC_idx_N(previouscontactidx_N);
    else if nanmask == [0 1]
            IC_range{p-1} = IC_idx_S(previouscontactidx_S);
        else if nanmask == [0 0]
                if IC_idx_S(previouscontactidx_S) == IC_idx_N(previouscontactidx_N)
                    IC_range{p-1} = IC_idx_S(previouscontactidx_S);
                else
                    minval = min([IC_idx_S(previouscontactidx_S),IC_idx_N(previouscontactidx_N)]);
                    maxval = max([IC_idx_S(previouscontactidx_S),IC_idx_N(previouscontactidx_N)]);
                    if maxval-minval <= 3
                        IC_range{p-1} = [minval,maxval];
                    else
                        midval = randi([minval+2,maxval-2]);
                        IC_range{p-1} = [minval,midval,maxval];
                    end
                end
            end
            if nanmask == [1 1]
               1;
            end
        end
    end
end
%% Step 3b - Get all possible combinations of initial contacts
if length(IC_range) > 15
    temp = IC_range;
    clear IC_range
    counter = 1;
    for i = 1:10:length(temp)
        stoprange = min([i+10,length(temp)]);
        IC_range(counter,1:stoprange-i+1) = temp(i:stoprange);
        counter = counter + 1;
    end
end
IC_idx = [];
for i = 1 : size(IC_range,1)
    D      	= IC_range(i,~cellfun(@isempty,IC_range(i,:)));
    [D{:}]	= ndgrid(IC_range{i,~cellfun(@isempty,IC_range(i,:))});
    contactcomb = cell2mat(cellfun(@(m)m(:),D,'uni',0));
    clear D
    %% Step 3c - Choose the combination with less comulative error from template
    distval     = nan(size(contactcomb));
    distval(:,end) = [];
    for s = 2 : size(IC_range,2)
        for ic1 = 1 : length(IC_range{i,s-1})
            for ic2 = 1 : length(IC_range{i,s})
                cont1   = IC_range{i,s-1}(ic1);
                cont2   = IC_range{i,s}(ic2);
                % Replace possible nan of the signals with zeros
                signal_step = signal(cont1:cont2);
                signal_step(isnan(signal_step)) = 0;
                % DTW evaluation
                dtwdist{i,s}(ic1,ic2) = dtw(rescale(signal_step,0,1),template);
                rowidx  = find((contactcomb(:,s-1) == cont1) & (contactcomb(:,s) == cont2));
                distval(rowidx,s-1) = dtwdist{i,s}(ic1,ic2);
            end
        end
    end
    [cost,combidx] = min(sum(distval,2));
    IC_idx = [IC_idx,contactcomb(combidx,:)];
    clear distval combidx contactcomb
    if i < size(IC_range,1)
        IC_range{i+1,1} = IC_idx(end);
    end
end
IC_idx = unique(IC_idx);
%% Mid-stance detection
for i = 1 : length(IC_idx)
    ic_idx      = IC_idx(i);
    temp_idx    = find(TC_idx > ic_idx,1,'first');
    if isempty(temp_idx)
        continue
    else
        tc_idx  = TC_idx(temp_idx);
    end
    signal_stance   = signal(ic_idx:tc_idx);
    % plot(signal_stance)
    [~,ms_point]	= max(signal_stance(100:end-100));
    if isempty(ms_point)
        [~,ms_point]	= max(signal_stance);
        MSt_idx(i)    	= ms_point + ic_idx - 1;
    else
        MSt_idx(i)    	= ms_point + 100 + ic_idx - 1;
    end
end
%% STEP 3 - Plotting
if figureflag
    figure,hold on,
    set(gcf, 'Position', get(0, 'Screensize'));
    plot(time,signal,'DisplayName','Signal','Color','k','LineWidth',1)
    plot(time(MSt_idx),signal(MSt_idx),'o','DisplayName','Mid-Stance','Color',[1 0.5 0],'LineWidth',1.2)
    plot(time(MS_idx),signal(MS_idx),'o','DisplayName','Mid-Swing','Color','r','LineWidth',1.2)
    plot(time(IC_idx),signal(IC_idx),'x','DisplayName','Initial contact','Color',[0 0.6 0],'LineWidth',1.2)
    plot(time(TC_idx),signal(TC_idx),'d','DisplayName','Terminal contact','Color','b','LineWidth',1.2)   
    xlabel('Time (s)'),ylabel('Transversal Angular velocity (dps)')
    legend('Color','none','EdgeColor','none')
    waitforbuttonpress;
%     close
end
%% STEP 4 - Matrix organization
% Sorting the events as a nx4 matrix IC - TC - MS - IC
NumIC = length(IC_idx);     % Number of initial contacts
for s = 2 : NumIC
    % Matrix with indeces
    gaiteventsidx.InitialContact(s-1)  	= IC_idx(s-1);                                 % Initial contact
    gaiteventsidx.MidStance(s-1)        = MSt_idx(find(MSt_idx>IC_idx(s-1),1,'first'));% Mid-Swing
    gaiteventsidx.TerminalContact(s-1) 	= TC_idx(find(TC_idx>IC_idx(s-1),1,'first'));  % Terminal contact
    gaiteventsidx.MidSwing(s-1)        	= MS_idx(find(MS_idx>IC_idx(s-1),1,'first'));  % Mid-Swing
    gaiteventsidx.FollowingContact(s-1)	= IC_idx(s);                                   % Initial following contact 
    
    % Matrix with timings
    gaiteventstime.InitialContact(s-1) 	= time(IC_idx(s-1));                                 % Initial contact
    gaiteventstime.MidStance(s-1)       = time(MSt_idx(find(MSt_idx>IC_idx(s-1),1,'first')));% Mid-Swing
    gaiteventstime.TerminalContact(s-1)	= time(TC_idx(find(TC_idx>IC_idx(s-1),1,'first')));  % Terminal contact
    gaiteventstime.MidSwing(s-1)     	= time(MS_idx(find(MS_idx>IC_idx(s-1),1,'first')));  % Mid-Swing
    gaiteventstime.FollowingContact(s-1)= time(IC_idx(s));                                   % Initial following contact 
    
end
validoutput = 1;
end



