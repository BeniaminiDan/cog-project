addpath('S:\Lab-Shared\Experiments\N170 free scan\ClutteredObjects_scan')
elfile=['OdedCN.asc'];
[SAMPLES, triggers, FIXATIONS, SACCADES, BLINKS]=readEyelinkFast(elfile,'readEyes','lr');
SR=1000;

%% unite the eyes location - [X,Y]
trajectory=[mean(SAMPLES(:,[2,5]),2),mean(SAMPLES(:,[3,6]),2)];
%plot(trajectory(:,1),trajectory(:,2),'*')


%% make a new saccade matrix
SACC_mat = SACCADES{:,:};
% sacc= start, end, distance
start_sacc=min(SACC_mat(:,[1,10])');
end_sacc=min(SACC_mat(:,[1,10])');
deltaXR_sacc=abs(SACC_mat(:,4)-SACC_mat(:,6)); 
deltaXL_sacc=abs(SACC_mat(:,13)-SACC_mat(:,15));
deltaX_sacc=nanmean([deltaXR_sacc,deltaXL_sacc]');
deltaYR_sacc=abs(SACC_mat(:,5)-SACC_mat(:,7));
deltaYL_sacc=abs(SACC_mat(:,14)-SACC_mat(:,16));
deltaY_sacc=nanmean([deltaYR_sacc,deltaYL_sacc]');
distance=sqrt(deltaX_sacc.^2 +deltaY_sacc.^2); %pitagoras

sacc=[start_sacc;end_sacc;distance]';
 
%% %% make a new fixation matrix
FIX_mat = FIXATIONS{:,:};
% fix= start, end, duration
start_fix=min(FIX_mat(:,[1,6])');
end_fix=min(FIX_mat(:,[2,7])');
dur_fix=mean(FIX_mat(:,[3,8])');

fix=[start_fix;end_fix;dur_fix]';

%% make a list of events= saccade+following fixation

events= [sacc((1:length(sacc)-1),3),fix(2:length(sacc),3)];

%% plot results
figure
plot(log(events(:,1)),log(events(:,2)),'.')
xlabel('Saccade length')
ylabel('log(Fixation duration)')

ratio=[log(events(:,1))./log(events(:,2))];
hist(ratio) %histogram of the ratio
%% k-means

idx= kmeans(ratio,2)