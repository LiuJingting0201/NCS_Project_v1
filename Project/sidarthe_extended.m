function dydt = sidarthe_extended(t, y, params, L, k, c, w, U_crit, T_crit, alpha_break, eta)
    S = y(1); I = y(2); D = y(3); A = y(4); R = y(5);
    T = y(6); H = y(7); E = y(8); U = y(9);

    % Dynamic transmission rate
    if U > U_crit
        alpha = alpha_break;
    else
        alpha = params(1) * (1 - L^2) * (1 + w * U);
    end

    % Dynamic mortality rate
    if T > T_crit
        tau = params(12) * (1 + eta * (T - T_crit)^2);
    else
        tau = params(12) * (1 - 0.4 * L);
    end

    % Differential equations
    dydt = zeros(9, 1);
    dydt(1) = -S * (alpha * I + params(2) * D + params(3) * A + params(4) * R);
    dydt(2) = S * (alpha * I + params(2) * D + params(3) * A + params(4) * R) - ...
              (params(5) + params(6) + params(10)) * I;
    dydt(3) = params(5) * I - (params(7) + params(11)) * D;
    dydt(4) = params(6) * I * (1 + 0.2 * L)- (params(8) + params(9)) * A;
    dydt(5) = params(7) * D*(1 + 0.3 * L) + params(8) * A - (params(10) + params(11)) * R;%lockdown intensity benifitial to recovery
    dydt(6) = params(9) * A*(1 - 0.05 * L)+ params(10) * R - (params(13) + tau) * T;
    dydt(7) = params(11) * D + params(12) * A + params(13) * T;
    dydt(8) = tau * T;
    dydt(9) = k * L - c * R;
end
