function rundeb()
%RUNDEB Summary of this function goes here
%   Detailed explanation goes here

debgui;

%% Load linearised system model
[file,location] = uigetfile('.mat');
TransF    = load(fullfile(location,file));
G_cLoop   = TransF.LinearAnalysisToolProject.Results.Data.Value;

%% Analysis parameters
N = size(G_cLoop.A,1);

% Generate frequency grid
par.Res     = Res;           % [-] Analysis resolution
par.Fmin	= Fmin;			 % [Hz] bottom of analysis frequency range
par.Ts		= Ts;            % [s] sample time of digital controller
par.Fs		= 1/par.Ts;		 % [Hz] sample frequency
par.Fnyq	= 1/(2*par.Ts);  % [Hz] nyquist frequency
par.frq		= logspace(log10(par.Fmin),log10(par.Fnyq),par.Res)';

%% Open disturbance data

[file,location] = uigetfile('.csv','Select the data file for flrx');
fname_flrx = fullfile(location,file);

%% Format for ss from Simulink: flrx, flry, flrz, [amps (ACTUATOR_NUM)], [sens (ACTUATOR_NUM)], [DACs (ACTUATOR_NUM)]
%% Extract and plot discrete transfer functions for each disturbance path
tf_flrx2xp = bode(G_cLoop(outputID, 1 ),par.frq*2*pi);    % SS transfer function format: <Output number,Input number> 
tf_flry2xp = bode(G_cLoop(outputID, 2 ),par.frq*2*pi);    % SS transfer function format: <Output number,Input number> 
tf_flrz2xp = bode(G_cLoop(outputID, 3 ),par.frq*2*pi);    % SS transfer function format: <Output number,Input number> 
tf_amps2xp = squeeze(bode(G_cLoop(outputID, 4:4+N-1 ),par.frq*2*pi));    % SS transfer function format: <Output number,Input number>
tf_sens2xp = squeeze(bode(G_cLoop(outputID, 4+N:4+ 2*N -1 ),par.frq*2*pi));    % SS transfer function format: <Output number,Input number>
tf_DAC2xp = bode(G_cLoop(outputID, 4+ 2*N ),par.frq*2*pi);    % SS transfer function format: <Output number,Input number>

figure;	
loglog(par.frq,tf_flrx2xp(:),'-', 'DisplayName','flrx2xp [/m.s^-^2]') % Transfer function using ANSYS SS block is in m/s2
hold on; grid
%loglog(par.frq,tf_flr2xp(:).*(2*pi*par.frq))    % Convert Velocity to
%Acceleration for plot required when using Simulink Velocity block & velocity data
loglog(par.frq,tf_flry2xp(:),'-', 'DisplayName',['flry2xp [' err_unit '/m.s^-^2]'])
loglog(par.frq,tf_flrz2xp(:),'-', 'DisplayName',['flrz2xp [' err_unit '/m.s^-^2]'])

for i=1:N
    loglog(par.frq,tf_amps2xp(i,:).*10^6,'--', 'DisplayName', ['amp' num2str(i) '2xp [' err_unit '/uA]']) % Plot convert to display in uA
    loglog(par.frq,tf_sens2xp(i,:),'-.', 'DisplayName', ['sens' num2str(i) '2xp [' err_unit '/m]'])
end
loglog(par.frq,tf_DAC2xp(:).*10^3,':', 'DisplayName', ['DAC2xp [' err_unit '/mV]']) % Plot convert to display in mV

legend('Location','southwest')
xlabel('Frequency [Hz]')
ylabel('Magnitude')
title('Disturbance Path Transfer Function')
xlim([par.Fmin, 1e+3])
%ylim([1e-6, 1e+3])

