function exheat(Tout,Tsat,Cp,hfg,mdotmax)
%EXHEAT Calculate power required to vaporise and heat a fluid
%   Calculate the power required to vaporise and heat a fluid. This
%   function displays a colourmap that shows the required power over
%   various mass flow rates and inlet vapour qualities. This function was
%   originally intended for VACCS development.
%
%   Inputs:
%   Tout    - Heater outlet temperature, double
%   Tsat    - Fluid saturation temperature, double
%   Cp      - Fluid specific heat capacity, double
%   hfg     - Fluid latent heat of vaporisation, double
%   mdotmax - Maximum analysis mass flow rate, double
%
%   See also SHAH, PLOSS
%
%   DLSimulink Toolbox

arguments (Input)
    Tout    (1,1) double
    Tsat    (1,1) double
    Cp      (1,1) double
    hfg     (1,1) double
    mdotmax (1,1) double
end

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