%% markov_absorb_343_arrows.m - Προσομοίωση με βέλη αντί για αριθμούς για κατεύθυνση
clear; clc; close all;

fprintf('=============================================================\n');
fprintf('ΜΑΡΚΟΒΙΑΝΗ ΔΥΝΑΜΙΚΗ - ΑΠΟ [3,4,3] ΜΕΧΡΙ ΑΠΟΡΡΟΦΗΣΗ (ΜΕ ΒΕΛΗ)\n');
fprintf('=============================================================\n\n');

%% οι παράμετροί μας
N = 10;           % μέγεθος πληθυσμού
M = 4;            % αριθμός σταδίων Centipede
T = 10;           % αριθμός γύρων ISC
p1 = 0.75;        % p > 2/3 (Σχήμα 4)
p2 = 0.6;         % p < 2/3 (Σχήμα 5)

% Αρχική κατάσταση [3,4,3] 
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

%  map για γρήγορη αναζήτηση δείκτη από κατάσταση
stateToIdx = containers.Map();
for idx = 1:size(stateList, 1)
    key = sprintf('%d_%d_%d', stateList(idx,1), stateList(idx,2), stateList(idx,3));
    stateToIdx(key) = idx;
end

%% προσομοίωση για p = 0.75
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
    
    % δείκτης τρέχουσας κατάστασης
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
    
    % Εμφάνιση μετάβασης
    transition_prob = P1(currentIdx, nextIdx);
    
    % Προσδιορισμός τύπου μετάβασης
    dx = nextState(1) - currentState(1);
    dy = nextState(2) - currentState(2);
    
    if dx == 0 && dy == -1
        type = 'Νότια';
    elseif dx == 1 && dy == -1
        type = 'Νοτιοανατολική';
    elseif dx == -1 && dy == 0
        type = 'Δυτική';
    elseif dx == 1 && dy == 0
        type = 'Ανατολική';
    else
        type = 'Άλλη';
    end
    
    fprintf('Βήμα %d: [%d,%d,%d] → [%d,%d,%d] (%s, πιθ. %.4f)\n', ...
            step, currentState(1), currentState(2), currentState(3), ...
            nextState(1), nextState(2), nextState(3), type, transition_prob);
    
  
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
    
    dx = nextState(1) - currentState(1);
    dy = nextState(2) - currentState(2);
    
    if dx == 0 && dy == -1
        type = 'Νότια';
    elseif dx == 1 && dy == -1
        type = 'Νοτιοανατολική';
    elseif dx == -1 && dy == 0
        type = 'Δυτική';
    elseif dx == 1 && dy == 0
        type = 'Ανατολική';
    else
        type = 'Άλλη';
    end
    
    fprintf('Βήμα %d: [%d,%d,%d] → [%d,%d,%d] (%s, πιθ. %.4f)\n', ...
            step, currentState(1), currentState(2), currentState(3), ...
            nextState(1), nextState(2), nextState(3), type, transition_prob);
    
    path_p2 = [path_p2; nextState];
    currentState = nextState;
end

fprintf('\nΣυνολικά βήματα μέχρι απορρόφηση: %d\n', step);
fprintf('Τελική κατάσταση: [%d,%d,%d]\n', currentState(1), currentState(2), currentState(3));

%% ΒΗΜΑ 5: Οπτικοποίηση της διαδρομής ΜΕ ΒΕΛΗ
figure('Name', 'Markov Chain Path from [3,4,3] - WITH ARROWS', 'Position', [100, 100, 1400, 600]);

% Υπογράφημα για p=0.75
subplot(1, 2, 1);
hold on;

% όλες οι πιθανές καταστάσεις
for i = 1:size(stateList, 1)
    s = stateList(i, :);
    if s(2) == N  % All-C
        plot(s(1), s(2), 'go', 'MarkerSize', 10, 'MarkerFaceColor', 'g', 'MarkerEdgeColor', 'k', 'LineWidth', 1.5);
    elseif s(2) == 0  % All-D/Grim
        plot(s(1), s(2), 'ro', 'MarkerSize', 8, 'MarkerFaceColor', 'r', 'MarkerEdgeColor', 'k', 'LineWidth', 1);
    else
        plot(s(1), s(2), 'ko', 'MarkerSize', 5, 'Color', [0.5, 0.5, 0.5]);
    end
end