%% Import disturbance models 
%%
PSD_DAC     = genPSD_DAC(par);
PSD_amp     = genPSD_import_amp(par);
PSD_flrX    = genPSD_import_flrX(par);
PSD_flrY    = genPSD_import_flrY(par);
PSD_flrZ    = genPSD_import_flrZ(par);
%PSD_flr_vel = PSD_flrX./((2*pi*par.frq).^2);           % convert Acceleration PSD to velocity PSD for Simulink vel block             
PSD_sen     = genPSD_import_sen(par);

%% Solve DEB
%%
PSD_DAC2xp = (tf_DAC2xp(:).^2).*PSD_DAC; 
PSD_amps2xp = (tf_amps2xp.^2).*repmat(PSD_amp,[1 N])';
PSD_amps2xp = PSD_amps2xp';
%PSD_flr2xp = (tf_flr2xp(:).^2).*PSD_flr_vel; % Using Accel not vel
PSD_flrx2xp = (tf_flrx2xp(:).^2).*PSD_flrX;
PSD_flry2xp = (tf_flry2xp(:).^2).*PSD_flrY;
PSD_flrz2xp = (tf_flrz2xp(:).^2).*PSD_flrZ;
PSD_sens2xp = (tf_sens2xp.^2).*repmat(PSD_sen,[1 N])';
PSD_sens2xp = PSD_sens2xp';
PSD_tot2xp = PSD_DAC2xp + PSD_flrx2xp + PSD_flry2xp + PSD_flrz2xp;

for i=1:N
    PSD_tot2xp = PSD_tot2xp + PSD_amps2xp(:,i);
    PSD_tot2xp = PSD_tot2xp + PSD_sens2xp(:,i);
end

%% Plot PSD contributions to performance channel Xp
%%
figure;	
loglog(par.frq,PSD_flrx2xp*1e+12,'-', 'DisplayName', 'FloorX')
hold on; grid
loglog(par.frq,PSD_flry2xp*1e+12,'-', 'DisplayName', 'FLoorY')
loglog(par.frq,PSD_flrz2xp*1e+12,'-', 'DisplayName', 'FloorZ')

for i=1:N
    loglog(par.frq,PSD_amps2xp(:,i)*1e+12,'--', 'DisplayName', ['Amp ' num2str(i)])
    loglog(par.frq,PSD_sens2xp(:,i).*1e12,'-.', 'DisplayName', ['Sensor ' num2str(i)])
end

loglog(par.frq,PSD_DAC2xp*1e+12,':', 'DisplayName', 'DAC') 
loglog(par.frq,PSD_tot2xp*1e+12,'k-','LineWidth',1, 'DisplayName', 'Total')  
legend('Location','southwest')
xlabel('Frequency [Hz]')
ylabel(['X_P [u' err_unit '^2/Hz]'])
title('PSD: Contribution to Performance Channel')
xlim([par.Fmin, 1e+3])
%ylim([1e-12, 1e+2])

%% Calculate and Plot CPS
%%
CPS_DAC2xp	= cps(PSD_DAC2xp, par.frq);
CPS_amps2xp	= cps(PSD_amps2xp, par.frq);
CPS_flrx2xp	= cps(PSD_flrx2xp, par.frq);
CPS_flry2xp	= cps(PSD_flry2xp, par.frq);
CPS_flrz2xp	= cps(PSD_flrz2xp, par.frq);
CPS_sens2xp	= cps(PSD_sens2xp, par.frq);
CPS_tot2xp  = cps(PSD_tot2xp, par.frq); % Total Frequency response of system 

disp(' ')
disp('--------------------------------------')
disp(['TOTAL x_p:          ',num2str(sqrt(CPS_tot2xp(end))*1e6,3),[' u' err_unit ' RMS'] ])
disp('--------------------------------------')
disp('FLOOR')
disp(['from floorX:        ',num2str(sqrt(CPS_flrx2xp(end))*1e6,3),[' u' err_unit ' RMS'] ])
disp(['from floorY:        ',num2str(sqrt(CPS_flry2xp(end))*1e6,3),[' u' err_unit ' RMS'] ])
disp(['from floorZ:        ',num2str(sqrt(CPS_flrz2xp(end))*1e6,3),[' u' err_unit ' RMS'] ])
disp('--------------------------------------')

