%% markov_absorb_343.m - Προσομοίωση Markov Dynamics από [3,4,3] μέχρι απορρόφηση
clear; clc; close all;

fprintf('=============================================================\n');
fprintf('ΜΑΡΚΟΒΙΑΝΗ ΔΥΝΑΜΙΚΗ - ΑΠΟ [3,4,3] ΜΕΧΡΙ ΑΠΟΡΡΟΦΗΣΗ\n');
fprintf('=============================================================\n\n');

%% Ορισμός παραμέτρων
N = 10;           % μέγεθος πληθυσμού
M = 4;            % αριθμός σταδίων Centipede
T = 10;           % αριθμός γύρων ISC
p1 = 0.75;        % p > 2/3 (Σχήμα 4)
p2 = 0.6;         % p < 2/3 (Σχήμα 5)

% αρχική κατάσταση [3,4,3] για κάποιο λόγο
s0 = [3, 4, 3];

fprintf('Παράμετροι:\n');
fprintf('  N = %d (μέγεθος πληθυσμού)\n', N);
fprintf('  M = %d (στάδια)\n', M);
fprintf('  T = %d (γύροι ISC)\n', T);
fprintf('  Αρχική κατάσταση: s0 = [%d, %d, %d] ', s0(1), s0(2), s0(3));
fprintf('(All-D: %d, All-M: %d, Grim: %d)\n\n', s0(1), s0(2), s0(3));

%% λίστα όλων των καταστάσεων
stateList = [];
for s1 = 0:N
    for s2 = 0:(N-s1)
        s3 = N - s1 - s2;
        stateList = [stateList; s1, s2, s3];
    end
end

% φτιάχνω map για γρήγορη αναζήτηση δείκτη από κατάσταση
stateToIdx = containers.Map();
for idx = 1:size(stateList, 1)
    key = sprintf('%d_%d_%d', stateList(idx,1), stateList(idx,2), stateList(idx,3));
    stateToIdx(key) = idx;
end

%% Προσομοίωση για p = 0.75
fprintf('--- ΠΕΡΙΠΤΩΣΗ 1: p = %.2f > 2/3 ---\n', p1);
fprintf('Υπολογισμός πίνακα μεταβάσεων...\n');
P1 = StateTransitionGraph(p1, M, T, N);


fprintf('\nΞεκινώντας προσομοίωση από [3,4,3]...\n\n');

% Πίνακας για αποθήκευση της διαδρομής
path_p1 = s0;
currentState = s0;
step = 0;
absorbed = false;

while ~absorbed
    step = step + 1;
    
    %  δείκτης τρέχουσας κατάστασης
    key = sprintf('%d_%d_%d', currentState(1), currentState(2), currentState(3));
    currentIdx = stateToIdx(key);
    
    % Έλεγχος αν είναι απορροφητική
    if P1(currentIdx, currentIdx) == 1
        fprintf('Βήμα %d: ΑΠΟΡΡΟΦΗΣΗ στην κατάσταση [%d,%d,%d]\n', ...
                step, currentState(1), currentState(2), currentState(3));
        absorbed = true;
        break;
    end
    
    % Επιλογή επόμενης κατάστασης
    nextIdx = randsample(1:size(stateList,1), 1, true, P1(currentIdx,:));
    nextState = stateList(nextIdx, :);
    
    % εμφάνιση μετάβασης
    transition_prob = P1(currentIdx, nextIdx);
    fprintf('Βήμα %d: [%d,%d,%d] → [%d,%d,%d] (πιθανότητα %.4f)\n', ...
            step, currentState(1), currentState(2), currentState(3), ...
            nextState(1), nextState(2), nextState(3), transition_prob);
    
    
    path_p1 = [path_p1; nextState];
    currentState = nextState;
end

fprintf('\nΣυνολικά βήματα μέχρι απορρόφηση: %d\n', step);
fprintf('Τελική κατάσταση: [%d,%d,%d]\n', currentState(1), currentState(2), currentState(3));

%% Προσομοίωση για p = 0.6
fprintf('\n--- ΠΕΡΙΠΤΩΣΗ 2: p = %.2f < 2/3 ---\n', p2);
fprintf('Υπολογισμός πίνακα μεταβάσεων...\n');
P2 = StateTransitionGraph(p2, M, T, N);

fprintf('\nΞεκινώντας προσομοίωση από [3,4,3]...\n\n');

path_p2 = s0;
currentState = s0;
step = 0;
absorbed = false;

