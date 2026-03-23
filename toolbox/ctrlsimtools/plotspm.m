function plotspm(system)
%PLOTSPM Plots imported system state space

fprintf('Loading bodeplot of system...\n')

plopts = bodeoptions;
plopts.FreqUnits = 'Hz';
plopts.PhaseVisible = 'off';

figure()
bodeplot(system,plopts)
xlim([0.1 10000])
grid on

end