% ------------------------
% --- Data Preparation ---
% ------------------------
close all;

object_names = ["acrylic_211_", "black_foam_110_", "car_sponge_101_", ...
                "flour_sack_410_", "kitchen_sponge_114_", "steel_vase_702_"];

% 1. Choosing the Time Step
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

% 2. Plotting result at timestep t = 10
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
xlabel('Pressure');
ylabel('Vibration');
zlabel('Temperature');

% points seem to be well separated, except for two objects (red and pink)