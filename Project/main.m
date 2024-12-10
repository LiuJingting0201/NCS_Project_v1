clear; clc; close all;

% Initialize parameters
params = [0.57,    % alpha: Transmission rate from infected (I) to susceptible (S)
          0.0114,  % beta: Transmission rate from diagnosed (D) to susceptible (S)
          0.456,   % gamma: Transmission rate from symptomatic (A) to susceptible (S)
          0.0114,  % delta: Transmission rate from recovered (R) to susceptible (S)
          0.171,   % epsilon: Transition rate from infected (I) to diagnosed (D)
          0.1254,  % theta: Transition rate from infected (I) to symptomatic (A)
          0.1254,  % zeta: Transition rate from diagnosed (D) to recovered (R)
          0.0171,  % eta: Transition rate from symptomatic (A) to recovered (R)
          0.0274,  % mu: Transition rate from symptomatic (A) to critical (T)
          0.0342,  % nu: Transition rate from recovered (R) back to critical (T)
          0.0342,  % tau: Transition rate from diagnosed (D) to deceased (E)
          0.01,    % kappa: Transition rate from critical (T) to deceased (E)
          0.0171]; % sigma: Transition rate from critical (T) to recovered (H)

% Initial state
y0 = [0.99, 0.01, 0, 0, 0, 0, 0, 0, 0]; % Initial values for S, I, D, A, R, T, H, E, U

%% Weight coefficients
w1 = 0.4; % Weight for minimizing deaths
w2 = 0.5; % Weight for minimizing social unrest
w3 = 0.1; % Weight for minimizing healthcare overload
w4 = 0.05; % Weight for minimizing infection peaks

% Define time segmentation
tspan = 0:10:200;


% Simulation with Default Lockdown Intensity
disp('Simulation with Default Lockdown Intensity');
default_L = 0.5; % Default lockdown intensity
[T_default, Y_default] = ode45(@(t, y) sidarthe_extended(t, y, params, default_L, ...
                           0.05, 0.1, 0.2, 0.6, 0.03, 1.2, 2), ...
                           [tspan(1), tspan(end)], y0);

% Optimized Lockdown Strategy
disp('Optimizing Lockdown Strategy');
L_opt = optimize_lockdown(params, y0, w1, w2, w3, w4, tspan);
disp('Optimized Lockdown Strategy:');
disp(L_opt);



%% Simulation with Optimized Lockdown
% Simulation with Optimized Lockdown Intensity
T_opt = []; Y_opt = [];
y_current = y0;
for i = 1:length(L_opt)
    [Ti, Yi] = ode45(@(t, y) sidarthe_extended(t, y, params, L_opt(i), ...
                           0.05, 0.1, 0.2, 0.6, 0.03, 1.2, 2), ...
                     [tspan(i), tspan(i+1)], y_current);
    T_opt = [T_opt; Ti];
    Y_opt = [Y_opt; Yi];
    y_current = Yi(end, :);
end

%% Visualization
% 1. Dynamics under default lockdown intensity
figure;
subplot(2, 2, 1);
plot(T_default, Y_default(:, 2), 'r', 'LineWidth', 1.5); hold on; % Infected (I)
plot(T_default, Y_default(:, 9), 'b', 'LineWidth', 1.5); % Social unrest (U)
xlabel('Time (days)');
ylabel('Population Fraction');
title('Default Lockdown Dynamics');
legend({'Infected (I)', 'Social Unrest (U)'});
grid on;

% 2. Dynamics under optimized lockdown intensity
subplot(2, 2, 2);
plot(T_opt, Y_opt(:, 2), 'r--', 'LineWidth', 1.5); hold on; % Infected (I)
plot(T_opt, Y_opt(:, 9), 'b--', 'LineWidth', 1.5); % Social unrest (U)

xlabel('Time (days)');
ylabel('Population Fraction');
title('Optimized Lockdown Dynamics');
legend({'Infected (I)', 'Social Unrest (U)'});
grid on;

% Visualize optimized lockdown intensity over multiple time segments
figure;
bar(1:length(L_opt), L_opt, 'FaceColor', [0.2, 0.7, 0.3]);
xticks(1:length(L_opt));
xticklabels(arrayfun(@(i) sprintf('%d-%d', tspan(i), tspan(i+1)), 1:length(L_opt), 'UniformOutput', false));
xlabel('Time Period');
ylabel('Lockdown Intensity');
title('Optimized Lockdown Intensity Over Time Segments');
grid on;


