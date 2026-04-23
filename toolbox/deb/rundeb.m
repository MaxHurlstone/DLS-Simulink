function rundeb(outputID,N,Res,Fmin,Ts,dacrange,dacbits)
%RUNDEB Runs a Dynamic Error Budget
%   Runs a dynamic error budget, using the user selected linear system and
%   disturbance data. If no disturbance data is selected, default data is
%   used (data equivalent to that used in 2023 Maglev project).
%
%   Inputs:
%   outputID - Selected performance channel, int32
%   N - Number of system actuators, int32
%   Res - Frequency resolution i.e. number of logspace bins, double
%   Fmin - Minimum frequency, double
%   Ts - Sample time, double
%   dacrange - DAC output voltage range, double
%   dacbits - DAC output bits, double
%
%   See also GENPSD
%
%   DLSimulink Toolbox

arguments (Input)
    outputID (1,1) int32 = 1
    N (1,1) int32 = 6
    Res (1,1) double = 5000
    Fmin (1,1) double = 0.1
    Ts (1,1) double = 1/2000
    dacrange (1,1) double = 20
    dacbits (1,1) double = 16
end

fig = uifigure;
selection = uiconfirm(fig,"Please follow the instructions in the command terminal. Press OK to continue.","rundeb.m",'Icon','info');
switch selection
    case 'OK'
        %
    case 'Cancel'
        return
end
close(fig);

fprintf('\n')
fprintf('1. Select your linear system model.\n\n')

% Load linearised system model
[file,location] = uigetfile('.mat', 'Select linear system model.');
TransF    = load(fullfile(location,file));
G_cLoop   = TransF.LinearAnalysisToolProject.Results.Data.Value;

% Set frequency paraeters
par.Res      = Res;
par.Fmin	 = Fmin;
par.Ts		 = Ts;
par.Fs		 = 1/par.Ts;
par.Fnyq	 = 1/(2*par.Ts);
par.frq		 = logspace(log10(par.Fmin),log10(par.Fnyq),par.Res)';

% Set DAC paraeters
par.dacrange = dacrange;
par.dacbits  =  dacbits;

fprintf(['2. Select the directory containing your disturbance .csv files.\n', ...
         '   Note, the following conventions must be followed:\n', ...
         '  - All disturbance data files must be in the same directory\n', ...
         '  - All disturbance data must be saved as .csv files\n', ...
         '  - All disturbance data must have a prefix identifying its type: amp_, floorx_, floory_, floorz_, sensor_\n\n'])

% Open and import disturbance data

dfloc = uigetdir('.csv','Select the directory containing your disturbance data.');

fprintf('3. Select a directory to save your PSD and CPS data. Pressing cancel means no data will be saved.\n\n')

saveloc = uigetdir('.csv','Select a directory to save your PSD and CPS data.');

fprintf('Running DEB...\n')

fprintf('Extracting PSD data...\n')

if ~dfloc
    fprintf("   No disturbance data selected, default will be used.\n")
    [dfloc,~,~] = fileparts(fullfile(mfilename("fullpath")));
    dfloc = fullfile(dfloc,"default_disturbances");
end

tbl = struct2table(dir(dfloc));
fulldids = tbl(~tbl.isdir,:).name;

splitdids = split(fulldids,"_");
dids = splitdids(:,1);

PSDdata = genpsd(dids,fulldids,dfloc,par);
PSD_DAC = PSDdata(1,:)';
PSD_amp = PSDdata(2,:)';
PSD_flrX = PSDdata(3,:)';
PSD_flrY = PSDdata(4,:)';
PSD_flrZ = PSDdata(5,:)';
PSD_sen  = PSDdata(6,:)';

fprintf('Create disturbance path transfer functions...\n')

% Format for ss from Simulink: flrx, flry, flrz, [amps (ACTUATOR_NUM)], [sens (ACTUATOR_NUM)], [DACs (ACTUATOR_NUM)]
% Extract and plot discrete transfer functions for each disturbance path
tf_flrx2xp = bode(G_cLoop(outputID, 1 ),par.frq*2*pi);    % SS transfer function format: <Output number,Input number> 
tf_flry2xp = bode(G_cLoop(outputID, 2 ),par.frq*2*pi);    % SS transfer function format: <Output number,Input number> 
tf_flrz2xp = bode(G_cLoop(outputID, 3 ),par.frq*2*pi);    % SS transfer function format: <Output number,Input number> 
tf_amps2xp = squeeze(bode(G_cLoop(outputID, 4:4+N-1 ),par.frq*2*pi));    % SS transfer function format: <Output number,Input number>
tf_sens2xp = squeeze(bode(G_cLoop(outputID, 4+N:4+ 2*N -1 ),par.frq*2*pi));    % SS transfer function format: <Output number,Input number>
tf_DAC2xp = bode(G_cLoop(outputID, 4+ 2*N ),par.frq*2*pi);    % SS transfer function format: <Output number,Input number>

fprintf('Plot disturbance path transfer functions...\n')

figure;	
loglog(par.frq,tf_flrx2xp(:),'-', 'DisplayName','flrx2xp [/m.s^-^2]') % Transfer function using ANSYS SS block is in m/s2
hold on; grid
loglog(par.frq,tf_flry2xp(:),'-', 'DisplayName','flry2xp [/m.s^-^2]')
loglog(par.frq,tf_flrz2xp(:),'-', 'DisplayName','flrz2xp [/m.s^-^2]')

