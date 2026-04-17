function PSD = genPSD_DAC(par)
%GENPSD_DAC Generate DAC disturbance PSD model
%   Generates PSD data for a DAC
%
%   Inputs:
%   par - genPSD parameters, structure
%
%   Outputs:
%   PSD - PSD data, array
%
%   See also RUNDEB
%
%   DLSimulink Toolbox

% DAC parameters
output_range    = par.dacrange;                             
n_bit_DAC		= par.dacbits;                                     

% DAC quantisation noise
DAC_quant       = output_range/((2^n_bit_DAC)*sqrt(12));      

% Check ^2 PSD of sensor white noise and reformat
PSD_DAC         = bode(tf(1)*(DAC_quant^2/par.Fnyq), par.frq*2*pi);  
PSD_DAC         = PSD_DAC(:);  

% Plot PSD for DAC
figure;
loglog(par.frq,PSD_DAC)
hold on; grid
xlabel('Frequency [Hz]')
ylabel('PSD [V^2/Hz]')
title('PSD DAC noise')
xlim([par.Fmin, 1e+3])

% Output
PSD	= PSD_DAC;
