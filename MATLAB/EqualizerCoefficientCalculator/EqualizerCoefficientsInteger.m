clear all;
close all;
clc;
fs = 48000;


%% Base shelve filter
fc2 = 300;
G2 = 10;
Q2 = 1/sqrt(2);
type2 = 'Base_Shelf';
[b2, a2]  = shelving(G2, fc2, fs, Q2, type2); %% Base shelve filter

numbase = [b2(1) b2(2) b2(3)];
denbase = [a2(1) a2(2) a2(3)];

scale = 12;
numbase_new = round(b2.*2^scale);
denbase_new = round(a2.*2^scale);
[h21,w21] = freqz(numbase,denbase,1024);
[h2,w2] = freqz(numbase_new,denbase_new,1024);

%% Treble shelve filter
fc1 = 10000;
G1 = 10;
Q1 = 1/sqrt(1.3);
type1 = 'Treble_Shelf';
[b1, a1]  = shelving(G1, fc1, fs, Q1, type1);

numtreble = [b1(1) b1(2) b1(3)]; 
dentreble = [a1(1) a1(2) a1(3)];

numtreble_new = round(b1.*2^scale);
dentreble_new = round(a1.*2^scale);
[h11,w11] = freqz(numtreble,dentreble,1024);
[h1,w1] = freqz(numtreble_new,dentreble_new,1024);

%% Mid peak filter
fc3 = 5000;
G3 = 10;
Q3 = 1/sqrt(0.1);
[b3, a3]  = peaking(G3, fc3, Q3, fs); % Mid peak filter

nummid = [b3(1) b3(2) b3(3)];
denmid = [a3(1) a3(2) a3(3)];

nummid_new = round(b3.*2^scale);
denmid_new = round(a3.*2^scale);

[h31,w31] = freqz(nummid,denmid,1024);
[h3,w3] = freqz(nummid_new,denmid_new,1024);

%% plot
plot(w2*fs/pi/2,mag2db(abs(h2)), w1*fs/pi/2,mag2db(abs(h1)), w3*fs/pi/2,mag2db(abs(h3)), w21*fs/pi/2,mag2db(abs(h21)), w11*fs/pi/2,mag2db(abs(h11)), w31*fs/pi/2,mag2db(abs(h31)))
legend('BaseCoeff', 'TrebleCoeff', 'MidCoeff', 'Base', 'Treble', 'Mid')
xlabel 'Radian Frequency (\omega/\pi)', ylabel 'Magnitude'
xlim([0 25^3]);
ylim([-5 10]);