clear all;
close all;
clc;

Fs = 48000;
Ts = 1/48000;
frequency_range = linspace(1,20000);
w=1000*2*pi;
w_1 = w/1.3;
w_2 = w*1.3;
num_1 = [w_1^2];
den_1 = [1 w_1*sqrt(2) w_1^2];

num_2 = [1 0 0];
den_2 = [1 w_2*sqrt(2) w_2^2];

G_1 = tf(num_1,den_1);
G_2 = -tf(num_2,den_2);

%Linkwitz
num_casc1 = [w^2];
den_casc1 = [1 w*sqrt(2) w^2];

num_casc2 = [1 0 0];
den_casc2 = [1 w*sqrt(2) w^2];

G1_casc = tf(num_casc1,den_casc1);
G2_casc = tf(num_casc2,den_casc2);

opts = bodeoptions('cstprefs');
opts.FreqUnits='Hz';
bode(G_1,opts),grid;
hold on
bode(G_2,opts),grid;
bode(G_1+G_2,opts),grid;
bode(G1_casc^2,opts)
bode(G2_casc^2,opts)
bode(G2_casc^2+G1_casc^2,opts)
