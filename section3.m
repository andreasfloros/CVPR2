% ------------------------------------------
% --- Linear Discriminant Analysis (LDA) ---
% ------------------------------------------

close all;

recommended_objects = ["black_foam_110_", "car_sponge_101_"];
more_objects = ["flour_sack_410_", "steel_vase_702_"];

do_lda(recommended_objects);
do_lda(more_objects);


% some helper functions
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

function do_lda(objects)

    object_colours = [1 0 0 ; 0 1 0];
    colours = zeros(3,20)';
    for object = 0 : 1
        for trial = 1 : 10
            colours(10 * object + trial, :) = object_colours(object + 1, :);
        end
    end
    
    ax_map = ["Pressure", "Vibration", "Temperature"];

    rdata = load_pvt_data(objects);
    
    % remove p, v and t axis and apply lda on the reduced data
    for ax = 1 : 3
        removed_row_dat = rdata;
        removed_row_dat(ax, :) = [];
        rlda_mat = get_lda_mat(removed_row_dat);
        [evects, evals] = eig(rlda_mat, "vector");
        
        % sort in descending order
        [evals, ind] = sort(evals, "descend");
        evects = evects(:, ind);

        % plots
        figure;
        scatter(removed_row_dat(1, :), removed_row_dat(2, :), [], colours, "filled");
        title("LDA by dropping " + ax_map(ax) + " Data.");
        hold on;
        xc = evects(1, 1);
        yc = -(evects(1, 1) .^ 2) / evects(2, 1);
        multiplier = 6 / sqrt(xc .^ 2 + yc .^ 2);
        line(multiplier * [- evects(1, 1); evects(1, 1)], ...
             multiplier * [(evects(1, 1) .^ 2) / evects(2, 1); -(evects(1, 1) .^ 2) / evects(2, 1)]);
    end

    % apply to all data
    rlda_mat = get_lda_mat(rdata);
    [evects, evals] = eig(rlda_mat, "vector");
    
    % sort in descending order
    [evals, ind] = sort(evals, "descend");
    evects = evects(:, ind);

    % plots
    figure;
    scatter3(rdata(1, :), rdata(2, :), rdata(3, :), [], colours, "filled");
    title("LDA on all of the data.");
    xlabel('Pressure');
    ylabel('Vibration');
    zlabel('Temperature');
    hold on;
    xc = 1;
    yc = 1;
    zc = (evects(1, 1) + evects(2, 1)) / evects(3, 1);
    multiplier = 6 / sqrt(xc .^ 2 + yc .^ 2 + zc.^2);
    line(multiplier * [- 1; 1; 0], ...
         multiplier * [-1; 1; 0], multiplier * [-zc; zc; 0]);
    xc = 1;
    yc = 1;
    zc = (evects(1, 2) + evects(2, 2)) / evects(3, 2);
    multiplier = 6 / sqrt(xc .^ 2 + yc .^ 2 + zc.^2);
    line(multiplier * [- 1; 1; 0], ...
         multiplier * [-1; 1; 0], multiplier * [-zc; zc; 0]);

end