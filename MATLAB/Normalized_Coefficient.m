clear all;
clc;
close all;
%user-defined parameters:
fs = 48000; %sampling frequency
f0 = 150;
dBgain = 0;
Q = 0.707; % Q is constant for 2nd order Butterworth

%intermediate parameters
% wo = 2*pi*f0/fs;
% cosW = cos(wo);
% sinW = sin(wo);
% alpha = sinW/(2*Q);
%low pass filter coefficients
% b0 = 10^(dBgain/20)*((1 - cosW)/2);
% b1 = 10^(dBgain/20)*(1 - cosW);
% b2 = 10^(dBgain/20)*((1 - cosW)/2);
% a0 = (1+alpha);
% a1 = -2*cosW;
% a2 = (1-alpha);
%Normalize so that A0 = 1
[b,a] = butter(2,150/(fs/2));
b0 = b(1);
b1 = b(2);
b2 = b(3);
a0 = a(1);
a1 = a(2);
a2 = a(3);
B0 = b0/a0;
B1 = b1/(2*a0);
B2 = b2/a0;
A1 = a1/(-2*a0);
A2 = a2/(-a0);
Mx = max(abs([B0, B1, B2]));
if Mx > 1
B0new = B0/Mx;
B1new = B1/Mx;
B2new = B2/Mx;
else
B0new = B0;
B1new = B1;
B2new = B2;
end
NB =16; % number of bits
Range = 2^(NB-1)-1;
N0 = round(B0new*Range);
N1 = round(B1new*Range);
N2 = round(B2new*Range);
D1 = round(A1*Range);
D2 = round(A2*Range);
D0 = round(Range+1);

Num_original=[b0 b1 b2];
Den_original= [a0 a1 a2];

Num_scaled = [N0 N1 N2];
Den_scaled = [D0 D1 N2];


[H_scaled,w_scaled] = freqz(Num_scaled,Den_scaled,1024);
[H_original,w_original] = freqz(Num_original,Den_original,1024);


plot(w_scaled*fs/(pi/2),mag2db(abs(H_scaled)))
hold on;
plot(w_original*fs/(pi/2),mag2db(abs(H_original)))

