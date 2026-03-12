function P = StateTransitionGraph(p, M, T, N)
% STATETRANSITIONGRAPH πίνακασ μεταβάσεων του Μαρκοβιανού 
%   P = StateTransitionGraph(p, M, T, N) επιστρέφει τον πίνακα πιθανοτήτων
%   μετάβασης για το ISC με N παίκτες

    % Δημιουργία λίστας όλων των καταστάσεων
    stateList = [];
    for s1 = 0:N
        for s2 = 0:(N-s1)
            s3 = N - s1 - s2;
            stateList = [stateList; s1, s2, s3];
        end
    end
    nStates = size(stateList, 1);
    
    % Πίνακας πληρωμών C
    C = [T*M,     3*(1-p)*T,     T*M;
         3*p*T,       T,         3*p + (T-1);
         T*M,     3*(1-p)+(T-1), T*M];
    
    % Αρχικοποίηση πίνακα μεταβάσεων
    P = zeros(nStates, nStates);
    
    % Για κάθε κατάσταση, υπολογίζουμε πιθανότητες μετάβασης
    for idx = 1:nStates
        s = stateList(idx, :);
        s1 = s(1); s2 = s(2); s3 = s(3);
        
        % Πιθανότητα επιλογής παίκτη από κάθε στρατηγική
        probSelect = s / N;
        
        % Υπολογισμός πληρωμών Q
        if s1 > 0
            Q1 = ((s1-1)*C(1,1) + s2*C(1,2) + s3*C(1,3)) / (N-1);
        else
            Q1 = -Inf;
        end
        
        if s2 > 0
            Q2 = (s1*C(2,1) + (s2-1)*C(2,2) + s3*C(2,3)) / (N-1);
        else
            Q2 = -Inf;
        end
        
        if s3 > 0
            Q3 = (s1*C(3,1) + s2*C(3,2) + (s3-1)*C(3,3)) / (N-1);
        else
            Q3 = -Inf;
        end
        
        Q = [Q1, Q2, Q3];
        
        % Υπολογισμός πιθανοτήτων μετάβασης σύμφωνα με PPI
        for i = 1:3  % i = στρατηγική που επιλέγεται να αλλάξει
            if s(i) > 0
                % Υπολογισμός παρονομαστή: Σ_k (s_k/N) * max(Q_k - Q_i, 0)
                denominator = 0;
                for k = 1:3
                    if s(k) > 0
                        denominator = denominator + (s(k)/N) * max(Q(k) - Q(i), 0);
                    end
                end
                
                if denominator > 0
                    for j = 1:3  % j = νέα στρατηγική
                        if j ~= i && s(j) > 0
                            % Πιθανότητα μετάβασης σύμφωνα με PPI
                            prob = probSelect(i) * ((s(j)/N) * max(Q(j) - Q(i), 0) / denominator);
                            
                            % Βρες την κατάσταση-στόχο
                            new_s = s;
                            new_s(i) = new_s(i) - 1;
                            new_s(j) = new_s(j) + 1;
                            
                            % Βρες τον δείκτη της κατάστασης-στόχου
                            targetIdx = find(ismember(stateList, new_s, 'rows'));
                            if ~isempty(targetIdx)
                                P(idx, targetIdx) = P(idx, targetIdx) + prob;
                            end
                        end
                    end
                end
            end
        end
        
        % Πιθανότητα να παραμείνει στην ίδια κατάσταση
        P(idx, idx) = 1 - sum(P(idx, :));
        
        % Διόρθωση για αριθμητικά σφάλματα
        if abs(sum(P(idx,:)) - 1) > 1e-10
            P(idx, :) = P(idx, :) / sum(P(idx, :));
        end
    end
end
