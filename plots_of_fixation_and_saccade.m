%% plot by trial
for trail_num=1:num_of_trials
    subplot(3,3,trail_num)
    cur_event = events{trail_num};
    x = cur_event(:,6); % Saccade length
    y = cur_event(:,10); % fixation duration
    z = 1:length(y);
    scatter(z,x./y,'o','MarkerEdgeAlpha',0.2)
    set(gca, 'YScale', 'log')
    ylim([min(grand_events(:,6)./grand_events(:,10)) max(grand_events(:,6)./grand_events(:,10))])
    if trail_num==4
        ylabel('Saccade length / Fixation duration [@ log scale]')
    end
    if trail_num==8
        xlabel('sequence #')
    end
    title(strcat('trail #',num2str(trail_num)))
end
axes( 'Position', [0, 0.95, 1, 0.05] ) ;
 set( gca, 'Color', 'None', 'XColor', 'White', 'YColor', 'White' ) ;
 text( 0.5, 0, 'ratio vs time sequence', 'FontSize', 14', 'FontWeight', 'Bold', ...
      'HorizontalAlignment', 'Center', 'VerticalAlignment', 'Bottom' ) ;

    %% by trail -- fixation and saccde
for trail_num=1:num_of_trials
    subplot(3,3,trail_num)
    cur_event = events{trail_num};
%     scatter(cur_event(:,6),cur_event(:,10),'o','MarkerEdgeAlpha',0.2) 
    x = cur_event(:,6); % Saccade length
    y = cur_event(:,10); % fixation duration
    z = 1:length(y);
    scatter3(x,y,z,8,z,'filled','o','MarkerEdgeAlpha',0.2);
    view(2)
    set(gca, 'YScale', 'log')
    set(gca, 'XScale', 'log')

    ylim([min(grand_events(:,10)) max(grand_events(:,10))])
    xlim([min(grand_events(:,6)) max(grand_events(:,6))])

    if trail_num==4
        ylabel('Fixation duration [log scale]','fontweight','bold','fontsize',12)
    end
    if trail_num==8
        xlabel('saccade length [log scale]','fontweight','bold','fontsize',12)
    end
    title(strcat('trail #',num2str(trail_num)))
end
axes( 'Position', [0, 0.95, 1, 0.05] ) ;
 set( gca, 'Color', 'None', 'XColor', 'White', 'YColor', 'White' ) ;
 text( 0.5, 0, 'Fixation duration vs saccade length @ log scale', 'FontSize', 14', 'FontWeight', 'Bold', ...
      'HorizontalAlignment', 'Center', 'VerticalAlignment', 'Bottom' ) ;
 b = colorbar;
  b.Label.String = 'sequance #'
 b.Location = [0.938020833333333,0.067405355493998,0.025781249883584,0.860572483841181];

%% plot relation between saccades & fixations

figure
subplot(1,2,1)
scatter(grand_events(:,6),grand_events(:,10),'o','MarkerEdgeAlpha',0.2)
xlabel(' Saccade length')
ylabel('Fixation duration')

subplot(1,2,2)
scatter(grand_events(:,6),grand_events(:,10),'o','MarkerEdgeAlpha',0.2)
xlabel(' Saccade length')
ylabel('Fixation duration')
set(gca, 'YScale', 'log')
set(gca, 'XScale', 'log')



