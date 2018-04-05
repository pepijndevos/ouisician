clear all;
close all;
clc;
fs = 48000;

fc1 = 10000;
G1 = 10;
Q1 = 1/sqrt(1.3);
type1 = 'Treble_Shelf';
[b1, a1]  = shelving(G1, fc1, fs, Q1, type1); %% Treble shelve filter

fc2 = 300;
G2 = 10;
Q2 = 1/sqrt(2);
type2 = 'Base_Shelf';
[b2, a2]  = shelving(G2, fc2, fs, Q2, type2); %% Base shelve filter

fc3 = 5000;
G3 = 10;
Q3 = 1/sqrt(0.1);
[b3, a3]  = peaking(G3, fc3, Q3, fs); % Mid peak filter

num2 = [b2(1) b2(2) b2(3)]; % Base shelve filter
den2 = [a2(1) a2(2) a2(3)];
[h2,w2] = freqz(num2,den2,1024);

num1 = [b1(1) b1(2) b1(3)]; % Treble shelve filter
den1 = [a1(1) a1(2) a1(3)];
[h1,w1] = freqz(num1,den1,1024);

num3 = [b3(1) b3(2) b3(3)]; % Mid peak filter
den3 = [a3(1) a3(2) a3(3)];
[h3,w3] = freqz(num3,den3,1024);

plot(w2*fs/pi/2,mag2db(abs(h2)), w1*fs/pi/2,mag2db(abs(h1)), w3*fs/pi/2,mag2db(abs(h3)))
legend('Base', 'Treble', 'Mid')
xlabel 'Radian Frequency (\omega/\pi)', ylabel 'Magnitude'
xlim([0 25^3]);
ylim([-5 10]);