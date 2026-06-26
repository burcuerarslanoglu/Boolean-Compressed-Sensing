clear all;
clc;
%% Initialization
p_values = 0.02:0.02:0.16; % Pooling probabilities from 2% to 16%
M_values = 20:20:300; % Number of measurements from 20 to 300
epsilon = 0.01; % epsilon for stopping criteria

% Load the dataset
data = load('GroupTesting.mat');
x_samples = data.x;
sample_size = size(x_samples, 1);
%sample_size = 100;

% Initialize the array to store the Hamming distances and computing times
hamming_distances = zeros(length(p_values), length(M_values), sample_size);
computing_times = zeros(length(p_values), length(M_values));
false_positives = zeros(length(p_values), length(M_values), sample_size);
false_negatives = zeros(length(p_values), length(M_values), sample_size);

% Noisy Measurements -> Not used
% Noisy = false;   
% p_noise = 0.05;

%% RUN
% Loop over each sample in the dataset
for sample_idx = 1:sample_size
    x_true = (x_samples(sample_idx, :))';
    disp(sample_idx)
    for p_idx = 1:length(p_values)
        for M_idx = 1:length(M_values)
            % Current p and M values
            p = p_values(p_idx);
            M = M_values(M_idx);

            % Generate the measurement matrix A
            A = double(rand(M, length(x_true)) < p);

            % Generate the measurements y based on A and x_true
            y = double(any(A & x_true', 2));
            
            % Make measurment noisy -> Not used
%             if Noisy
%                 noise = double(rand(length(y)) < p_noise);
%                 y = rem((y + noise),2);
%             end

            % Start timing
            tic;

            % Implement a group testing algorithm to estimate x from A and y
             x_estimate = DD(A,y); % The same as COMP tho
            % x_estimate = COMP(A, y);
            % x_estimate = MP(A, y, epsilon);
            % x_estimate = double(MP(A,y,epsilon) >= 1);
            
            % Stop timing and record the computing time
            computing_time = toc;

            % Accumulate the TP, TN, FP & FN
            TP = sum((x_true == 1) & (x_estimate == 1));
            TN = sum((x_true == 0) & (x_estimate == 0));
            FP = sum((x_true == 0) & (x_estimate == 1));
            FN = sum((x_true == 1) & (x_estimate == 0));

            false_positives(p_idx, M_idx, sample_idx) = FP / (FP + TN);
            false_negatives(p_idx, M_idx, sample_idx) = FN / (FN + TP);

            % Accumulate the computing time
            computing_times(p_idx, M_idx) = computing_times(p_idx, M_idx) + computing_time;
            % Calculate the Hamming distance between the true state and the estimate
            hamming_distances(p_idx, M_idx, sample_idx) = sum(abs(x_true - x_estimate));
        end
    end
end
%% Plot necessities
mean_hamming_distances = squeeze(mean(hamming_distances, 3));
mean_computing_times = squeeze(mean(computing_times, 3));
average_fpr = squeeze(mean(false_positives, 3));
average_fnr = squeeze(mean(false_negatives, 3));

% Generate a color map to differentiate the lines for each p_value
colors = jet(length(p_values));

%% Plot
figure;
hold on; 

% Plot a line for each p_value
for p_idx = 1:length(p_values)
    plot(M_values, mean_hamming_distances(p_idx, :), 'Color', colors(p_idx, :), 'LineWidth', 1);
end

title('Hamming Distance vs. Number of Measurements');
xlabel('Number of Measurements (M)');
ylabel('Mean Hamming Distance');
legend(arrayfun(@(p) sprintf('p = %.2f', p), p_values, 'UniformOutput', false), 'Location', 'northeast');
xlim([M_values(1) M_values(end)])
% ylim([0 10])
grid on;
hold off; 

% 3D plot
mean_hamming_distances = squeeze(mean(hamming_distances, 3));
figure; % Creates a new figure for the computing times
surf(M_values, p_values, mean_hamming_distances);
xlabel('Number of Measurements (M)');
ylabel('Pooling Probability (p)');
zlabel('Mean Hamming Distance');
title('Hamming Distance for Various p and M');
view(37.5, 20);

%% Plot average computing times
figure;
hold on; 

% Plot a line for each p_value
for p_idx = 1:length(p_values)
    plot(M_values, mean_computing_times(p_idx, :), 'Color', colors(p_idx, :), 'LineWidth', 1);
end

title('Computing Time vs. Number of Measurements');
xlabel('Number of Measurements (M)');
ylabel('Mean Computing Time');
legend(arrayfun(@(p) sprintf('p = %.2f', p), p_values, 'UniformOutput', false), 'Location', 'northwest');
xlim([M_values(1) M_values(end)])
grid on;
hold off; % Release the figure hold

% 3D plot
figure; % Creates a new figure for the computing times
surf(M_values, p_values, mean_computing_times);
xlabel('Number of Measurements (M)');
ylabel('Pooling Probability (p)');
zlabel('Mean Computing Time (seconds)');
title('Computing Time for Various p and M');
view(330, 20);


%% Plot FPR and FNR

figure;
hold on; 

% Plot a line for each p_value
for p_idx = 1:length(p_values)
    plot(M_values, average_fnr(p_idx, :), 'Color', colors(p_idx, :), 'LineWidth', 1);
end

title('False Negative Rate vs. Number of Measurements');
xlabel('Number of Measurements (M)');
ylabel('Mean False Negative Rate');
legend(arrayfun(@(p) sprintf('p = %.2f', p), p_values, 'UniformOutput', false), 'Location', 'northeast');
xlim([M_values(1) M_values(end)])
grid on;
hold off; 

figure;
hold on; % Hold on to the current figure to plot multiple lines

% Plot a line for each p_value
for p_idx = 1:length(p_values)
    plot(M_values, average_fpr(p_idx, :), 'Color', colors(p_idx, :), 'LineWidth', 1);
end

% Adding graph details
title('False Positive Rate vs. Number of Measurements');
xlabel('Number of Measurements (M)');
ylabel('Mean Positive Negative Rate');
legend(arrayfun(@(p) sprintf('p = %.2f', p), p_values, 'UniformOutput', false), 'Location', 'northeast');
xlim([M_values(1) M_values(end)])
grid on;
hold off; % Release the figure hold


% 3d plot
figure; % New figure for FPR
surf(M_values, p_values, average_fpr);
xlabel('Number of Measurements (M)');
ylabel('Pooling Probability (p)');
zlabel('Mean False Positive Rate');
title('False Positive Rate for Various p and M');
view(37.5, 20);

figure; % New figure for FNR
surf(M_values, p_values, average_fnr);
xlabel('Number of Measurements (M)');
ylabel('Pooling Probability (p)');
zlabel('Mean False Negative Rate');
title('False Negative Rate for Various p and M');
view(37.5, 20);