function [mmgait,mgait, gait]=gateplot(x,k,dt,mnl,fn,sptitle,y_label)

figure(fn);
lk=length(k);
nl=0;
nd=2;
for i=1:nd:lk-2,
    nl=nl+1;
    gait{nl}=x(k(i)+1:k(i+nd)-1);
    lg(nl)=length(gait{nl}); 
end;

%mnl=round(mean(lg));
mnl=round(median(lg));
mgait=zeros(mnl,length(lg));
for i=1:length(lg),
    mgait(:,i)=set_resample(gait{i},dt,mnl);    
end;

mmgait=mean(mgait,2); 

% Plot 1cycle gaits 
for i = 1:1:length(lg)
    t = 0:dt:dt*(lg(i)-1);
    plot(t,gait{i})
    hold on
end
 
%mnl=round(mean(lg));
%mnl=round(median(lg));
mgait=zeros(mnl,length(lg));
for i=1:length(lg),
    mgait(:,i)=set_resample(gait{i},dt,mnl);    
end;
       
tm=0:dt:dt*(mnl-1);
mmgait=mean(mgait,2);
% mmgait=median(mgait,2);
period = max(tm);

plot(tm,mmgait,'rx','LineWidth',2);
title(sptitle,'fontsize', 15);
text(max(tm),0,num2str(max(tm)),'color',[1 0 0]);
xlabel('Time (sec)','fontsize', 15);
ylabel(y_label,'fontsize', 15);



