% ------------------------------
% --- Clustering and Bagging ---
% ------------------------------
close all;
rng(3);

% -----------------------------
% --- 1. K-means Clustering ---
% -----------------------------
pvt = load("F0_PVT.mat").f0_pvt;

% elbow plot to determine number of clusters k
k_list = 1:12;
wcss_list = [];
for k = k_list
    [idx, C, sumd] = kmeans(pvt', k);
    wcss = 0;
    for cur_idx = 1:length(idx)
        cluster_idx = idx(cur_idx);
        wcss = wcss + sumd(cluster_idx);
    end
    wcss = wcss / length(idx);
    wcss_list = [wcss_list wcss];
end
figure;
plot(k_list, wcss_list);
xlabel('K');
ylabel('Within Cluster Sum-of-Square Distance');

% choose k = 6
k = 6;
cluster_idx = kmeans(pvt', k);

% determine point colours after clustering
object_colours = [1 0 0 ; 0 1 0 ; 0 0 1; 0 0 0; 0.9 0.9 0.5; 0.9 0.6 0.8];
rand_colours = [0.2 0.5 0.5; 0 0.7 0; 0.2 0 0.8; 0.7 0.9 0.9; 0.1 0.3 0.7; 0.1 0.1 0.1];
cluster_colours = zeros(size(pvt))';
for i = 1:length(cluster_colours)
    cluster_colours(i, :) = rand_colours(cluster_idx(i), :);
end

% plot result and compare with true classes
figure;
subplot(1,2,1);
scatter3(pvt(1, :), pvt(2, :), pvt(3, :), [], cluster_colours, "filled");
title('K-means Clustering')
xlabel('Pressure');
ylabel('Vibration');
zlabel('Temperature');
subplot(1,2,2);
true_plot(pvt, object_colours);

% Comment: clustering does not correspond too well with the real classes
% we can experiment with different distance metrics
dist_metrics = ["sqeuclidean", "cityblock", "cosine", "correlation"];

% experiment with different distance metrics
for dist_metric = dist_metrics
    cluster_idx = kmeans(pvt', k, "Distance", dist_metric);

    cluster_colours = zeros(size(pvt))';
    for i = 1:length(cluster_colours)
        cluster_colours(i, :) = rand_colours(cluster_idx(i), :);
    end
    
    % plot result and compare with true classes
    figure;
    subplot(1,2,1);
    scatter3(pvt(1, :), pvt(2, :), pvt(3, :), [], cluster_colours, "filled");
    title(['K-means Clustering - ' dist_metric]);
    xlabel('Pressure');
    ylabel('Vibration');
    zlabel('Temperature');
    subplot(1,2,2);
    true_plot(pvt, object_colours);
end

% Comment: in general, the data is not separated well enough to use
% k-means clustering, so no distance metric may solve the inaccuracy (maybe
% try use other clustering algorithms). 


% ------------------------------------
% --- 2. Bagging on Electrode Data ---
% ------------------------------------
rng(1);
X = load("F0_Electrode_PCA.mat").projectedelec';
Y = load("F0_Electrode_PCA.mat").f0_class';

% split to training and test set
cv = cvpartition(size(X,1),'HoldOut',0.4);
idx = cv.test;
trainX = X(~idx,:);
testX  = X(idx,:);
trainY = Y(~idx,:);
testY = Y(idx,:);

% a: choose number of bags -> can check through OOB visualization
oob_list = [];
b_list = 1:2:50;
for b = b_list
    % create treebagger
    Mdl = TreeBagger(b, X, Y, 'Method','classification', 'OOBPrediction', 'on');

    % compute out of bag error
    ooberr = oobError(Mdl, 'Mode', 'ensemble');
    
    % append to list of OOB error
    oob_list = [oob_list, ooberr];
end

% plot OOB error vs. number of trees
figure;
plot(b_list, oob_list);
xlabel('Trees Grown');
ylabel('Out-of-Bag Error');

% b: run algorithm and visualize two decision trees
% from part a, 25 bags seems to give low OOB error - performance does not
% improve much more after b = 25.
b = 25;

Mdl = TreeBagger(b, trainX, trainY, 'Method','classification');
view(Mdl.Trees{1},'Mode','graph');
view(Mdl.Trees{2},'Mode','graph');

% c: run algorithm on test data and construct confusion matrix
predY = convertCharsToStrings(predict(Mdl, testX));
testY = compose("%i", testY);

figure;
cm = confusionchart(testY,predY);

% d: discuss misclassifications


% Helper Function
function true_plot(pvt, object_colours)
    % define the object names
    legend_obj_names = ["acrylic", "black foam", "car sponge", "flour sack", ...
                "kitchen sponge", "steel vase"];

    % plot figure
    scatter3(pvt(1, 1:10), pvt(2, 1:10), pvt(3, 1:10), [], object_colours(1, :), "filled");
    hold on;
    scatter3(pvt(1, 11:20), pvt(2, 11:20), pvt(3, 11:20), [], object_colours(2, :), "filled");
    scatter3(pvt(1, 21:30), pvt(2, 21:30), pvt(3, 21:30), [], object_colours(3, :), "filled");
    scatter3(pvt(1, 31:40), pvt(2, 31:40), pvt(3, 31:40), [], object_colours(4, :), "filled");
    scatter3(pvt(1, 41:50), pvt(2, 41:50), pvt(3, 41:50), [], object_colours(5, :), "filled");
    scatter3(pvt(1, 51:60), pvt(2, 51:60), pvt(3, 51:60), [], object_colours(6, :), "filled");
    hold off;
    title('True Classes');
    xlabel('Pressure');
    ylabel('Vibration');
    zlabel('Temperature');
    legend(legend_obj_names, 'Location', 'best');
end