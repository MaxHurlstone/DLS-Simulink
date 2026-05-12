function CPS = cps(PSD,frq)
%CPS Calculates Cumulative Power Spectrum
%   Calculates cumulative power spectrum, code from original DEB script.
%
%   Inputs:
%   (Required)
%   PSD - Power spectral density, double
%   frq - Frequency array, double
%
%   See also RUNDEB
%
%   DLSimulink Toolbox

[m,n]       = size(PSD);
CPS			= zeros(m,n);

for i=1:n
    delta_f		= diff(frq);                   			
    f_temp		= frq(1:end-1)+0.5*delta_f;                         % make freq vector containing mid points	
    
    PS          = 0.5*(PSD(1:end-1,i)+PSD(2:end,i)).*delta_f;       % calculates PS for frequency vector
    PS			= interp1(f_temp,PS,frq,'linear',0);                % scale PS over frq frequency vector
    CPS(:,i)         = cumtrapz(PS);                                     % Cumulative Power Spectrum [SI^2]
end
