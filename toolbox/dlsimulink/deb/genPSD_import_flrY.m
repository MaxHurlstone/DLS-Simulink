function PSD = genPSD_import_flrY(par)

%% Generate Imported Disturbance PSD model
%%
data_import     = readcell('FloorZ_PSD_A1.csv');
data_frq        = cell2mat(data_import(2:end,1));                          % Import data frequency vector <rows, col>
data_PSD        = cell2mat(data_import(2:end,2));                          % Import data PSD maginitude <rows, col>

% Map PSD to the analysis frequency vector 
PSD_import_flrY = interp1(data_frq, data_PSD, par.frq,'linear',0);         % Zero where outside of data frequency range

% Calculate signal power up to end of analysis frequency range
CPS_Mapped = cps(PSD_import_flrY, par.frq);
idx        = find(data_frq > par.frq(end));
CPS_Import = cps(data_PSD(1:idx(1)), data_frq(1:idx(1)));

% Plot PSD for Floor vibrations
figure;
loglog(par.frq,PSD_import_flrY(:))
hold on; grid
loglog(data_frq,data_PSD(:))
legend(['PSD Mapped - Var:' num2str(sqrt(CPS_Mapped(end)),3)],['PSD Raw Data - Var:' num2str(sqrt(CPS_Import(end)),3)])
xlabel('Frequency [Hz]')
ylabel('PSD [(m/s^2)^2/Hz]')
title('PSD Import Floor Vibrations Y')
xlim([par.Fmin,par.Fnyq])

% Output
PSD	= PSD_import_flrY;