while ~absorbed
    step = step + 1;
    
    key = sprintf('%d_%d_%d', currentState(1), currentState(2), currentState(3));
    currentIdx = stateToIdx(key);
    
    if P2(currentIdx, currentIdx) == 1
        fprintf('Βήμα %d: ΑΠΟΡΡΟΦΗΣΗ στην κατάσταση [%d,%d,%d]\n', ...
                step, currentState(1), currentState(2), currentState(3));
        absorbed = true;
        break;
    end
    
    nextIdx = randsample(1:size(stateList,1), 1, true, P2(currentIdx,:));
    nextState = stateList(nextIdx, :);
    
    transition_prob = P2(currentIdx, nextIdx);
    fprintf('Βήμα %d: [%d,%d,%d] → [%d,%d,%d] (πιθανότητα %.4f)\n', ...
            step, currentState(1), currentState(2), currentState(3), ...
            nextState(1), nextState(2), nextState(3), transition_prob);
    
    path_p2 = [path_p2; nextState];
    currentState = nextState;
end

fprintf('\nΣυνολικά βήματα μέχρι απορρόφηση: %d\n', step);
fprintf('Τελική κατάσταση: [%d,%d,%d]\n', currentState(1), currentState(2), currentState(3));

%%  οπτικοποίηση της διαδρομής
figure('Name', 'Markov Chain Path from [3,4,3]', 'Position', [100, 100, 1400, 600]);

% υπογράφημα για p=0.75
subplot(1, 2, 1);
hold on;

% σχεδίαση όλων των πιθανών καταστάσεων ως γκρι κύκλους
for i = 1:size(stateList, 1)
    s = stateList(i, :);
    if s(2) == N
        plot(s(1), s(2), 'go', 'MarkerSize', 8, 'MarkerFaceColor', 'g', 'MarkerEdgeColor', 'k');
    elseif s(2) == 0
        plot(s(1), s(2), 'ro', 'MarkerSize', 8, 'MarkerFaceColor', 'r', 'MarkerEdgeColor', 'k');
    else
        plot(s(1), s(2), 'ko', 'MarkerSize', 4, 'Color', [0.7, 0.7, 0.7]);
    end
end

% σχεδίαση της διαδρομής
for i = 1:size(path_p1, 1)-1
    % γραμμή
    plot([path_p1(i,1), path_p1(i+1,1)], [path_p1(i,2), path_p1(i+1,2)], ...
         'b-', 'LineWidth', 2);
    
    % βέλος ΑΝ ΘΕΛΕΙ Η ΕΡΓΑΣΙΑ ΔΕΝ ΕΧΩ ΙΔΕΑ 
    dx = path_p1(i+1,1) - path_p1(i,1);
    dy = path_p1(i+1,2) - path_p1(i,2);
    if dx ~= 0 || dy ~= 0
        quiver(path_p1(i,1), path_p1(i,2), dx*0.3, dy*0.3, ...
               'MaxHeadSize', 0.5, 'Color', 'b', 'LineWidth', 1.5);
    end
end

% σχεδίαση κόμβων της διαδρομής
for i = 1:size(path_p1, 1)
    if i == 1
        % αρχική κατάσταση
        plot(path_p1(i,1), path_p1(i,2), 'yo', 'MarkerSize', 15, ...
             'MarkerFaceColor', 'y', 'MarkerEdgeColor', 'k', 'LineWidth', 2);
    elseif i == size(path_p1, 1)
        % τελική κατάσταση
        if path_p1(i,2) == N
            plot(path_p1(i,1), path_p1(i,2), 'go', 'MarkerSize', 15, ...
                 'MarkerFaceColor', 'g', 'MarkerEdgeColor', 'k', 'LineWidth', 2);
        elseif path_p1(i,2) == 0
            plot(path_p1(i,1), path_p1(i,2), 'ro', 'MarkerSize', 15, ...
                 'MarkerFaceColor', 'r', 'MarkerEdgeColor', 'k', 'LineWidth', 2);
        else
            plot(path_p1(i,1), path_p1(i,2), 'bo', 'MarkerSize', 12, ...
                 'MarkerFaceColor', 'b', 'MarkerEdgeColor', 'k', 'LineWidth', 1.5);
        end
    else
        % ενδιάμεσες καταστάσεις
        plot(path_p1(i,1), path_p1(i,2), 'bo', 'MarkerSize', 8, ...
             'MarkerFaceColor', 'b', 'MarkerEdgeColor', 'k');
    end
    
    % αριθμός βήματος
    text(path_p1(i,1)+0.2, path_p1(i,2)+0.2, num2str(i-1), 'FontSize', 10, 'FontWeight', 'bold');
end

xlabel('s_1 (All-D)');
ylabel('s_2 (All-M)');
title(sprintf('p = %.2f: Διαδρομή από [3,4,3] (βήματα: %d)', p1, size(path_p1,1)-1));
grid on;
axis equal;
xlim([-0.5, N+0.5]);
ylim([-0.5, N+0.5]);
set(gca, 'XTick', 0:2:N, 'YTick', 0:2:N);

