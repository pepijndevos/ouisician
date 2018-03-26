clear all;
clc;
close all;
%% sine generator frequency 
NB = 16;
min_range = -2^(NB-1);
max_range = 2^(NB-1)-1;
Range = 2^(NB-1)-1;
samples = 15;
f = 150;
iCLK = 50000000 ; % internal clock

sCLK = 1/((1/f)/samples) %Clk frequency for the required sine wave
counter = round((50000000/sCLK)/2)-1




t=0:pi/samples:2*pi; 
Array=int32(sin(t)*Range); 
plot(t,Array);

dlmwrite('Array.txt', Array)