for i=1:N
    loglog(par.frq,tf_amps2xp(i,:).*10^6,'--', 'DisplayName', ['amp' num2str(i) '2xp [/uA]']) % Plot convert to display in uA
    loglog(par.frq,tf_sens2xp(i,:),'-.', 'DisplayName', ['sens' num2str(i) '2xp [/m]'])
end
loglog(par.frq,tf_DAC2xp(:).*10^3,':', 'DisplayName', 'DAC2xp [/mV]') % Plot convert to display in mV

legend('Location','southwest')
xlabel('Frequency [Hz]')
ylabel('Magnitude')
title('Disturbance Path Transfer Function')
xlim([par.Fmin, 1e+3])

fprintf('Solve the DEB...\n')

% Solve DEB
PSD_DAC2xp = (tf_DAC2xp(:).^2).*PSD_DAC; 
PSD_amps2xp = (tf_amps2xp.^2).*repmat(PSD_amp,[1 N])';
PSD_amps2xp = PSD_amps2xp';
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

% Plot PSD contributions to performance channel Xp
fprintf('Plot PSD contributions to performance channel...\n')

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
ylabel('X_P [microns^2/Hz]')
title('PSD: Contribution to Performance Channel')
xlim([par.Fmin, 1e+3])

% Calculate and Plot CPS
fprintf('Calculate and plot CPS...\n')

% Components of system response
CPS_DAC2xp	= cps(PSD_DAC2xp, par.frq);
CPS_amps2xp	= cps(PSD_amps2xp, par.frq);
CPS_flrx2xp	= cps(PSD_flrx2xp, par.frq);
CPS_flry2xp	= cps(PSD_flry2xp, par.frq);
CPS_flrz2xp	= cps(PSD_flrz2xp, par.frq);
CPS_sens2xp	= cps(PSD_sens2xp, par.frq);

% Total system response
CPS_tot2xp  = cps(PSD_tot2xp, par.frq); 

fprintf('<strong>\n--------------- RESULTS ---------------</strong>')

disp(' ')
disp('---------------------------------------')
disp(['TOTAL x_p:          ',num2str(sqrt(CPS_tot2xp(end))*1e6,3),' microns RMS'])
disp('---------------------------------------')
disp('FLOOR')
disp(['from floorX:        ',num2str(sqrt(CPS_flrx2xp(end))*1e6,3),' microns RMS'])
disp(['from floorY:        ',num2str(sqrt(CPS_flry2xp(end))*1e6,3),' microns RMS'])
disp(['from floorZ:        ',num2str(sqrt(CPS_flrz2xp(end))*1e6,3),' microns RMS'])
disp('---------------------------------------')

for i=1:N
    disp(['ACTUATOR ' num2str(i) ])
    disp([['from amp' num2str(i) ':          '],num2str(sqrt(CPS_amps2xp(end,i))*1e6,3),' microns RMS'])
    disp([['from sensor' num2str(i) ':       '],num2str(sqrt(CPS_sens2xp(end,i))*1e6,3),' microns RMS'])
    disp('---------------------------------------')
end
disp(['from DAC:           ',num2str(sqrt(CPS_DAC2xp(end))*1e6,3),' microns RMS'])
disp('---------------------------------------')

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
ylabel('||X_p||^2_R_M_S [microns^2]')
title('CPS: Contribution to Performance Channel')
xlim([par.Fmin, 1e+3])

text(par.frq(end)*1.0,CPS_flrx2xp(end)*1e+12,[num2str(sqrt(CPS_flrx2xp(end))*1e6,3) ' microns'])
text(par.frq(end)*1.0,CPS_flry2xp(end)*1e+12,[num2str(sqrt(CPS_flry2xp(end))*1e6,3) ' microns'])
text(par.frq(end)*1.0,CPS_flrz2xp(end)*1e+12,[num2str(sqrt(CPS_flrz2xp(end))*1e6,3) ' microns'])

for i=1:N
    text(par.frq(end)*1.0,CPS_amps2xp(end,i)*1e+12,[num2str(sqrt(CPS_amps2xp(end,i))*1e6,3) ' microns'])
    text(par.frq(end)*1.0,CPS_sens2xp(end,i)*1e+12,[num2str(sqrt(CPS_sens2xp(end,i))*1e6,3) ' microns'])
end

text(par.frq(end)*1.0,CPS_DAC2xp(end)*1e+12,[num2str(sqrt(CPS_DAC2xp(end))*1e6,3) ' microns'])
text(par.frq(end)*1.0,CPS_tot2xp(end)*1e+12,[num2str(sqrt(CPS_tot2xp(end))*1e6,3) ' microns'])

% Export PSD as CSV 
if saveloc
    varNames = {'Frequency [Hz]'; 'PSD [microns/s^2]^2/Hz'};
    exportTab = table(par.frq, PSD_tot2xp,'VariableNames', varNames);

    fname = string(datetime("today"))+ "_DEB_PSD.csv";
    fullfname = fullfile(saveloc,fname);
    writetable(exportTab,fullfname);  
    fprintf('PSD saved to: %s\n',fullfname)
    
    % Export CPS as CSV
    varNames = {'Frequency [Hz]'; 'CPS microns^2'};
    exportTab = table(par.frq, CPS_tot2xp,'VariableNames', varNames);

    fname = string(datetime("today"))+ "_DEB_CPS.csv";
    fullfname = fullfile(saveloc,fname);
    writetable(exportTab,fullfname);
    fprintf('PSD saved to: %s\n',fullfname)
else
    % nothing
end

end