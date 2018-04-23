%% start
close all
clear all
clc
format long
%% Load data
nor1 = load('WFM01.CSV');
nor2 = load('WFM02.CSV');
nor3 = load('WFM03.CSV');
nor4 = load('WFM04.CSV');
nor5 = load('WFM05.CSV');
nor6 = load('WFM06.CSV');
%% find time index
fs = 1/((nor5(1000,1)-nor5(999,1)));
n = 6;
SNR = snr(nor5(10000:end,1),fs,n)
figure(10); clf;
snr(nor5(10000:end,1),fs,n)

%% fft
Y = fft(x);
L = size(x);
L = L(1);
P2 = abs(Y/L);
P1 = P2(1:L/2+1);
%%
P1(2:end-1) = 2*P1(2:end-1);
f = Fs*(0:(L/2))/L;
plot(f,P1)
title('Single-Sided Amplitude Spectrum of X(t)')
xlabel('f (Hz)')
ylabel('|P1(f)|')

%% Plot data
figure(1); clf;
hold on;
plot(nor1(1:end,1), nor1(1:end,3));
plot(nor1(1:end,1), nor1(1:end,2));
legend('Vin','Vout');
title('Normalization, f = 1kHz, Gain =241')
xlabel('time (seconds)')
ylabel('Voltage (V)')

figure(2); clf;
hold on;
plot(nor2(1:end,1), nor2(1:end,3));
plot(nor2(1:end,1), nor2(1:end,2));
legend('Vin','Vout');
title('Normalization, f = 1kHz, Gain =241')
xlabel('time (seconds)')
ylabel('Voltage (V)')

figure(3); clf;
hold on;
plot(nor3(1:end,1), nor3(1:end,2));
title('Normalization, f = 1kHz, Gain =241')
xlabel('time (seconds)')
ylabel('Voltage (V)')

figure(4); clf;
hold on;
plot(nor4(1:end,1), nor4(1:end,3));
plot(nor4(1:end,1), nor4(1:end,2));
legend('Vin','Vout');
title('Normalization, f = 1kHz, Gain =241')
xlabel('time (seconds)')
ylabel('Voltage (V)')

figure(5); clf;
hold on;
plot(nor5(1:end,1), nor5(1:end,3));
plot(nor5(1:end,1), nor5(1:end,2));
title('Normalization, f = 1kHz')
xlabel('time (seconds)')
ylabel('Voltage (V)')

figure(6); clf;
hold on;
plot(nor6(1:end,1), nor6(1:end,3));
plot(nor6(1:end,1), nor6(1:end,2));
legend('Vin','Vout');
title('Normalization, f = 1kHz, Gain =241')
xlabel('time (seconds)')
ylabel('Voltage (V)')

%%
figure(2); clf;
hold on;
plot(t, nor1(t:t+9000,3));
plot(t, nor1(t:t+9000,2));
legend('Vin','Vout');
title('Normalization')
xlabel('time (seconds)')
ylabel('Voltage (V)')

%%
figure(3); clf;
hold on;
plot(nor2(1:end,1), nor2(1:end,3));
legend('Vin','Vout');
title('Normalization')
xlabel('time (seconds)')
ylabel('Voltage (V)')

figure(4); clf;
hold on;
plot(nor3(1:end,1), nor3(1:end,3));
legend('Vin','Vout');
title('Normalization')
xlabel('time (seconds)')
ylabel('Voltage (V)')


%% bode plot
freq = [0.1 0.5 1 5 10 20 50 500 5000 15000 20000 30000 40000 200000];
mag = [150 200 300 460 590 837 887 866 888 840 855 785 730 406];
figure(8); clf;
hold on
plot(freq, 20*log(mag))
title('Bode plot')
xlabel('frequency')
ylabel('20*log(mag) (dB)')