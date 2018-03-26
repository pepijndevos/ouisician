clear all;
close all;
clc;

Fs = 48000;
Ts = 1/48000;

[b,a] = butter(2,150*2/Fs,'low')
%[b1,a1] = butter(2,150*2/Fs,'high');
NB =24; % number of bits
Range = 2^(NB-1)-1;
min_range = -2^(NB-1)
max_range = 2^(NB-1)-1

Mx_num = max(abs(b));
Mx_den = max(abs(a));
if Mx_num>Mx_den
    Mx = Mx_num;
    if Mx>1
        b_new = b./Mx;
        a_new = a./Mx;
    else
        b_new = b;
        a_new = a;
    end
else
    Mx = Mx_den;
    if Mx>1
        b_new = b./Mx;
        a_new = a./Mx;
    else
        b_new = b;
        a_new = a;
    end
end 

N0 = round(b_new(1)*Range);
N1 = round(b_new(2)*Range);
N2 = round(b_new(3)*Range);
D0 = round(a_new(1)*Range);
D1 = round(a_new(2)*Range);
D2 = round(a_new(3)*Range);


num_new = [N0 N1 N2]
den_new = [D0 D1 D2]


[h,w] = freqz(b,a,1024);
%[h1,w1] = freqz(b1,a1,1024);
[hs,ws] = freqz(num_new,den_new,1024);
%[hs1,ws1] = freqz(bs1,as1,1024);

semilogx(w*Fs/pi/2,mag2db(abs(h)), ws*Fs/pi/2,mag2db(abs(hs)))
grid
%plot(w1*Fs/pi/2,mag2db(abs(h1)), ws1*Fs/pi/2,mag2db(abs(hs1)))
legend('butter Design', 'scaled')
xlabel 'Radian Frequency (\omega/\pi)', ylabel 'Magnitude'
xlim([0 0.5*10^4]);
ylim([-100 1]);