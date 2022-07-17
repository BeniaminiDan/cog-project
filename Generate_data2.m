% Open Data and generate matrices of eye position, fixations and saccades

clear all
% get the data
cd('S:\Lab-Shared\Experiments\N170 free scan\ClutteredObjects_scan\Analysis')
load('OdedCN_info.mat')

%% parameters
num_of_trials=size(SDATA.trial_info,1);
subject=SDATA.GeneralInfo.Name;

%% Extract eye movements matrix

for trial=1:num_of_trials
    EyeMovements= cell2mat(SDATA.EyeInfo.TrialEyeMovements(trial));
    trajectories{:,trial}=[EyeMovements(:,1),nanmean(EyeMovements(:,[2,5]),2),nanmean(EyeMovements(:,[3,6]),2),nanmean(EyeMovements(:,[4,7]),2),EyeMovements(:,8)];
    % trajectory is [sample; X pos; Y pos; pupil area; blink mask]
    
    fix=SDATA.EyeInfo.TrialFixations{trial, 1};
    %remove the lines that are triggers
    idx=find(fix{:,10}<100); % if dur is 0=trigger
    fix([idx],:)=[]; %remove triggers
    events{:,trial}=fix;
end

%% Grand events matrix (all events, not by trial)
grand_events=[];
for trial=1:num_of_trials
    grand_events= [grand_events;events{:,trial}];
end

%% plot relation between saccades & fixations

%i think log-log is the most interesting 

figure
scatter(log(grand_events{:,6}),log(grand_events{:,10}),'o','MarkerEdgeAlpha',0.2)
xlabel('log (Saccade length)')
ylabel('log(Fixation duration)')

figure
scatter((grand_events{:,6}),(grand_events{:,10}),'o','MarkerEdgeAlpha',0.2)
xlabel('Saccade length')
ylabel('(Fixation duration)')

figure
scatter((grand_events{:,6}),log(grand_events{:,10}),'o','MarkerEdgeAlpha',0.2)
xlabel('Saccade length')
ylabel('log(Fixation duration)')


ratio=[(grand_events{:,6})./(grand_events{:,10})];
hist(ratio,200) %histogram of the ratio

figure
scatter(log(grand_events{1:200,10}),log(grand_events{1:200,6}),10,grand_events{1:200,1},'filled')
c = colorbar;

zlabel('')
xlabel('Saccade length')
ylabel('(Fixation duration)')

plot(700:900,ratio(700:900),'-*')