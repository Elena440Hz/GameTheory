% Script to simulate Markov dynamics and draw its state transition graph

clear all; clc
M=4; 					% Number of Centipede stages
T=10; 					% Number of one-shot centipedes played
p=3/4;					% proportion of payoff received by terminating player
N=10;					% population size
Tm=100;					% final time of simulating Markov dynamics
s0=[3 4 3];				% initial Markov state

P=StateTransitionGraph(p,M,T,N);
s=MarkDyn(s0,p,M,T,N,P,Tm); figure(2); plot(s)