% Σχεδίαση της διαδρομής ΜΕ ΒΕΛΗ
for i = 1:size(path_p1, 1)-1
    from = path_p1(i, :);
    to = path_p1(i+1, :);
    
    % Υπολογισμός κατεύθυνσης
    dx = to(1) - from(1);
    dy = to(2) - from(2);
    
    % βέλη
    if dx ~= 0 || dy ~= 0
        quiver(from(1), from(2), dx*0.6, dy*0.6, ...
               'MaxHeadSize', 0.8, 'Color', 'b', 'LineWidth', 2.5, 'AutoScale', 'off');
    end
end

% κόμβοι της διαδρομής
for i = 1:size(path_p1, 1)
    if i == 1
        % αρχική κατάσταση - μεγάλος κίτρινος κύκλος
        plot(path_p1(i,1), path_p1(i,2), 'yo', 'MarkerSize', 18, ...
             'MarkerFaceColor', 'y', 'MarkerEdgeColor', 'k', 'LineWidth', 2.5);
    elseif i == size(path_p1, 1)
        % τελική κατάσταση - ανάλογα με τον τύπο
        if path_p1(i,2) == N
            plot(path_p1(i,1), path_p1(i,2), 'go', 'MarkerSize', 18, ...
                 'MarkerFaceColor', 'g', 'MarkerEdgeColor', 'k', 'LineWidth', 2.5);
        elseif path_p1(i,2) == 0
            plot(path_p1(i,1), path_p1(i,2), 'ro', 'MarkerSize', 18, ...
                 'MarkerFaceColor', 'r', 'MarkerEdgeColor', 'k', 'LineWidth', 2.5);
        else
            plot(path_p1(i,1), path_p1(i,2), 'mo', 'MarkerSize', 15, ...
                 'MarkerFaceColor', 'm', 'MarkerEdgeColor', 'k', 'LineWidth', 2);
        end
    else
        % ενδιάμεσες καταστάσεις - μπλε κύκλοι
        plot(path_p1(i,1), path_p1(i,2), 'bo', 'MarkerSize', 10, ...
             'MarkerFaceColor', 'b', 'MarkerEdgeColor', 'k', 'LineWidth', 1.5);
    end
end

xlabel('s_1 (All-D)', 'FontSize', 12);
ylabel('s_2 (All-M)', 'FontSize', 12);
title(sprintf('p = %.2f: Διαδρομή από [3,4,3] (βήματα: %d)', p1, size(path_p1,1)-1), 'FontSize', 14);
grid on;
axis equal;
xlim([-0.5, N+0.5]);
ylim([-0.5, N+0.5]);
set(gca, 'XTick', 0:2:N, 'YTick', 0:2:N, 'FontSize', 11);
box on;

% υπόμνημα
text(0.5, 9.5, '● Αρχική', 'Color', 'k', 'FontWeight', 'bold', 'FontSize', 11);
text(0.5, 9.0, '● Ενδιάμεση', 'Color', 'b', 'FontWeight', 'bold', 'FontSize', 11);
text(0.5, 8.5, '● Τελική (All-C)', 'Color', 'g', 'FontWeight', 'bold', 'FontSize', 11);
text(0.5, 8.0, '● Τελική (All-D/Grim)', 'Color', 'r', 'FontWeight', 'bold', 'FontSize', 11);
text(0.5, 7.5, '→ Κατεύθυνση', 'Color', 'b', 'FontWeight', 'bold', 'FontSize', 11);

% υπογράφημα για p=0.6
subplot(1, 2, 2);
hold on;

for i = 1:size(stateList, 1)
    s = stateList(i, :);
    if s(2) == N
        plot(s(1), s(2), 'go', 'MarkerSize', 10, 'MarkerFaceColor', 'g', 'MarkerEdgeColor', 'k', 'LineWidth', 1.5);
    elseif s(2) == 0
        plot(s(1), s(2), 'ro', 'MarkerSize', 8, 'MarkerFaceColor', 'r', 'MarkerEdgeColor', 'k', 'LineWidth', 1);
    else
        plot(s(1), s(2), 'ko', 'MarkerSize', 5, 'Color', [0.5, 0.5, 0.5]);
    end
end

for i = 1:size(path_p2, 1)-1
    from = path_p2(i, :);
    to = path_p2(i+1, :);
    
    dx = to(1) - from(1);
    dy = to(2) - from(2);
    
    if dx ~= 0 || dy ~= 0
        quiver(from(1), from(2), dx*0.6, dy*0.6, ...
               'MaxHeadSize', 0.8, 'Color', 'r', 'LineWidth', 2.5, 'AutoScale', 'off');
    end
