% Open Data and generate matrices of eye position, fixations and saccades

clear all
% get the data
cd('S:\Lab-Shared\Experiments\N170 free scan\ClutteredObjects_scan\Analysis')
load('S101_info.mat')

% parameters
num_of_trials=size(SDATA.trial_info,1);
% num_of_trials=size(1,1);
subject=SDATA.GeneralInfo.Name;

% Extract eye movements matrix

for trial=1:num_of_trials
    EyeMovements= cell2mat(SDATA.EyeInfo.TrialEyeMovements(trial));
    trajectories{:,trial}=[EyeMovements(:,1),nanmean(EyeMovements(:,[2,5]),2),nanmean(EyeMovements(:,[3,6]),2),nanmean(EyeMovements(:,[4,7]),2),EyeMovements(:,8)];
    % trajectory is [sample; X pos; Y pos; pupil area; blink mask]
    
    fix=SDATA.EyeInfo.TrialFixations{trial, 1};
    fix=fix{:,:};
    %remove the lines that are triggers
%     idx=find(~fix{:,3}); % if dur is 0=trigger
    idx = find(fix(:,10)<10); % if dur is 0=trigger
    fix([idx],:)=[]; %remove triggers
    events{:,trial}=fix;


end



% add to each event a colum that states which trail number its from
for event_num=1:length(events)
    events{event_num} = [events{event_num},ones(length(events{event_num}),1).*event_num];
end

% Grand events matrix (all events, not by trial)
    grand_events=[];
    for trial=1:num_of_trials
        grand_events= [grand_events;events{:,trial}];
    end

    