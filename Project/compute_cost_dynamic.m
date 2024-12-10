function cost = compute_cost_dynamic(L, params, y0, w1, w2, w3, w4, tspan)
    T = []; Y = [];
    y_current = y0;

    % Simulate each time segment
    for i = 1:length(tspan) - 1
        [Ti, Yi] = ode45(@(t, y) sidarthe_extended(t, y, params, L(i), ...
                               0.05, 0.1, 0.2, 0.6, 0.03, 1.2, 2), ...
                         [tspan(i), tspan(i+1)], y_current);
        T = [T; Ti];
        Y = [Y; Yi];
        y_current = Yi(end, :);
    end

    % Calculate cost components
    M = Y(end, 8); % Final deaths
    U_cumulative = trapz(T, Y(:, 9)); % Cumulative social unrest
    T_overload = trapz(T, max(0, Y(:, 6) - 0.03)); % Healthcare overload
    P_peak = max(Y(:, 2)); % Infection peak

    % Compute the cost
    cost = w1 * M + w2 * U_cumulative^1.5 + w3 * T_overload^2 + w4 * P_peak*1.2;
     % Add lockdown cost (penalize prolonged strict lockdowns)
    lockdown_cost = sum((1:length(L)) .* L.^2); % Weighted by time segment index
    cost = cost + 0.2 * lockdown_cost; % Adjust weight as needed

    % Add smoothness and regularization terms
    L_diff = sum(abs(diff(L))); % Changes in lockdown intensity
    cost = cost + 0.05 * L_diff + 0.01 * sum(L.^2);
end