end

for i = 1:size(path_p2, 1)
    if i == 1
        plot(path_p2(i,1), path_p2(i,2), 'yo', 'MarkerSize', 18, ...
             'MarkerFaceColor', 'y', 'MarkerEdgeColor', 'k', 'LineWidth', 2.5);
    elseif i == size(path_p2, 1)
        if path_p2(i,2) == N
            plot(path_p2(i,1), path_p2(i,2), 'go', 'MarkerSize', 18, ...
                 'MarkerFaceColor', 'g', 'MarkerEdgeColor', 'k', 'LineWidth', 2.5);
        elseif path_p2(i,2) == 0
            plot(path_p2(i,1), path_p2(i,2), 'ro', 'MarkerSize', 18, ...
                 'MarkerFaceColor', 'r', 'MarkerEdgeColor', 'k', 'LineWidth', 2.5);
        else
            plot(path_p2(i,1), path_p2(i,2), 'mo', 'MarkerSize', 15, ...
                 'MarkerFaceColor', 'm', 'MarkerEdgeColor', 'k', 'LineWidth', 2);
        end
    else
        plot(path_p2(i,1), path_p2(i,2), 'ro', 'MarkerSize', 10, ...
             'MarkerFaceColor', 'r', 'MarkerEdgeColor', 'k', 'LineWidth', 1.5);
    end
end

xlabel('s_1 (All-D)', 'FontSize', 12);
ylabel('s_2 (All-M)', 'FontSize', 12);
title(sprintf('p = %.2f: Διαδρομή από [3,4,3] (βήματα: %d)', p2, size(path_p2,1)-1), 'FontSize', 14);
grid on;
axis equal;
xlim([-0.5, N+0.5]);
ylim([-0.5, N+0.5]);
set(gca, 'XTick', 0:2:N, 'YTick', 0:2:N, 'FontSize', 11);
box on;

text(0.5, 9.5, '● Αρχική', 'Color', 'k', 'FontWeight', 'bold', 'FontSize', 11);
text(0.5, 9.0, '● Ενδιάμεση', 'Color', 'r', 'FontWeight', 'bold', 'FontSize', 11);
text(0.5, 8.5, '● Τελική (All-C)', 'Color', 'g', 'FontWeight', 'bold', 'FontSize', 11);
text(0.5, 8.0, '● Τελική (All-D/Grim)', 'Color', 'r', 'FontWeight', 'bold', 'FontSize', 11);
text(0.5, 7.5, '→ Κατεύθυνση', 'Color', 'r', 'FontWeight', 'bold', 'FontSize', 11);

sgtitle('Μαρκοβιανή Δυναμική: Διαδρομές από [3,4,3] μέχρι απορρόφηση (με βέλη)', 'FontSize', 16);

%% πολλές προσομοιώσεις για στατιστική ανάλυση
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

% στατιστικά
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
        color = 'πράσινο';
    elseif uniqueFinal(i,2) == 0
        type = 'All-D/Grim';
        color = 'κόκκινο';
    else
        type = 'Μικτή';
        color = 'μωβ';
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
xlabel('Αριθμός βημάτων μέχρι απορρόφηση', 'FontSize', 12);
ylabel('Συχνότητα', 'FontSize', 12);
title(sprintf('p = %.2f: Κατανομή βημάτων μέχρι απορρόφηση', p1), 'FontSize', 14);
grid on;

subplot(1, 2, 2);
histogram(stepsToAbsorb_p2, 20, 'FaceColor', 'r', 'FaceAlpha', 0.7);
xlabel('Αριθμός βημάτων μέχρι απορρόφηση', 'FontSize', 12);
ylabel('Συχνότητα', 'FontSize', 12);
title(sprintf('p = %.2f: Κατανομή βημάτων μέχρι απορρόφηση', p2), 'FontSize', 14);
grid on;

sgtitle('Κατανομή χρόνου απορρόφησης από [3,4,3]', 'FontSize', 16);

fprintf('\n=============================================================\n');
fprintf('ΟΛΟΚΛΗΡΩΣΗ ΠΡΟΣΟΜΟΙΩΣΕΩΝ\n');
fprintf('=============================================================\n');
