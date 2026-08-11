%% Test script for DLSimulink development

close all
clear

Fs = 1000; 
N = 1500;
T = 1/Fs;
t = ((0:N-1)*T)';
S = 0.8 + 0.7*sin(2*pi*50*t) + sin(2*pi*120*t);
X = S + 2*randn(size(t));

L = N;
[P1,Y] = dlsfft(X);

figure()
f = Fs/L*(0:(L/2));
plot(f,P1)

figure()
plot(Fs/L*(0:L-1),abs(Y))