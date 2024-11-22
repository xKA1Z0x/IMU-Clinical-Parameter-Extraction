function gcf = plotdatasegmentedstrides(data2plot,str2plot)
GC = [0:1:100];     % gait cycle vector
FA = 0.2;           % face Alpha value
co = 0.8;           % light color
sensorlabel = {'Pelvis','Torso','R Thigh','R Shank','R Foot','L Thigh','L Shank','L Foot'};

gcf = figure;
if strcmp(str2plot,'JA')
    ax(1) = subplot(331); hold on
    plot(data2plot.JA_seg(:,:,1),'color',[co co co])
    plot(data2plot.JA_mean(:,1),'k-','linewidth',2)
    h = patch([0:100 fliplr(0:100)],[data2plot.JA_mean(:,1)'+data2plot.JA_std(:,1)' fliplr(data2plot.JA_mean(:,1)'-data2plot.JA_std(:,1)')],'k');
    set(h,'FaceAlpha',FA,'edgecolor','none')
    xlim([0 100])
    ylabel('Pelvis Oblq [Deg]')
    
    ax(2) = subplot(332); hold on
    plot(data2plot.JA_seg(:,:,2),'color',[co co co]);
    plot(data2plot.JA_mean(:,2),'k-','linewidth',2)
    h = patch([0:100 fliplr(0:100)],[data2plot.JA_mean(:,2)'+data2plot.JA_std(:,2)' fliplr(data2plot.JA_mean(:,2)'-data2plot.JA_std(:,2)')],'k');
    set(h,'FaceAlpha',FA,'edgecolor','none')
    xlim([0 100])
    ylabel('Pelvis Tilt [Deg]')
    xlabel('Gait Cycle [%]')
    
    ax(3) = subplot(333); hold on
    plot(data2plot.JA_seg(:,:,3),'color',[co co co])
    plot(data2plot.JA_mean(:,3),'k-','linewidth',2)
    h = patch([0:100 fliplr(0:100)],[data2plot.JA_mean(:,3)'+data2plot.JA_std(:,3)' fliplr(data2plot.JA_mean(:,3)'-data2plot.JA_std(:,3)')],'k');
    set(h,'FaceAlpha',FA,'edgecolor','none')
    xlim([0 100])
    ylabel('Pelvis Ro [Deg]')
    
    ax(4) = subplot(334); hold on
    plot(data2plot.JA_seg(:,:,7),'color',[co co co])
    h1  = plot(data2plot.JA_mean(:,7),'b-','linewidth',2);
    h   = patch([0:100 fliplr(0:100)],[data2plot.JA_mean(:,7)'+data2plot.JA_std(:,7)' fliplr(data2plot.JA_mean(:,7)'-data2plot.JA_std(:,7)')],'b');
    set(h,'FaceAlpha',FA,'edgecolor','none')
    plot(data2plot.JA_seg(:,:,16),'color',[co co co])
    h2  = plot(data2plot.JA_mean(:,16),'r-','linewidth',2);
    h   = patch([0:100 fliplr(0:100)],[data2plot.JA_mean(:,16)'+data2plot.JA_std(:,16)' fliplr(data2plot.JA_mean(:,16)'-data2plot.JA_std(:,16)')],'r');
    set(h,'FaceAlpha',FA,'edgecolor','none')
    legend([h1, h2],'Right','Left')
    xlim([0 100])
    ylabel('Hip Abd/Add [Deg]')
    
    ax(5) = subplot(335); hold on
    plot(data2plot.JA_seg(:,:,8),'color',[co co co])
    h1  = plot(data2plot.JA_mean(:,8),'b-','linewidth',2);
    h   = patch([0:100 fliplr(0:100)],[data2plot.JA_mean(:,8)'+data2plot.JA_std(:,8)' fliplr(data2plot.JA_mean(:,8)'-data2plot.JA_std(:,8)')],'b');
    set(h,'FaceAlpha',FA,'edgecolor','none')
    plot(data2plot.JA_seg(:,:,17),'color',[co co co])
    h2  = plot(data2plot.JA_mean(:,17),'r-','linewidth',2);
    h   = patch([0:100 fliplr(0:100)],[data2plot.JA_mean(:,17)'+data2plot.JA_std(:,17)' fliplr(data2plot.JA_mean(:,17)'-data2plot.JA_std(:,17)')],'r');
    set(h,'FaceAlpha',FA,'edgecolor','none')
    legend([h1, h2],'Right','Left')
    xlim([0 100])
    ylabel('Hip Int/Ext ro. [Deg]')
    xlabel('Gait Cycle [%]')
    
    ax(6) = subplot(336); hold on
    plot(data2plot.JA_seg(:,:,9),'color',[co co co])
    h1  = plot(data2plot.JA_mean(:,9),'b-','linewidth',2);
    h   = patch([0:100 fliplr(0:100)],[data2plot.JA_mean(:,9)'+data2plot.JA_std(:,9)' fliplr(data2plot.JA_mean(:,9)'-data2plot.JA_std(:,9)')],'b');
    set(h,'FaceAlpha',FA,'edgecolor','none')
    plot(data2plot.JA_seg(:,:,18),'color',[co co co])
    h2  = plot(data2plot.JA_mean(:,18),'r-','linewidth',2);
    h   = patch([0:100 fliplr(0:100)],[data2plot.JA_mean(:,18)'+data2plot.JA_std(:,18)' fliplr(data2plot.JA_mean(:,18)'-data2plot.JA_std(:,18)')],'r');
    set(h,'FaceAlpha',FA,'edgecolor','none')
    legend([h1, h2],'Right','Left')
    xlim([0 100])
    ylabel('Hip Flex/Ex [Deg]')
    xlabel('Gait Cycle [%]')
    
    ax(7) = subplot(3,4,[9 10]); hold on
    plot(data2plot.JA_seg(:,:,12),'color',[co co co])
    h1  = plot(data2plot.JA_mean(:,12),'b-','linewidth',2);
    h   = patch([0:100 fliplr(0:100)],[data2plot.JA_mean(:,12)'+data2plot.JA_std(:,12)' fliplr(data2plot.JA_mean(:,12)'-data2plot.JA_std(:,12)')],'b');
    set(h,'FaceAlpha',FA,'edgecolor','none')
    plot(data2plot.JA_seg(:,:,21),'color',[co co co])
    h2  = plot(data2plot.JA_mean(:,21),'r-','linewidth',2);
    h   = patch([0:100 fliplr(0:100)],[data2plot.JA_mean(:,21)'+data2plot.JA_std(:,21)' fliplr(data2plot.JA_mean(:,21)'-data2plot.JA_std(:,21)')],'r');
    set(h,'FaceAlpha',FA,'edgecolor','none')
    legend([h1, h2],'Right','Left')
    xlim([0 100])
    ylabel('Knee Flex/Ex [Deg]')
    xlabel('Gait Cycle [%]')
    
    ax(8) = subplot(3,4,[11 12]); hold on
    plot(data2plot.JA_seg(:,:,15),'color',[co co co])
    h1  = plot(data2plot.JA_mean(:,15),'b-','linewidth',2);
    h   = patch([0:100 fliplr(0:100)],[data2plot.JA_mean(:,15)'+data2plot.JA_std(:,15)' fliplr(data2plot.JA_mean(:,15)'-data2plot.JA_std(:,15)')],'b');
    set(h,'FaceAlpha',FA,'edgecolor','none')
    plot(data2plot.JA_seg(:,:,24),'color',[co co co])
    h2  = plot(data2plot.JA_mean(:,24),'r-','linewidth',2);
    h   = patch([0:100 fliplr(0:100)],[data2plot.JA_mean(:,24)'+data2plot.JA_std(:,24)' fliplr(data2plot.JA_mean(:,24)'-data2plot.JA_std(:,24)')],'r');
    set(h,'FaceAlpha',FA,'edgecolor','none')
    legend([h1, h2],'Right','Left')
    xlim([0 100])
    ylabel('Ankle Dorsi/Plantar Angle [Deg]')
    xlabel('Gait Cycle [%]')
end

if strcmp(str2plot,'ACC') || strcmp(str2plot,'AV')
    for i = 1 : 8
        if i == 1
            ax(i) = subplot(3,4,[1 2]);
        else
            if i == 2
                ax(i) = subplot(3,4,[3 4]);
            else
                ax(i) = subplot(3,3,i+1);
            end
        end
        hold on
        plot(data2plot.([str2plot '_seg'])(:,:,3*(i-1)+1),'color',[co+0.2 co co])
        plot(data2plot.([str2plot '_seg'])(:,:,3*i-1),'color',[co co+0.2 co])
        plot(data2plot.([str2plot '_seg'])(:,:,3*i),'color',[co co co+0.2])
        pl(1)= plot(data2plot.([str2plot '_mean'])(:,3*(i-1)+1),'r-','linewidth',2);
        pl(2)= plot(data2plot.([str2plot '_mean'])(:,3*i-1),'g-','linewidth',2);
        pl(3)= plot(data2plot.([str2plot '_mean'])(:,3*i),'b-','linewidth',2);
        xlim([0 100])
        ylabel(sensorlabel{i})
    end
    legend(pl,'x','y','z')
end
set(ax,'fontsize',10)
linkaxes(ax,'x')
end
