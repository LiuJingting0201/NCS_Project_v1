function L_opt = optimize_lockdown(params, y0, w1, w2, w3, w4, tspan)
    % Initial lockdown intensities and boundary conditions
    L0 = 0.5 * ones(1, length(tspan) - 1); % Initial lockdown intensities
    lb = 0.1 * ones(1, length(tspan) - 1); % Lower bounds
    ub = 0.8 * ones(1, length(tspan) - 1); % Upper bounds

    % Optimization options
   options = optimoptions('fmincon', 'Display', 'iter', 'Algorithm', 'sqp', ...
                       'MaxIterations', 1000, 'OptimalityTolerance', 1e-6);


    % Call the optimizer
    L_opt = fmincon(@(L) compute_cost_dynamic(L, params, y0, w1, w2, w3, w4, tspan), ...
                    L0, [], [], [], [], lb, ub, [], options);
end


