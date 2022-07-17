% discount entropy

trial_num =5; 
subject= 'oded';

p=trajectories{1, trial_num};
xtraj = p(:,3);
ytraj = p(:,2);

f=events{1, trial_num};
xfix = f{:,3};
yfix = f{:,2};
fix_dur=f{:,10};
sacc_len=f{:,6};
fix_ratio= (sacc_len)./(fix_dur);
fix_ratio=normalize(fix_ratio, 'range');

N=size(f,1);
%step_size = 10;

v = VideoWriter('test.avi');
open(v);
axis([min(xtraj)-100 max(xtraj)+100 min(ytraj)-100 max(ytraj)+100])
idx_prev=1;

for fx = [3:N]
    idx= find(p(:,1)==f{fx,12}); %idx of fixation in trajectory
    idx_2back= find(p(:,1)==f{fx-2,12}); %idx of fixation in trajectory

    h = scatter(xtraj(idx_prev:idx),ytraj(idx_prev:idx),'filled'); 
    h.SizeData = 60; 
    h.MarkerFaceAlpha= fix_ratio(fx);

    axis([min(xtraj)-100 max(xtraj)+100 min(ytraj)-100 max(ytraj)+100])
    idx=idx_prev;
    hold on;
    title(['Subject: ',subject,', ','Trial ',int2str(trial_num)])
    frame = getframe(gcf);
    writeVideo(v,frame)
end
close(v)




%%

v = VideoWriter('test.avi');
open(v);
axis([min(xtraj)-100 max(xtraj)+100 min(ytraj)-100 max(ytraj)+100])
idx_prev=1;

for fx = [3:N]
    idx= find(p(:,1)==f{fx,12}); %idx of fixation in trajectory
    idx_2back= find(p(:,1)==f{fx-2,12}); %idx of fixation in trajectory
    h1 = scatter(xtraj(idx_2back:idx),ytraj(idx_2back:idx),'filled'); 
    h1.SizeData = 60; 
    h1.MarkerFaceAlpha= fix_ratio(fx);

    axis([min(xtraj)-100 max(xtraj)+100 min(ytraj)-100 max(ytraj)+100])
    idx=idx_prev;
    %hold on;
    title(['Subject: ',subject,', ','Trial ',int2str(trial_num)])
    frame = getframe(gcf);
    writeVideo(v,frame)
end
close(v)