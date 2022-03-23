% ------------------------
% --- Data Preparation ---
% ------------------------
close all;

% disable legend warnings
warning('off', 'MATLAB:handle_graphics:exceptions:SceneNode')

object_names = ["acrylic_211_", "black_foam_110_", "car_sponge_101_", ...
                "flour_sack_410_", "kitchen_sponge_114_", "steel_vase_702_"];
legend_obj_names = ["acrylic", "black foam", "car sponge", "flour sack", ...
                "kitchen sponge", "steel vase"];
object_colours = [1 0 0 ; 0 1 0 ; 0 0 1; 0 0 0; 0.9 0.9 0.5; 0.9 0.6 0.8];

% ---------------------------------
% --- 1. Choosing the Time Step ---
% ---------------------------------
% plot one sample of P, V, T
trial = 1;
figure;

% plot pressure
subplot(2,2,1);
obj_idx = 1;
for object_name = object_names
    load("PR_CW_DATA_2021\" + object_name + num2str(trial,'%02.f') + "_HOLD.mat");
    plot(F0pdc, 'Color', object_colours(obj_idx, :));
    hold on;
    obj_idx = obj_idx + 1;
end
hold off;
ylabel('Pressure');
xlabel('Time');

% plot temperature
subplot(2,2,2);
obj_idx = 1;
for object_name = object_names
    load("PR_CW_DATA_2021\" + object_name + num2str(trial,'%02.f') + "_HOLD.mat");
    plot(F0tdc, 'Color', object_colours(obj_idx, :));
    hold on;
    obj_idx = obj_idx + 1;
end
hold off;
ylabel('Temperature');
xlabel('Time');

% plot vibration
obj_idx = 1;
subplot(2,2,[3 4]);
for object_name = object_names
    load("PR_CW_DATA_2021\" + object_name + num2str(trial,'%02.f') + "_HOLD.mat");
    plot(F0pac(2,:), 'Color', object_colours(obj_idx, :));
    hold on;
    obj_idx = obj_idx + 1;
end
hold off;
ylabel('Vibration');
xlabel('Time');
legend(legend_obj_names, 'Location','southeast');

% combined plot for P,V,T for each object
for type = ["Pressure", "Vibration", "Temperature"]
    figure;
    sgtitle(type + " Combined Plot");
    for trial = 1 : 10
        subplot(3,4,trial);
        hold on;
        for object_name = object_names
            load("PR_CW_DATA_2021\" + object_name + num2str(trial,'%02.f') + "_HOLD.mat");
            
            % plot combined timeseries
            if type == "Pressure"
                plot(F0pdc);
            elseif type == "Vibration"
                plot(F0pac(2,:));
            else
                plot(F0tdc);
            end
        end
        hold off;
    end
    legend(legend_obj_names);
end

% from the combined plots, we can see that the vibration is only
% distinguishable at lower time values. We can try to zoom in:
figure;
sgtitle("Vibration Combined Plot - Zoomed In");
for trial = 1 : 10
    subplot(3,4,trial);
    hold on;
    for object_name = object_names
        load("PR_CW_DATA_2021\" + object_name + num2str(trial,'%02.f') + "_HOLD.mat");
        
        % plot combined timeseries
        plot(F0pac(2,1:100));
    end
    hold off;
end
legend(legend_obj_names);

% a timestep of 10 looks to perform quite well when distinguishing between
% the different objects
t = 10;

% ---------------------------------------------------
% --- 2. Plotting result at corresponding timestep --
% ---------------------------------------------------
f0_pvt = [];
f0_class = [];
obj_idx = 0;
for object_name = object_names 
    obj_idx = obj_idx + 1;
    for trial = 1 : 10
        load("PR_CW_DATA_2021\" + object_name + num2str(trial,'%02.f') + "_HOLD.mat");
        f0_pvt = [f0_pvt, [F0pdc(:, t); F0pac(2, t); F0tdc(:, t)]];
        f0_class = [f0_class, obj_idx];
    end
end

% normalise the data
f0_pvt = normalize(f0_pvt, 2);

% save resulting PVT data as a .mat file
save('F0_PVT.mat', "f0_pvt", "f0_class");

% repeat for electrode data
f0_electrode = [];
for object_name = object_names 
    for trial = 1 : 10
        load("PR_CW_DATA_2021\" + object_name + num2str(trial,'%02.f') + "_HOLD.mat");
        f0_electrode = [f0_electrode, F0Electrodes(:, t)];
    end
end

% normalise the data
f0_electrode = normalize(f0_electrode, 2);

% save resulting Electrode data as a .mat file
save('F0_Electrode.mat', "f0_electrode", "f0_class");

% ---------------------------------------------
% --- 3. Plot the resulting 3D scatter plot ---
% ---------------------------------------------
f0_pvt = load("F0_PVT.mat").f0_pvt;
f0_electrode = load("F0_Electrode.mat").f0_electrode;

% Comment: points seem to be well separated, except for two objects
% (acrylic and steel vase)
figure;
scatter3(f0_pvt(1, 1:10), f0_pvt(2, 1:10), f0_pvt(3, 1:10), [], object_colours(1, :), "filled");
hold on;
scatter3(f0_pvt(1, 11:20), f0_pvt(2, 11:20), f0_pvt(3, 11:20), [], object_colours(2, :), "filled");
scatter3(f0_pvt(1, 21:30), f0_pvt(2, 21:30), f0_pvt(3, 21:30), [], object_colours(3, :), "filled");
scatter3(f0_pvt(1, 31:40), f0_pvt(2, 31:40), f0_pvt(3, 31:40), [], object_colours(4, :), "filled");
scatter3(f0_pvt(1, 41:50), f0_pvt(2, 41:50), f0_pvt(3, 41:50), [], object_colours(5, :), "filled");
scatter3(f0_pvt(1, 51:60), f0_pvt(2, 51:60), f0_pvt(3, 51:60), [], object_colours(6, :), "filled");
hold off;
legend(legend_obj_names);

xlabel('Pressure');
ylabel('Vibration');
zlabel('Temperature');
