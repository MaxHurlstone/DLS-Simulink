function sysio = sisotf(system,Ni,No,kext,ts)
%SISOTF Extract SISO from MIMO system
%   Extract SISO system from selected input to selected output, apply
%   gains, and discretise system using a ZOH equivalent Pade approximation.
%
%   Inputs:
%   system - Input MIMO system, ss
%   Ni     - Input variable index, integer
%   No     - Output variable index, integer
%   kext   - External gains, double
%   ts     - System sample time / hardware control rate, double
%
%   Outputs:
%   sysio  - Output SISO system
%
%   See also IMPORTSPM, PLOTSPM
%
%   DLSimulink Toolbox

arguments (Input)
    system (:,:) ss
    Ni (1,1) int32 = 1;
    No (1,1) int32 = 1;
    kext (1,1) double = 1;
    ts (1,1) double = 0.001;
end

arguments (Output)
    sysio (1,1) ss
end

% Extract I/O pair  
sysin = system(No,Ni);

% Create Pade approximation discrete controller implementation
if ts ~= 0
    [numpd, denpd] = pade(ts,10);
    tfpd = tf(numpd,denpd);
else
    tfpd = 1;
end

% Apply Pade and any external gains (electronics, for example)
sysio = tfpd*sysin*kext;
fprintf('TF created for selected I/O pair.\n')

% Plot
figure()
bodeplot(system(No,Ni),bodeopts()); hold on;
bodeplot(sysio,bodeopts());
legend('original','with Pade')

end