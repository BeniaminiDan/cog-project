%% K means calcs and plots

% trying to find the optimal K number
X_log = [log(grand_events(:,6)),log(grand_events(:,10))];

eva = evalclusters(X_log,'kmeans','DaviesBouldin','KList',1:4); % optimal 3
eva = evalclusters(X_log,'kmeans','CalinskiHarabasz','KList',1:6); % optimal 3
eva = evalclusters(X_log,'kmeans','silhouette'	,'KList',1:6); % optimal 3

% k means calc & plot
k = 3
X = [grand_events(:,6),grand_events(:,10)];
[idx,C]= kmeans(X_log,k); % returns the K cluster centroid locations in the K-by-P matrix C.
cgroup = ['b' 'r' 'g' 'k' 'y' 'm']

% plot linear data by color of clusters
figure;
subplot(1,2,1)
title('k means on linear data')
for i=1:k
    scatter(X(idx==i,1),X(idx==i,2),cgroup(i),'o','MarkerEdgeAlpha',0.2)
    xlabel('saccade length')
    ylabel('fixation duration')
    
    hold on
end
legend('1','2','3')

% plot log data by color of clusters
subplot(1,2,2)
for i=1:k
    scatter(X(idx==i,1),X(idx==i,2),cgroup(i),'o','MarkerEdgeAlpha',0.2)
    xlabel('saccade length')
    ylabel('fixation duration')
        set(gca, 'YScale', 'log')
    set(gca, 'XScale', 'log')

    hold on
end
X = [grand_events(:,6),grand_events(:,10)];

% setting the title
axes( 'Position', [0, 0.95, 1, 0.05] ) ;
 set( gca, 'Color', 'None', 'XColor', 'White', 'YColor', 'White' ) ;
 text( 0.5, 0, 'K means ', 'FontSize', 14', 'FontWeight', 'Bold', ...
      'HorizontalAlignment', 'Center', 'VerticalAlignment', 'Bottom' ) ;
