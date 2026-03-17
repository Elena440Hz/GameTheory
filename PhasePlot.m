function PhasePlot(p, M, T)
    
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
    
    % Δημιουργία πλέγματος (grid) για το simplex x1 + x2 <= 1
    [X1, X2] = meshgrid(0:0.04:1, 0:0.04:1);
    dX1 = zeros(size(X1));
    dX2 = zeros(size(X2));
    
    % Υπολογισμός των διανυσμάτων της Δυναμικής Αντιγραφέων
    for i = 1:size(X1, 1)
        for j = 1:size(X1, 2)
            x1 = X1(i, j);
            x2 = X2(i, j);
            x3 = 1 - x1 - x2;
            
            % Υπολογίζουμε μόνο τα σημεία που ανήκουν μέσα στο τρίγωνο
            if x3 >= -1e-6 
                x = [x1; x2; x3];
                
                % Αναμενόμενα κέρδη για κάθε στρατηγική
                f = C * x;
                
                % Μέσο κέρδος όλου του πληθυσμού
                phi = x' * C * x;
                
                % Εξισώσεις Replicator Dynamics
                dX1(i, j) = x1 * (f(1) - phi);
                dX2(i, j) = x2 * (f(2) - phi);
            else
                % Εκτός simplex αγνοούμε
                dX1(i, j) = NaN;
                dX2(i, j) = NaN;
            end
        end
    end
    
    % Σχεδίαση Φασικού Διαγράμματος
    figure;
    hold on;
    % Σχεδίαση των βελών (quiver plot)
    quiver(X1, X2, dX1, dX2, 1.5, 'color', [0.8 0.2 0.2], 'LineWidth', 1);
    % Σχεδίαση των ορίων του simplex
    plot([0 1], [1 0], 'k-', 'LineWidth', 1.5); % Διαγώνιος
    plot([0 0], [0 1], 'k-', 'LineWidth', 1.5); % Άξονας Υ
    plot([0 1], [0 0], 'k-', 'LineWidth', 1.5); % Άξονας Χ
    
    % Μορφοποίηση του γραφήματος
    axis equal;
    axis([0 1 0 1]);
    xlabel('x_1 (Ποσοστό All-M/2)');
    ylabel('x_2 (Ποσοστό All-1)');
    title(sprintf('Φασικό Διάγραμμα Replicator Dynamics (p=%g, M=%d, T=%d)', p, M, T));
    grid on;
    hold off;
end