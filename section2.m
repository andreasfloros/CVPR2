% ------------------------------------------
% --- Principal Component Analysis (PCA) ---
% ------------------------------------------

% TODO: display eigenvectors, 1d plotting, process electrode data

% load PVT data from the Data Preparation section
% load("F0_PVT.mat");

% the below code is mostly data preparation and should probably be moved to
% section1.m, feel free to move it over if you find it useful

object_names = ["acrylic_211_", "black_foam_110_", "car_sponge_101_", ...
                "flour_sack_410_", "kitchen_sponge_114_", "steel_vase_702_"];

% select a time step (this is randomly chosen, we need to experiment here)
t = 200;

% combine pvt data (3 x 60) = 6 * (3 x 10) where each 3 x 10 corresponds to
% all trials for a given object
pvt = [];
for object_name = object_names 
    for trial = 1 : 10
        load("PR_CW_DATA_2021\" + object_name + num2str(trial,'%02.f') + "_HOLD.mat");
        pvt = [pvt, [F0pdc(:, t); F0pac(2, t); F0tdc(:, t)]];
    end
end

% normalise the data (not sure if this is how we should be doing it)
pvt = normalize(pvt, 2);

% visualise data in three dimensions
object_colours = [1 0 0 ; 0 1 0 ; 0 0 1; 0 0 0; 0.9 0.9 0.5; 0.9 0.6 0.8];
colours = zeros(size(pvt))';
for object = 0 : 5
    for trial = 1 : 10
        colours(10 * object + trial, :) = object_colours(object + 1, :);
    end
end

figure;
scatter3(pvt(1, :), pvt(2, :), pvt(3, :), [], colours, "filled");

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