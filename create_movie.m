% % Z = peaks;
% % surf(Z)
% h = animatedline;
% axis tight manual
% ax = gca;
% ax.NextPlot = 'add';
% 
% xfixtot = SDATA.EyeInfo.fixations(:,4);
% yfixtot = SDATA.EyeInfo.fixations(:,5);
% 
% xfix = xfixtot(1:2000,:);
% xfix = xfix{:,:};
% 
% yfix = yfixtot(1:2000,:);
% yfix = yfix{:,:};
% trajectories{:,trial}=[EyeMovements(:,1),nanmean(EyeMovements(:,[2,5]),2),nanmean(EyeMovements(:,[3,6]),2),nanmean(EyeMovements(:,[4,7]),2),EyeMovements(:,8)];
% % trajectory is [sample; X pos; Y pos; pupil area; blink mask]

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

