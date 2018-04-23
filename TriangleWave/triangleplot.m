%% start
close all
clear all
clc
format long
%% Load data
load_10k = load('10K.CSV');
load_0 = load('0K.CSV');


%% line data 
deltax = load_0(8000,1) - load_0(13500,1);
deltay = load_0(8000,3) - load_0(13500,3);
a = deltay/deltax;
b = load_0(13500,3)-a*load_0(13500,1);
y = a*load_0(8000:13500,1) + b;
e=sum(abs(load_0(8000:13500,3)-y))/(13500-8000);

%% Plot data
figure(1); clf;
hold on;
plot(load_10k(1:end,1), load_10k(1:end,3));
legend('Vtriangle','line');
title('Triangle wave with a 10k ohm resistor, f=217kHz, Vpp=0.77V ')
xlabel('time (seconds)')
ylabel('Voltage (V)')

figure(2); clf;
hold on;
plot(load_0(1:end,1), load_0(1:end,3), 'g');
plot(load_0(8000:13500,1),y, 'r')
%line([load_0(8000,1),load_0(13500,1)],[load_0(8000,3),load_0(13500,3)]);
legend('Vtriangle','line');
title('Triangle wave with a 0 ohm resistor, f=91kHz, Vpp=1.85V')
xlabel('time (seconds)')
ylabel('Voltage (V)')