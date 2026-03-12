function PlotTransitionGraph(p, M, T, N)
% PLOTTRANSITIONGRAPH Σχεδιάζει το γράφημα μεταβάσεων για το ISC
%   PlotTransitionGraph(p, M, T, N) δημιουργεί το γράφημα στο επίπεδο (s1,s2)

    % Υπολογισμός πίνακα μεταβάσεων
    P = StateTransitionGraph(p, M, T, N);
    
    % Δημιουργία λίστας καταστάσεων
    stateList = [];
    for s1 = 0:N
        for s2 = 0:(N-s1)
            s3 = N - s1 - s2;
            stateList = [stateList; s1, s2, s3];
        end
    end
    
    % Δημιουργία figure
    figure('Position', [100, 100, 800, 600]);
    hold on;
    
    % Σχεδίαση κόμβων
    for idx = 1:size(stateList, 1)
        s = stateList(idx, :);
        
        % Χρωματισμός ανάλογα με τον τύπο της κατάστασης
        if s(2) == N  % (0,N,0) - All-C
            plot(s(1), s(2), 'go', 'MarkerSize', 12, 'MarkerFaceColor', 'g', 'LineWidth', 2);
        elseif s(2) == 0  % (s1,0,N-s1) - μείγμα All-D/Grim
            plot(s(1), s(2), 'ro', 'MarkerSize', 10, 'MarkerFaceColor', 'r', 'LineWidth', 1.5);
        else
            plot(s(1), s(2), 'bo', 'MarkerSize', 8, 'MarkerFaceColor', 'b');
        end
        
        % Προσθήκη αριθμού κόμβου 
        % text(s(1)+0.1, s(2)+0.1, num2str(idx), 'FontSize', 8);
    end
    
    % Σχεδίαση ακμών (μεταβάσεις)
    [fromIdx, toIdx] = find(P > 0.01);  % κατώφλι για εμφάνιση
    
    for k = 1:length(fromIdx)
        if fromIdx(k) ~= toIdx(k)  
            s_from = stateList(fromIdx(k), :);
            s_to = stateList(toIdx(k), :);
            
            % Υπολογισμός κατεύθυνσης
            dx = s_to(1) - s_from(1);
            dy = s_to(2) - s_from(2);
            
            % Μήκος βέλους
            arrowLength = 0.3;
            
            % Σχεδίαση βέλους
            quiver(s_from(1), s_from(2), dx*arrowLength, dy*arrowLength, ...
                   'MaxHeadSize', 0.5, 'Color', [0.5, 0.5, 0.5], 'LineWidth', 1);
        end
    end
    
    % Ρύθμιση άξονων
    xlabel('s_1 (All-1)');
    ylabel('s_2 (All-M)');
    title(sprintf('Γράφημα Μεταβάσεων: p=%.2f, M=%d, T=%d, N=%d', p, M, T, N));
    xlim([-0.5, N+0.5]);
    ylim([-0.5, N+0.5]);
    grid on;
    axis equal;
    
    % Προσθήκη legend
    legend({'All-C (0,N,0)', 'All-D/Grim (s₁,0,s₃)', 'Μικτές καταστάσεις'}, ...
           'Location', 'best');
    
    hold off;
end
