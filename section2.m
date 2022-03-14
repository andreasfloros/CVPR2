% ------------------------------------------
% --- Principal Component Analysis (PCA) ---
% ------------------------------------------
close all;

% TODO: display eigenvectors, 1d plotting, process electrode data

% load PVT data from the Data Preparation section
pvt = load("F0_PVT.mat").f0_pvt;

% ---------------------------------------
% --- 1. Principal Component Analysis ---
% ---------------------------------------
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


% -----------------------------------------------
% --- 2. PCA and Scree Plot on Electrode Data ---
% -----------------------------------------------
elec = load("F0_Electrode.mat").f0_electrode;
f0_class = load("F0_Electrode.mat").f0_class;

% covariance matrix and eigen decomposition
elec_cov = cov(elec');
[elecvectors, elecvalues] = eig(elec_cov, "vector");

% sort in descending order
[elecvalues, ind] = sort(elecvalues, "descend");
elecvectors = elecvectors(:, ind);

% scree plot
figure;
plot(elecvalues, '-o');
title('Scree Plot');
ylabel('Eigenvalue');
xlabel('Principal Components');
xlim([1 20]);

% from the scree plot, we can see that 3 principal components already take
% into account nearly 100% of the observed variance, thus we can use 3
% principal components.
features = elecvectors(:, 1:3);

% project to three dimensions
projectedelec = features' * elec;

% visualise data in three dimensions
object_colours = [1 0 0 ; 0 1 0 ; 0 0 1; 0 0 0; 0.9 0.9 0.5; 0.9 0.6 0.8];
colours = zeros(size(pvt))';
for object = 0 : 5
    for trial = 1 : 10
        colours(10 * object + trial, :) = object_colours(object + 1, :);
    end
end

figure;
scatter3(projectedelec(1, :), projectedelec(2, :), projectedelec(3, :), [], colours, "filled");

% save resulting PCA for electrode
save('F0_Electrode_PCA.mat', "projectedelec", "f0_class");

