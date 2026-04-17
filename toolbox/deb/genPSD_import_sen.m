function PSD = genPSD_import_sen(par)

%% Generate Imported Disturbance PSD model
%%
data_import     = readcell('SFH9206_PSD_unfiltered_A1.csv');
data_frq        = cell2mat(data_import(2:end,1));                          % Import data frequency vector <rows, col>
data_PSD        = cell2mat(data_import(2:end,2));                          % Import data PSD maginitude <rows, col>

% Map PSD to the analysis frequency vector 
PSD_import_SFH9206 = interp1(data_frq, data_PSD, par.frq,'linear',0);         % Zero where outside of data frequency range

% Calculate signal power to test energy conservation
CPS_Mapped = cps(PSD_import_SFH9206, par.frq);
idx        = find(data_frq > par.frq(end));
CPS_Import = cps(data_PSD(1:idx(1)), data_frq(1:idx(1)));

% Plot PSD for Floor vibrations
figure;
loglog(par.frq,PSD_import_SFH9206(:))
hold on; grid
loglog(data_frq,data_PSD(:))
legend(['PSD Mapped - Var:' num2str(sqrt(CPS_Mapped(end)),3)],['PSD Raw Data - Var:' num2str(sqrt(CPS_Import(end)),3)])
xlabel('Frequency [Hz]')
ylabel('PSD [(m)^2/Hz]')
title('PSD SFH9206 Sensor Noise')
xlim([par.Fmin,1e+3])

% Output
PSD	= PSD_import_SFH9206;
