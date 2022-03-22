% ------------------------------
% --- Clustering and Bagging ---
% ------------------------------
close all;

% -----------------------------
% --- 1. K-means Clustering ---
% -----------------------------
pvt = load("F0_PVT.mat").f0_pvt;

% there are k = 6 objects, so we can use k-means to cluster into 6 clusters
k = 6;
cluster_idx = kmeans(pvt', k);

% determine point colours after clustering
object_colours = [1 0 0 ; 0 1 0 ; 0 0 1; 0 0 0; 0.9 0.9 0.5; 0.9 0.6 0.8];
true_colours = zeros(size(pvt))';
for object = 0 : 5
    for trial = 1 : 10
        true_colours(10 * object + trial, :) = object_colours(object + 1, :);
    end
end

cluster_colours = zeros(size(pvt))';
for i = 1:length(cluster_colours)
    cluster_colours(i, :) = object_colours(cluster_idx(i), :);
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
scatter3(pvt(1, :), pvt(2, :), pvt(3, :), [], true_colours, "filled");
title('True Classes')
xlabel('Pressure');
ylabel('Vibration');
zlabel('Temperature');

% Comment: clustering does not correspond too well with the real classes
% we can experiment with different distance metrics
dist_metrics = ["sqeuclidean", "cityblock", "cosine", "correlation"];

% experiment with different distance metrics
for dist_metric = dist_metrics
    cluster_idx = kmeans(pvt', k, "Distance", dist_metric);

    cluster_colours = zeros(size(pvt))';
    for i = 1:length(cluster_colours)
        cluster_colours(i, :) = object_colours(cluster_idx(i), :);
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
    scatter3(pvt(1, :), pvt(2, :), pvt(3, :), [], true_colours, "filled");
    title('True Classes')
    xlabel('Pressure');
    ylabel('Vibration');
    zlabel('Temperature');
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

Mdl = TreeBagger(b, X, Y, 'Method','classification');
% view(Mdl.Trees{1},'Mode','graph');
% view(Mdl.Trees{2},'Mode','graph');

% c: run algorithm on test data and construct confusion matrix
predY = convertCharsToStrings(predict(Mdl, testX));
testY = compose("%i", testY);

figure;
cm = confusionchart(testY,predY);
% Comment: prediction is 100% accurate

% d: discuss misclassifications