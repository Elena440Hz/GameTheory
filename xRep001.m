% Script to simulate Replicator dynamics and draw its phase plot
clear all; clc
M=4; 					% Number of Centipede stages
T=10; 					% Number of one-shot centipedes played

% p = 3/4 για το Σχήμα 2 και p = 3/5 για το Σχήμα 3
p=3/5;					% proportion of payoff received by terminating player
Tf=1; 					% final time of simulating replicator dynamics

x0=rand(3,1);			% initial state
x0=x0/sum(x0);

% Επίλυση και σχεδίαση της εξέλιξης στον χρόνο (Figure 1)
x=RepDyn(x0,p,M,T,Tf); 
figure(1); 
plot(x')
title('Εξέλιξη Πληθυσμών στον Χρόνο (Replicator Dynamics)')
xlabel('Χρόνος (t)')
ylabel('Ποσοστό Πληθυσμού')
legend('All-M/2', 'All-1', 'Grim')

% Σχεδίαση του Φασικού Διαγράμματος (Figure 2 ή 3 ανάλογα το p)
PhasePlot(p,M,T) 