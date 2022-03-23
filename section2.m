% ------------------------------------------
% --- Principal Component Analysis (PCA) ---
% ------------------------------------------
close all;

% load PVT data from the Data Preparation section
pvt = load("F0_PVT.mat").f0_pvt;

object_colours = [1 0 0 ; 0 1 0 ; 0 0 1; 0 0 0; 0.9 0.9 0.5; 0.9 0.6 0.8];
colours = zeros(size(pvt))';

for object = 0 : 5
    for trial = 1 : 10
        colours(10 * object + trial, :) = object_colours(object + 1, :);
    end
end

% ---------------------------------------
% --- 1. Principal Component Analysis ---
% ---------------------------------------
% covariance matrix and eigen decomposition
pvt_cov = cov(pvt');

[pvtvectors, pvtvalues] = eig(pvt_cov, "vector");

% sort in descending order
[pvtvalues, ind] = sort(pvtvalues, "descend");
pvtvectors = pvtvectors(:, ind);

% visualise data with eigenvectors
figure;
scatter3(pvt(1, :), pvt(2, :), pvt(3, :), [], colours, "filled");
hold on;
for i = 1 : 3
    line([0; pvtvalues(i) * pvtvectors(1, i)], [0; pvtvalues(i) * pvtvectors(2, i)], [0; pvtvalues(i) * pvtvectors(3, i)]);
end
title("PVT Data with Eigenvectors");
xlabel('Pressure');
ylabel('Vibration');
zlabel('Temperature');

% keep two largest eigenvectors
features = pvtvectors(:, 1 : 2);

% project to two dimensions
projectedpvt = features' * pvt;

% visualise data in two dimensions
figure;
scatter(projectedpvt(1, :), projectedpvt(2, :), [], colours, "filled");
title('PVT Data Projected in 2D Space');
ylabel('Principal Component Direction');
xlabel('Principal Component Direction');

% 1d plots
for i = 1 : 3
    projto1d = pvtvectors(:, i);
    projected_data = projto1d' * pvt;
    figure;
    scatter(projected_data, 0, [], colours, "filled");
    title("Projection using Principal Component " + i);
    set(gca,'ytick', [])
end


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
figure;
scatter3(projectedelec(1, :), projectedelec(2, :), projectedelec(3, :), [], colours, "filled");
title('Electrode Data Projected in 3D Space');
xlabel('Principal Component Direction');
ylabel('Principal Component Direction');
zlabel('Principal Component Direction');


% save resulting PCA for electrode
save('F0_Electrode_PCA.mat', "projectedelec", "f0_class");