% 4. Population dynamics under default lockdown intensity
figure;
subplot(1, 2, 1);
plot(T_default, Y_default(:, 1), 'g', 'LineWidth', 1.5); hold on; % Susceptible (S)
plot(T_default, Y_default(:, 2), 'r', 'LineWidth', 1.5); % Infected (I)
plot(T_default, Y_default(:, 3), 'b', 'LineWidth', 1.5); % Diagnosed (D)
plot(T_default, Y_default(:, 4), 'm', 'LineWidth', 1.5); % Symptomatic (A)
plot(T_default, Y_default(:, 5), 'c', 'LineWidth', 1.5); % Recovered (R)
plot(T_default, Y_default(:, 6), 'k', 'LineWidth', 1.5); % Critical (T)
plot(T_default, Y_default(:, 8), 'y', 'LineWidth', 1.5); % Deceased (E)
xlabel('Time (days)');
ylabel('Population Fraction');
title('Default Lockdown: Population Dynamics');
legend({'Susceptible (S)', 'Infected (I)', 'Diagnosed (D)', 'Symptomatic (A)', ...
        'Recovered (R)', 'Critical (T)', 'Dead (E)'}, 'Location', 'northeast');
grid on;

% 5. Population dynamics under optimized lockdown intensity
subplot(1, 2, 2);
plot(T_opt, Y_opt(:, 1), 'g--', 'LineWidth', 1.5); hold on; % Susceptible (S)
plot(T_opt, Y_opt(:, 2), 'r--', 'LineWidth', 1.5); % Infected (I)
plot(T_opt, Y_opt(:, 3), 'b--', 'LineWidth', 1.5); % Diagnosed (D)
plot(T_opt, Y_opt(:, 4), 'm--', 'LineWidth', 1.5); % Symptomatic (A)
plot(T_opt, Y_opt(:, 5), 'c--', 'LineWidth', 1.5); % Recovered (R)
plot(T_opt, Y_opt(:, 6), 'k--', 'LineWidth', 1.5); % Critical (T)
plot(T_opt, Y_opt(:, 8), 'y--', 'LineWidth', 1.5); % Deceased (E)
xlabel('Time (days)');
ylabel('Population Fraction');
title('Optimized Lockdown: Population Dynamics');
legend({'Susceptible (S)', 'Infected (I)', 'Diagnosed (D)', 'Symptomatic (A)', ...
        'Recovered (R)', 'Critical (T)', 'Dead (E)'}, 'Location', 'northeast');
grid on;

figure;

% Deaths comparison
subplot(1, 2, 1);
plot(T_default, Y_default(:, 8), 'r', 'LineWidth', 1.5); hold on;
plot(T_opt, Y_opt(:, 8), 'b--', 'LineWidth', 1.5);
xlabel('Time (days)');
ylabel('Cumulative Deaths');
title('Deaths: Default vs Optimized');
legend({'Default', 'Optimized'});
grid on;

% Critical cases comparison
subplot(1, 2, 2);
plot(T_default, Y_default(:, 6), 'r', 'LineWidth', 1.5); hold on;
plot(T_opt, Y_opt(:, 6), 'b--', 'LineWidth', 1.5);
xlabel('Time (days)');
ylabel('Critical Cases');
title('Critical Cases: Default vs Optimized');
legend({'Default', 'Optimized'});
grid on;

% Calculate total deaths for default and optimized lockdown strategies
total_deaths_default = Y_default(end, 8); % Total deaths for default strategy
total_deaths_optimized = Y_opt(end, 8); % Total deaths for optimized strategy

% Display the results
fprintf('Total Deaths (Default Lockdown): %.4f\n', total_deaths_default);
fprintf('Total Deaths (Optimized Lockdown): %.4f\n', total_deaths_optimized);

% Plot total deaths comparison
figure;
bar([1, 2], [total_deaths_default, total_deaths_optimized], 'FaceColor', [0.2, 0.7, 0.3]);
set(gca, 'XTickLabel', {'Default', 'Optimized'});
ylabel('Total Deaths');
title('Comparison of Total Deaths: Default vs Optimized');
grid on;

