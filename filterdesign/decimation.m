clear all
close all

%% parameters

Fso = 48e3; % audio sample rate
OSF = 2^10; % ADC oversample factor
Fsi = Fso*OSF; % ADC sample rate
Fc = 20e3; % audio cutoff frequency
N   = 128;        % FIR filter order

%% firceqrip attempt

Rp  = 0.00057565; % Corresponds to 0.01 dB peak-to-peak ripple
Rst = 1e-4;       % Corresponds to 80 dB stopband attenuation

eqnum = firceqrip(N,Fc/(Fsi/2),[Rp Rst],'passedge'); % eqnum = vec of coeffs
fvtool(eqnum,'Fs',Fsi,'Color','White') % Visualize filter

%% dsp toolbox attempt

src = dsp.SampleRateConverter('InputSampleRate',Fsi,...
    'OutputSampleRate',Fso,'Bandwidth',Fc);

info(src)
flt = src.getFilters.coeffs;
flt.Stage1.Numerator
flt.Stage2.Numerator