% υπογράφημα για p=0.6
subplot(1, 2, 2);
hold on;

for i = 1:size(stateList, 1)
    s = stateList(i, :);
    if s(2) == N
        plot(s(1), s(2), 'go', 'MarkerSize', 8, 'MarkerFaceColor', 'g', 'MarkerEdgeColor', 'k');
    elseif s(2) == 0
        plot(s(1), s(2), 'ro', 'MarkerSize', 8, 'MarkerFaceColor', 'r', 'MarkerEdgeColor', 'k');
    else
        plot(s(1), s(2), 'ko', 'MarkerSize', 4, 'Color', [0.7, 0.7, 0.7]);
    end
end

for i = 1:size(path_p2, 1)-1
    plot([path_p2(i,1), path_p2(i+1,1)], [path_p2(i,2), path_p2(i+1,2)], ...
         'r-', 'LineWidth', 2);
    
    dx = path_p2(i+1,1) - path_p2(i,1);
    dy = path_p2(i+1,2) - path_p2(i,2);
    if dx ~= 0 || dy ~= 0
        quiver(path_p2(i,1), path_p2(i,2), dx*0.3, dy*0.3, ...
               'MaxHeadSize', 0.5, 'Color', 'r', 'LineWidth', 1.5);
    end
end

for i = 1:size(path_p2, 1)
    if i == 1
        plot(path_p2(i,1), path_p2(i,2), 'yo', 'MarkerSize', 15, ...
             'MarkerFaceColor', 'y', 'MarkerEdgeColor', 'k', 'LineWidth', 2);
    elseif i == size(path_p2, 1)
        if path_p2(i,2) == N
            plot(path_p2(i,1), path_p2(i,2), 'go', 'MarkerSize', 15, ...
                 'MarkerFaceColor', 'g', 'MarkerEdgeColor', 'k', 'LineWidth', 2);
        elseif path_p2(i,2) == 0
            plot(path_p2(i,1), path_p2(i,2), 'ro', 'MarkerSize', 15, ...
                 'MarkerFaceColor', 'r', 'MarkerEdgeColor', 'k', 'LineWidth', 2);
        else
            plot(path_p2(i,1), path_p2(i,2), 'mo', 'MarkerSize', 12, ...
                 'MarkerFaceColor', 'm', 'MarkerEdgeColor', 'k', 'LineWidth', 1.5);
        end
    else
        plot(path_p2(i,1), path_p2(i,2), 'ro', 'MarkerSize', 8, ...
             'MarkerFaceColor', 'r', 'MarkerEdgeColor', 'k');
    end
    
    text(path_p2(i,1)+0.2, path_p2(i,2)+0.2, num2str(i-1), 'FontSize', 10, 'FontWeight', 'bold');
end

xlabel('s_1 (All-D)');
ylabel('s_2 (All-M)');
title(sprintf('p = %.2f: Διαδρομή από [3,4,3] (βήματα: %d)', p2, size(path_p2,1)-1));
grid on;
axis equal;
xlim([-0.5, N+0.5]);
ylim([-0.5, N+0.5]);
set(gca, 'XTick', 0:2:N, 'YTick', 0:2:N);

sgtitle('Μαρκοβιανή Δυναμική: Διαδρομές από [3,4,3] μέχρι απορρόφηση');

%% πολλαπλές προσομοιώσεις για στατιστική ανάλυση
fprintf('\n--- ΣΤΑΤΙΣΤΙΚΗ ΑΝΑΛΥΣΗ ΠΟΛΛΑΠΛΩΝ ΠΡΟΣΟΜΟΙΩΣΕΩΝ ---\n');

nSim = 100;  % αριθμός προσομοιώσεων
stepsToAbsorb_p1 = zeros(nSim, 1);
finalStates_p1 = zeros(nSim, 3);
stepsToAbsorb_p2 = zeros(nSim, 1);
finalStates_p2 = zeros(nSim, 3);

fprintf('\nΕκτέλεση %d προσομοιώσεων για p=%.2f...\n', nSim, p1);
for sim = 1:nSim
    currentState = s0;
    steps = 0;
    
    while true
        key = sprintf('%d_%d_%d', currentState(1), currentState(2), currentState(3));
        currentIdx = stateToIdx(key);
        
        if P1(currentIdx, currentIdx) == 1
            break;
        end
        
        nextIdx = randsample(1:size(stateList,1), 1, true, P1(currentIdx,:));
        currentState = stateList(nextIdx, :);
        steps = steps + 1;
    end
    
    stepsToAbsorb_p1(sim) = steps;
    finalStates_p1(sim, :) = currentState;
