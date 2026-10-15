function [PSDdata] = genpsd(dids,fulldids,dfloc,par)
%GENPSD Extracts and generates PSD data
%   Generates PSD data for a directory containing amp, floorx, floory,
%   floorz and sensor noise data.
%
%   Inputs:
%   dids - Disturbance ids, cell
%   fulldids - Full disturbance ids including file extension, cell
%   dfloc - Disturbance file locations, string
%   par - Parameter structure, struct
%
%   Outputs:
%   PSDData - Output PSDdata, array
%
%   See also RUNDEB
%
%   DLSimulink Toolbox

arguments (Input)
    dids (:,1) cell
    fulldids (:,1) cell
    dfloc (1,1) string
    par (1,1) struct
end

arguments (Output)
    PSDdata (:,:) double
end

% Generate PSC_DAC
output_range = par.dacrange;                             
n_bit_DAC = par.dacbits;                                     

% DAC quantisation noise
DAC_quant = output_range/((2^n_bit_DAC)*sqrt(12));      

% Check ^2 PSD of sensor white noise and reformat
PSD_DAC = bode(tf(1)*(DAC_quant^2/par.Fnyq), par.frq*2*pi);  
PSD_DAC = PSD_DAC(:);    

% Output
PSDdata(1,:) = PSD_DAC;

figure;
loglog(par.frq,PSD_DAC)
hold on; grid
xlabel('Frequency [Hz]')
ylabel('PSD [V^2/Hz]')
title('PSD DAC noise')
xlim([par.Fmin, 1e+3])

% Loop through other disturbances

for i=1:length(dids)
    data_import     = readcell(fullfile(dfloc,fulldids{i}));
    data_frq        = cell2mat(data_import(2:end,1));                          % Import data frequency vector <rows, col>
    data_PSD        = cell2mat(data_import(2:end,2));                          % Import data PSD maginitude <rows, col>
    
    % Map PSD to the analysis frequency vector 
    PSD_Import = interp1(data_frq, data_PSD, par.frq,'linear',0);         % Zero where outside of data frequency range
    
    % Calculate signal power to test energy conservation
    CPS_Mapped = cps(PSD_Import, par.frq);
    idx        = find(data_frq < par.frq(end));
    CPS_Import_Test = cps(data_PSD(idx), data_frq(idx));
    
    % Plot PSD for Floor vibrations
    figure;
    loglog(par.frq,PSD_Import(:))
    hold on; grid
    loglog(data_frq,data_PSD(:))
    legend(['PSD Mapped - Var:' num2str(sqrt(CPS_Mapped(end)),3)],['PSD Raw Data - Var:' num2str(sqrt(CPS_Import_Test(end)),3)])
    xlabel('Frequency [Hz]')
    ylabel('PSD [(m)^2/Hz]')
    title("PSD " + strrep(fulldids{i},'_',' '))
    xlim([par.Fmin,1e+3])
    
    % Output
    PSDdata(1+i,:)	= PSD_Import;
end

end