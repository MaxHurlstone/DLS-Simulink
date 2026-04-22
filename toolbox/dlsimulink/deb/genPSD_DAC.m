function PSD = genPSD_DAC(par)

%% Generate DAC disturbance PSD model
%%
output_range    = 20;                                          % Output range of DAC [V] 
n_bit_DAC		= 16;                                          % DAC resolution in bits
DAC_quant       = output_range/((2^n_bit_DAC)*sqrt(12));      % DAC quantisation noise

PSD_DAC         = bode(tf(1)*(DAC_quant^2/par.Fnyq), par.frq*2*pi);         % Check ^2 PSD of sensor white noise
PSD_DAC         = PSD_DAC(:);                                               % Reformat array    

%%Plot PSD for DAC
figure;
loglog(par.frq,PSD_DAC)
hold on; grid
xlabel('Frequency [Hz]')
ylabel('PSD [V^2/Hz]')
title('PSD DAC noise')
xlim([par.Fmin, 1e+3])

% Output
PSD	= PSD_DAC;
