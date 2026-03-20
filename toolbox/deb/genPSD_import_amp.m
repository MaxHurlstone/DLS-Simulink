function PSD = genPSD_import_amp(par)

%% Generate Imported Disturbance PSD model
%%
data_import     = readcell('TA105_PSD_A1.csv');
data_frq        = cell2mat(data_import(2:end,1));                          % Import data frequency vector <rows, col>
data_PSD        = cell2mat(data_import(2:end,2));                          % Import data PSD maginitude <rows, col>

% Map PSD to the analysis frequency vector 
PSD_import_TA105 = interp1(data_frq, data_PSD, par.frq,'linear',0);         % Zero where outside of data frequency range

% Calculate signal power to test energy conservation
CPS_Mapped = cps(PSD_import_TA105, par.frq);
CPS_Import = cps(data_PSD, data_frq);

% Plot PSD for Floor vibrations
figure;
loglog(par.frq,PSD_import_TA105(:))
hold on; grid
loglog(data_frq,data_PSD(:))
legend(['PSD Mapped - Var:' num2str(sqrt(CPS_Mapped(end)),3)],['PSD Raw Data - Var:' num2str(sqrt(CPS_Import(end)),3)])
xlabel('Frequency [Hz]')
ylabel('PSD [(A)^2/Hz]')
title('PSD TA105 Amplifier Noise')
xlim([par.Fmin,1e+3])

% Output
PSD	= PSD_import_TA105;
