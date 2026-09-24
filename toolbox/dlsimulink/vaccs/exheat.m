function exheat(Tout,Tsat,Cp,hfg,mdotmax)
%EXHEAT Summary of this function goes here
%   Detailed explanation goes here
% arguments (Input)
%     inputArg1
%     inputArg2
% end
% 
% arguments (Output)
%     outputArg1
%     outputArg2
% end

% Create analysis grid
x = 0:0.01:1;
mdot = 0:(mdotmax/100):mdotmax;

[X,Y] = meshgrid(x,mdot);

% Calculate temperature change
dT = Tout-Tsat;

% Calculate required power grid
Q = Y .* ((1-X).*hfg + (dT*Cp));

% Plot required power as a function of quality and mass flow rate
imagesc(x,mdot,Q)
xlabel('x');
ylabel('Mass flow rate [kg/s]');
zlabel('Power [W]');
grid on;
cb = colorbar();
ylabel(cb,'Power [W]','FontSize',11,'Rotation',270)
set(gca,'YDir','normal')
title('Exhaust Heater Power Requirements')

end