clear all;
close all;
clc;

Fs = 48000;
Ts = 1/48000;
lpf = 100;
hpf = 600;
mid_freq = (100+300)/2;
Fw = 25000;
delta = Fw/Fs;
range = mid_freq:delta:2000;
[x ,Sz] = size(range);
b = zeros(Sz,1,3);
a = zeros(Sz,1,3);
for i=1:Sz
    lpf = lpf+delta;
    hpf = hpf+delta;
    [b(i,:),a(i,:)] = butter(1,[(lpf)*2/Fs (hpf)*2/Fs],'bandpass');
end
%fprintf('%3.12f\n',b,a);
scale = 20;
%max_range = 2^(20-1)-1;
%min_range = -2^(20-1);
num_new = round(b.*2^scale);
den_new = round(a.*2^scale);
dlmwrite('A0_coef.txt',den_new(:,:,1),'precision','%d','delimiter',' ');
dlmwrite('A1_coef.txt',den_new(:,:,2),'precision','%d','delimiter',' ');
dlmwrite('A2_coef.txt',den_new(:,:,3),'precision','%d','delimiter',' ');

dlmwrite('B0_coef.txt',num_new(:,:,1),'precision','%10.1f');
dlmwrite('B1_coef.txt',num_new(:,:,2),'precision','%10.1f');
dlmwrite('B2_coef.txt',num_new(:,:,3),'precision','%10.1f');



%fprintf('%10.12f\n',num_new,den_new)
%[h1,w1] = freqz(b1,a1,1024);
%[hs,ws] = freqz(num_new,den_new,1024*2);
%[hs1,ws1] = freqz(bs1,as1,1024);

% 
 for j=1:1000:Sz
     [h,w] = freqz(b(j,:),a(j,:),1024*3);
     hold on;
     semilogx(w.*Fs/pi/2,mag2db(abs(h)));
 end

grid
%semilogx(w1*Fs/pi/2,mag2db(abs(h1)), ws1*Fs/pi/2,mag2db(abs(hs1)))
legend('butter Design', 'scaled')
xlabel 'Radian Frequency (\omega/\pi)', ylabel 'Magnitude'


%% FFT Plot

% Y = fft(simout);
% 
% semilogx(w*Fs/pi/2,abs(Y))
% xlim([0 0.5*10^4]);