end

fprintf('Εκτέλεση %d προσομοιώσεων για p=%.2f...\n', nSim, p2);
for sim = 1:nSim
    currentState = s0;
    steps = 0;
    
    while true
        key = sprintf('%d_%d_%d', currentState(1), currentState(2), currentState(3));
        currentIdx = stateToIdx(key);
        
        if P2(currentIdx, currentIdx) == 1
            break;
        end
        
        nextIdx = randsample(1:size(stateList,1), 1, true, P2(currentIdx,:));
        currentState = stateList(nextIdx, :);
        steps = steps + 1;
    end
    
    stepsToAbsorb_p2(sim) = steps;
    finalStates_p2(sim, :) = currentState;
end

% αποτελέσματα στατιστικής
fprintf('\nΑΠΟΤΕΛΕΣΜΑΤΑ ΓΙΑ p = %.2f:\n', p1);
fprintf('  Μέσος αριθμός βημάτων μέχρι απορρόφηση: %.2f (std = %.2f)\n', ...
        mean(stepsToAbsorb_p1), std(stepsToAbsorb_p1));
fprintf('  Ελάχιστος αριθμός βημάτων: %d\n', min(stepsToAbsorb_p1));
fprintf('  Μέγιστος αριθμός βημάτων: %d\n', max(stepsToAbsorb_p1));

fprintf('\n  Κατανομή τελικών καταστάσεων:\n');
[uniqueFinal, ~, finalIdx] = unique(finalStates_p1, 'rows');
counts = accumarray(finalIdx, 1);
for i = 1:size(uniqueFinal, 1)
    if uniqueFinal(i,2) == N
        type = 'All-C';
    elseif uniqueFinal(i,2) == 0
        type = 'All-D/Grim';
    else
        type = 'Μικτή';
    end
    fprintf('    [%d,%d,%d] (%s): %d φορές (%.1f%%)\n', ...
            uniqueFinal(i,1), uniqueFinal(i,2), uniqueFinal(i,3), type, ...
            counts(i), 100*counts(i)/nSim);
end

fprintf('\nΑΠΟΤΕΛΕΣΜΑΤΑ ΓΙΑ p = %.2f:\n', p2);
fprintf('  Μέσος αριθμός βημάτων μέχρι απορρόφηση: %.2f (std = %.2f)\n', ...
        mean(stepsToAbsorb_p2), std(stepsToAbsorb_p2));
fprintf('  Ελάχιστος αριθμός βημάτων: %d\n', min(stepsToAbsorb_p2));
fprintf('  Μέγιστος αριθμός βημάτων: %d\n', max(stepsToAbsorb_p2));

fprintf('\n  Κατανομή τελικών καταστάσεων:\n');
[uniqueFinal, ~, finalIdx] = unique(finalStates_p2, 'rows');
counts = accumarray(finalIdx, 1);
for i = 1:size(uniqueFinal, 1)
    if uniqueFinal(i,2) == N
        type = 'All-C';
    elseif uniqueFinal(i,2) == 0
        type = 'All-D/Grim';
    else
        type = 'Μικτή';
    end
    fprintf('    [%d,%d,%d] (%s): %d φορές (%.1f%%)\n', ...
            uniqueFinal(i,1), uniqueFinal(i,2), uniqueFinal(i,3), type, ...
            counts(i), 100*counts(i)/nSim);
end

%% ιστόγραμμα βημάτων μέχρι απορρόφηση
figure('Name', 'Steps to Absorption', 'Position', [100, 100, 1200, 500]);

subplot(1, 2, 1);
histogram(stepsToAbsorb_p1, 20, 'FaceColor', 'b', 'FaceAlpha', 0.7);
xlabel('αριθμός βημάτων μέχρι απορρόφηση');
ylabel('συχνότητα');
title(sprintf('p = %.2f: Κατανομή βημάτων μέχρι απορρόφηση', p1));
grid on;

subplot(1, 2, 2);
histogram(stepsToAbsorb_p2, 20, 'FaceColor', 'r', 'FaceAlpha', 0.7);
xlabel('αριθμός βημάτων μέχρι απορρόφηση');
ylabel('συχνότητα');
title(sprintf('p = %.2f: κατανομή βημάτων μέχρι απορρόφηση', p2));
grid on;

sgtitle('κατανομή χρόνου απορρόφησης από [3,4,3]');

fprintf('\n=============================================================\n');
fprintf('ΟΛΟΚΛΗΡΩΣΗ ΠΡΟΣΟΜΟΙΩΣΕΩΝ\n');
fprintf('=============================================================\n');
