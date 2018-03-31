clear all
close all

%% parameters

OSF = 2^10; % ADC oversample factor
Fsi = 50e6; % ADC sample rate
Fso = Fsi/OSF; % audio sample rate
Fc = 20e3; % audio cutoff frequency

%% direct firceqrip attempt
N   = 128;        % FIR filter order

Rp  = 0.00057565; % Corresponds to 0.01 dB peak-to-peak ripple
Rst = 1e-3;       % Corresponds to 80 dB stopband attenuation

eqnum = firceqrip(N,Fc/(Fsi/2),[Rp Rst],'passedge'); % eqnum = vec of coeffs
fvtool(eqnum,'Fs',Fsi) % Visualize filter

%% multistage firpm attempt
D1=64;
D2=16;
D=D1*D2;
SD=2*1e-4;

f1 = [0, 1/D, 2/D1-1/D, 1];
a1 = [1 1 0 0];
eq1 = round(firpm(255, f1, a1)*2^16);
fvtool(eq1,'Fs',Fsi)

f2 = [0, 1/D2-D1*SD, 1/D2, 1];
a2 = [1 1 0 0];
eq2 = round(firpm(1023, f2, a2)*2^16);
fvtool(eq2,'Fs',Fsi/D1)

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