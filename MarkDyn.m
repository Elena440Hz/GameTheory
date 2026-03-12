function s = MarkDyn(s0, p, M, T, N, P, Tm)
% MARKDYN Προσομοιώνει Μαρκοβιανή δυναμική για το Iterated Symmetric Centipede
%   s = MarkDyn(s0, p, M, T, N, P, Tm) επιστρέφει την εξέλιξη του συστήματος

    %% ΕΛΕΓΧΟΣ ΕΙΣΟΔΩΝ
    if nargin < 1
        error('MarkDyn: Απαιτείται το όρισμα s0 (αρχική κατάσταση)');
    end
    
    if length(s0) ~= 3
        error('MarkDyn: Το s0 πρέπει να είναι διάνυσμα 3 στοιχείων');
    end
    
    % Προεπιλεγμένες τιμές
    if nargin < 2 || isempty(p), p = 0.75; end
    if nargin < 3 || isempty(M), M = 4; end
    if nargin < 4 || isempty(T), T = 10; end
    if nargin < 5 || isempty(N)
        N = sum(s0);
        fprintf('MarkDyn: Χρήση N = %d από το άθροισμα του s0\n', N);
    end
    
    if abs(sum(s0) - N) > 1e-10
        error('MarkDyn: Το άθροισμα s0 (%d) πρέπει να ισούται με N=%d', sum(s0), N);
    end
    
    if nargin < 7 || isempty(Tm), Tm = 100; end
    
    %% 
    s = zeros(Tm+1, 3);
    s(1,:) = s0(:)';
    
    % Αν δεν δόθηκε πίνακας μεταβάσεων, τον υπολογίζουμε
    if nargin < 6 || isempty(P)
        fprintf('MarkDyn: Υπολογισμός πίνακα μεταβάσεων...\n');
        P = StateTransitionGraph(p, M, T, N);
    end
    
    % Δημιουργία λίστας καταστάσεων
    stateList = [];
    for s1 = 0:N
        for s2 = 0:(N-s1)
            s3 = N - s1 - s2;
            stateList = [stateList; s1, s2, s3];
        end
    end
    
    % Βρες τον δείκτη της αρχικής κατάστασης
    currentIdx = find(ismember(stateList, s0, 'rows'));
    if isempty(currentIdx)
        error('MarkDyn: Η κατάσταση [%d,%d,%d] δεν βρέθηκε', s0(1), s0(2), s0(3));
    end
    
    currentState = s0;
    
    for step = 1:Tm
        % Έλεγχος για απορροφητική κατάσταση
        if P(currentIdx, currentIdx) == 1
            s(step+1:end, :) = repmat(currentState, Tm-step+1, 1);
            break;
        end
        
        % Επιλογή επόμενης κατάστασης
        nextIdx = randsample(1:size(stateList,1), 1, true, P(currentIdx,:));
        currentState = stateList(nextIdx, :);
        currentIdx = nextIdx;
        s(step+1, :) = currentState;
    end
end
