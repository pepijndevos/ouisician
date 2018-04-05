clear all;
close all;
clc;

Fs = 48000;
Ts = 1/48000;

[b,a] = butter(2,200*2/Fs,'low')
%fprintf('%3.12f\n',b,a);
scale = 16;
num_new = round(b.*2^scale);
den_new = round(a.*2^scale);
fprintf('%3.12f\n',num_new,den_new)

[h,w] = freqz(b,a,1024);
%[h1,w1] = freqz(b1,a1,1024);
[hs,ws] = freqz(num_new,den_new,1024);
%[hs1,ws1] = freqz(bs1,as1,1024);

semilogx(w*Fs/pi/2,mag2db(abs(h)), ws*Fs/pi/2,mag2db(abs(hs)))
grid
%semilogx(w1*Fs/pi/2,mag2db(abs(h1)), ws1*Fs/pi/2,mag2db(abs(hs1)))
legend('butter Design', 'scaled')
xlabel 'Radian Frequency (\omega/\pi)', ylabel 'Magnitude'


%% FFT Plot

% Y = fft(simout);
% 
% semilogx(w*Fs/pi/2,abs(Y))
% xlim([0 0.5*10^4]);


