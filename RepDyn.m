function x = RepDyn(x0, p, M, T, Tf)
    
% Κατασκευή πίνακα κερδών C' (All-M/2, All-1, Grim)
    C = zeros(3,3);
    
    % All-M/2
    C(1,1) = T * (M/2);
    C(1,2) = 3 * (1 - p) * T;
    C(1,3) = (M+1)* p;
    % All-1
    C(2,1) = 3 * p * T;
    C(2,2) = T;
    C(2,3) = 3 * p + (T - 1);
    % Grim
    C(3,1) = (M+1) * (1-p) + (T-1) * 3 * p;
    C(3,2) = 3 * (1 - p) + (T - 1);
    C(3,3) = T * M;

    % Ορισμός του συστήματος διαφορικών εξισώσεων (Replicator Dynamics)
    ode_fun = @(t, x) [
        x(1) * ((C(1,:) * x) - (x' * C * x));
        x(2) * ((C(2,:) * x) - (x' * C * x));
        x(3) * ((C(3,:) * x) - (x' * C * x))
    ];

    % Επίλυση του συστήματος από t=0 έως t=Tf
    [~, x_out] = ode45(ode_fun, [0 Tf], x0);
   
    x = x_out';
end