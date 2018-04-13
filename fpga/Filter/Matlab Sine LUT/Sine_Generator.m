clear all;
clc;
close all;
%% sine generator frequency 
f=1000;
fs=48000;
t=0:1/fs:1/f; %time index
fs=48000; %48kHz sampling rate
x=int32(sin(2*pi*f*t)*(2^7 -1));
plot(t,x);

dlmwrite('sine_array.txt',x)