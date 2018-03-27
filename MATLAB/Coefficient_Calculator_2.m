clear all;
close all;
clc;

Fs = 48000;
Ts = 1/48000;

[b,a] = butter(2,150*2/Fs,'high')
%[b1,a1] = butter(2,150*2/Fs,'high');

bs = b./a(3);
as = a./a(3);

mx = max(abs(([bs(1) bs(2) bs(3)])));
if mx > 1
    b0new = bs(1)/mx;
    b1new = bs(2)/mx;
    b2new = bs(3)/mx;
else
    b0new = bs(1);
    b1new = bs(2);
    b2new = bs(3);
end

mx1 = max(abs(([as(1) as(2) as(3)])));
if mx1 > 1
    a0new = as(1)/mx1;
    a1new = as(2)/mx1;
    a2new = as(3)/mx1;
else
    a0new = as(1);
    a1new = as(2);
    a2new = as(3);
end

NB = 16;
range = 2^(NB-1)-1;

N0 = floor(b0new*range*0.75);
N1 = floor(b1new*range*0.75);
N2 = floor(b2new*range*0.75);

D1 = floor(a0new*range);

D2 = floor(a1new*range);
D3 = floor(a2new*range);
num = [N2 N1 N0]
den = [D1 D2 D3]
[hs,ws] = freqz(num,den,512);

%bs1 = round(b1./a1(3).*2^19) %coef for hpf
%as1 = round(a1./a1(3).*2^19)

hold on;
[h,w] = freqz(b,a,1024);
%[h1,w1] = freqz(b1,a1,1024);
%[hs,ws] = freqz(bs,as,1024);
%[hs1,ws1] = freqz(bs1,as1,1024);

plot(w*Fs/pi/2,mag2db(abs(h)), ws*Fs/pi/2,mag2db(abs(hs)))
%plot(w1*Fs/pi/2,mag2db(abs(h1)), ws1*Fs/pi/2,mag2db(abs(hs1)))
legend('butter Design', 'scaled')
xlabel 'Radian Frequency (\omega/\pi)', ylabel 'Magnitude'
xlim([0 0.1*10^4]);
ylim([-30 10]);