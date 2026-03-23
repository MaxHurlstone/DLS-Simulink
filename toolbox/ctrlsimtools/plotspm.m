function plotspm(system)
%PLOTSPM Plots imported system state space

fprintf('Loading bodeplot of system...\n')

figure()
bodeplot(system,bodeopts())

end