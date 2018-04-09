clear all
close all

%% parameters

OSF = 2^9; % ADC oversample factor
Fso = 48e3; % audio sample rate
Fsi = Fso*OSF; % ADC sample rate

Fc = 20e3; % audio cutoff frequency

%% direct firceqrip attempt
N   = 128;        % FIR filter order

Rp  = 0.00057565; % Corresponds to 0.01 dB peak-to-peak ripple
Rst = 1e-3;       % Corresponds to 80 dB stopband attenuation

eqnum = firceqrip(N,Fc/(Fsi/2),[Rp Rst],'passedge'); % eqnum = vec of coeffs
fvtool(eqnum,'Fs',Fsi) % Visualize filter

%% multistage firpm attempt
D1=128;
D2=8;
D=D1*D2;
SD=2*1e-4;

f1 = [0, 1/D, 2/D1-1/D, 1];
a1 = [1 1 0 0];
eq1 = round(firpm(D1*3-1, f1, a1)*16000);
%eq1 = firpm(D1*3-1, f1, a1);


f2 = [0, 1/D2-D1*SD, 1/D2, 1];
a2 = [1 1 0 0];
eq2 = round(firpm(D2*32-1, f2, a2)*2^11);
%eq2 = firpm(D2*32-1, f2, a2);


[h1, f1] = freqz(eq1, 1, 1000, Fsi);
[h2, f2] = freqz(eq2, 1, 1000, Fsi/D1);

subplot(2,1,1);
plot(f1/1e6, mag2db(abs(h1)))
ylabel('Magnitude (dB)');
xlabel('Frequency (MHz)');
title('Stage 1')

subplot(2,1,2);
plot(f2/1e3, mag2db(abs(h2)))
ylabel('Magnitude (dB)');
xlabel('Frequency (KHz)');
title('Stage 2')

csvwrite('fir1.csv',reshape(eq1, [], 32));
csvwrite('fir2.csv',reshape(eq2, [], 32));

%% dsp toolbox attempt

src = dsp.SampleRateConverter('InputSampleRate',Fsi,...
    'OutputSampleRate',Fso,'Bandwidth',2*Fc,...
    'StopbandAttenuation',96);

info(src)
%visualizeFilterStages(src)

flt = src.getFilters.coeffs;
tb1 = flt.Stage1.Numerator;
fvtool(tb1,'Fs',Fsi)
tb2 = flt.Stage2.Numerator;
fvtool(tb2,'Fs',Fsi/32)
tb3 = flt.Stage3.Numerator;
fvtool(tb3,'Fs',Fsi/32/2)
%% iir attempt

[b,a] = butter(2,Fc/(Fsi/2));
%[b,a] = butter(2,0.5);

as = round(a*2^20)
bs = round(b*2^20)
fvtool(b, a)
fvtool(bs, as)