function [PSD] = genpsd(dids,fulldids,dfloc,par)
%GENPSD Summary of this function goes here
%   Detailed explanation goes here
arguments (Input)
    dids (1,1) string
    fulldids (:,1) cell
    dfloc (1,1) string
    par (1,1) struct
end

arguments (Output)
    PSD (1,:) double
end

% Extract disturbance id (the type of disturbance PSD to plot)


% Init figure
figure;

if did == "dac"
    output_range = par.dacrange;                             
    n_bit_DAC = par.dacbits;                                     
    
    % DAC quantisation noise
    DAC_quant = output_range/((2^n_bit_DAC)*sqrt(12));      
    
    % Check ^2 PSD of sensor white noise and reformat
    PSD_DAC = bode(tf(1)*(DAC_quant^2/par.Fnyq), par.frq*2*pi);  
    PSD_DAC = PSD_DAC(:);    

    xlabel('Frequency [Hz]')
    ylabel('PSD [V^2/Hz]')
    title('PSD DAC noise')
    xlim([par.Fmin, 1e+3])
    
    % Output
    PSD	= PSD_DAC;
else

end

loglog(par.frq,PSD)
hold on; grid

end