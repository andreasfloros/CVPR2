% ------------------------------------------
% --- Linear Discriminant Analysis (LDA) ---
% ------------------------------------------

close all;

% TODO: part a (just drop one variable)

recommended_objects = ["black_foam_110_", "car_sponge_101_"];
more_objects = ["flour_sack_410_", "steel_vase_702_"];

rdata = load_pvt_data(recommended_objects);
rlda_mat = get_lda_mat(rdata);

[evects, evals] = eig(rlda_mat, "vector");

% sort in descending order
[evals, ind] = sort(evals, "descend");
evects = evects(:, ind);

% generate the plots here


% some helper functions so we don't reuse the same code
function pvt = load_pvt_data(object_names)
    t = 10;
    pvt = [];
    for object_name = object_names
        for trial = 1 : 10
            load("PR_CW_DATA_2021\" + object_name + num2str(trial,'%02.f') + "_HOLD.mat");
            pvt = [pvt, [F0pdc(:, t); F0pac(2, t); F0tdc(:, t)]];
        end
    end
    pvt = normalize(pvt, 2);
end

function lda_mat = get_lda_mat(data)
    sb = get_bscatter_matrix(data);
    sw = get_wscatter_matrix(data);
    lda_mat = sw \ sb;
end

% LDA functions (assuming 10 trials)

function within_scat_mat = get_wscatter_matrix(data)
    within_scat_mat = 0;
    [~, num_cols] = size(data);
    for obj_idx = 1 : num_cols / 10
        cur = data(:, (obj_idx - 1) * 10 + 1: obj_idx * 10);
        cur = cur - mean(cur, 2);
        cur = cur * cur';
        within_scat_mat = within_scat_mat + cur;
    end
end

% this one is specific to 2 classes
function between_scat_mat = get_bscatter_matrix(data)
    obj1_mean = mean(data(:, 1: 10), 2);
    obj2_mean = mean(data(:, 11: 20), 2);
    between_scat_mat = obj1_mean - obj2_mean;
    between_scat_mat = between_scat_mat * between_scat_mat';
end