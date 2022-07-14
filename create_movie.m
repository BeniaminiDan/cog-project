

xfixtot = SDATA.EyeInfo.fixations(:,4);
yfixtot = SDATA.EyeInfo.fixations(:,5);

xfixtot = xfixtot{:,:};
yfixtot = yfixtot{:,:};

p=trajectories{1, 1};
xfixtot = p(:,3);
yfixtot = p(:,2);


N=size(xfixtot);
step_size = 10;
total_steps = N/step_size;

xfix = xfixtot(1:N,:);
yfix = yfixtot(1:N,:);

%axis tight manual
v = VideoWriter('test.avi');
open(v);
xlim([0 2000])
ylim([0 2000])
% plot()
for j = 1:total_steps
%     X = sin(j*pi/10)*Z;
%     surf(X,Z)
    try
        plot(xfix(j:j+step_size)',yfix(j:j+step_size)','k');
    end
    hold on;
    frame = getframe(gcf);
    writeVideo(v,frame)
end

close(v)

%% updated

trial_num =2; 
subject= '101';

p=trajectories{1, trial_num};
xtraj = p(:,3);
ytraj = p(:,2);

N=length(xtraj);
step_size = 100;

v = VideoWriter('test.avi');
open(v);
axis([min(xtraj)-100 max(xtraj)+100 min(yfix)-100 max(yfix)+100])

for j = [1:step_size:N]
    plot(xtraj(j:j+step_size-1),yfix(j:j+step_size-1),'k');
    hold on;
    title(['Subject: ',subject,', ','Trial ',int2str(trial_num)])
    frame = getframe(gcf);
    writeVideo(v,frame)
end
close(v)