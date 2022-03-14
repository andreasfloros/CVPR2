% ------------------------
% --- Data Preparation ---
% ------------------------
close all;

object_names = ["acrylic_211_", "black_foam_110_", "car_sponge_101_", ...
                "flour_sack_410_", "kitchen_sponge_114_", "steel_vase_702_"];

% ---------------------------------
% --- 1. Choosing the Time Step ---
% ---------------------------------
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
    legend(object_names);
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
legend(object_names);

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

object_colours = [1 0 0 ; 0 1 0 ; 0 0 1; 0 0 0; 0.9 0.9 0.5; 0.9 0.6 0.8];
colours = zeros(size(f0_pvt))';
for object = 0 : 5
    for trial = 1 : 10
        colours(10 * object + trial, :) = object_colours(object + 1, :);
    end
end

% Comment: points seem to be well separated, except for two objects (red and pink)
figure;
scatter3(f0_pvt(1, :), f0_pvt(2, :), f0_pvt(3, :), [], colours, "filled");
xlabel('Pressure');
ylabel('Vibration');
zlabel('Temperature');
