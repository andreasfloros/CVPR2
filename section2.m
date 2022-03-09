% ------------------------------------------
% --- Principal Component Analysis (PCA) ---
% ------------------------------------------

% TODO: display eigenvectors, 1d plotting, process electrode data

% load PVT data from the Data Preparation section
% load("F0_PVT.mat");

% ------------------------------------------------------------------------------------
% do PCA
% covariance matrix and eigen decomposition
pvt_cov = cov(pvt');
[pvtvectors, pvtvalues] = eig(pvt_cov, "vector");

% sort in descending order
[pvtvalues, ind] = sort(pvtvalues, "descend");
pvtvectors = pvtvectors(:, ind);

% keep two largest eigenvectors
features = pvtvectors(:, 1 : 2);

% project to two dimensions
projectedpvt = features' * pvt;

% visualise data in two dimensions

figure;
scatter(projectedpvt(1, :), projectedpvt(2, :), [], colours, "filled");