for i=1:N
    disp(['ACTUATOR ' num2str(i) ])
    disp([['from amp' num2str(i) ':          '],num2str(sqrt(CPS_amps2xp(end,i))*1e6,3),[' u' err_unit ' RMS'] ])
    disp([['from sensor' num2str(i) ':       '],num2str(sqrt(CPS_sens2xp(end,i))*1e6,3),[' u' err_unit ' RMS'] ])
    disp('--------------------------------------')
end
disp(['from DAC:           ',num2str(sqrt(CPS_DAC2xp(end))*1e6,3),[' u' err_unit ' RMS'] ])
disp('--------------------------------------')

figure;	
semilogx(par.frq,CPS_flrx2xp*1e+12,'-', 'DisplayName','FloorX')         
hold on; grid
semilogx(par.frq,CPS_flry2xp*1e+12,'-', 'DisplayName','FloorY')
semilogx(par.frq,CPS_flrz2xp*1e+12,'-', 'DisplayName','FloorZ')

for i=1:N
    semilogx(par.frq,CPS_amps2xp(:,i)*1e+12,'--', 'DisplayName',['Amp' num2str(i)])
    semilogx(par.frq,CPS_sens2xp(:,i)*1e+12,'-.', 'DisplayName',['Sensor' num2str(i)])
end
semilogx(par.frq,CPS_DAC2xp*1e+12,':', 'DisplayName','DAC') 

semilogx(par.frq,CPS_tot2xp*1e+12,'k-','LineWidth',1, 'DisplayName', 'Total')  
legend('Location','northwest')
xlabel('Frequency [Hz]')
ylabel(['||X_p||^2_R_M_S [u' err_unit '^2]'])
title('CPS: Contribution to Performance Channel')
xlim([par.Fmin, 1e+3])
%ylim([0, 2000])

text(par.frq(end)*1.0,CPS_flrx2xp(end)*1e+12,[num2str(sqrt(CPS_flrx2xp(end))*1e6,3) 'u' err_unit ])
text(par.frq(end)*1.0,CPS_flry2xp(end)*1e+12,[num2str(sqrt(CPS_flry2xp(end))*1e6,3) 'u' err_unit ])
text(par.frq(end)*1.0,CPS_flrz2xp(end)*1e+12,[num2str(sqrt(CPS_flrz2xp(end))*1e6,3) 'u' err_unit ])

for i=1:N
    text(par.frq(end)*1.0,CPS_amps2xp(end,i)*1e+12,[num2str(sqrt(CPS_amps2xp(end,i))*1e6,3) 'u' err_unit ])
    text(par.frq(end)*1.0,CPS_sens2xp(end,i)*1e+12,[num2str(sqrt(CPS_sens2xp(end,i))*1e6,3) 'u' err_unit ])
end

text(par.frq(end)*1.0,CPS_DAC2xp(end)*1e+12,[num2str(sqrt(CPS_DAC2xp(end))*1e6,3) 'u' err_unit])
text(par.frq(end)*1.0,CPS_tot2xp(end)*1e+12,[num2str(sqrt(CPS_tot2xp(end))*1e6,3) 'u' err_unit])

%% Export PSD as CSV 
%%
varNames = {'Frequency [Hz]'; ['PSD [' err_unit '/s^2]^2/Hz']};
exportTab = table(par.frq, PSD_tot2xp,'VariableNames', varNames);
writetable(exportTab,'DeltaRobotDEB_PSD_C1.csv');  

%% Export CPS as CSV 
%%
varNames = {'Frequency [Hz]'; ['CPS [' err_unit '/s^2]^2']};
exportTab = table(par.frq, CPS_tot2xp,'VariableNames', varNames);
writetable(exportTab,'DeltaRobotDEB_CPS_C1.csv'); 

%% End

end