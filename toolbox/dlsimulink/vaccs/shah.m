function [h_avg,mdot] = shah(q,A,mdotmax,di,n,orien,rhoG,rhoL,muL,cpL,kL,hLG)
%SHAH Shah 1982 Flow Boiling Correlation Calculator
%   Uses the Shah 1982 flow boiling correlation to estimate the
%   average heat transfer coefficient. A contour plot of the Shah
%   correlation over the specified operating conditions is generated. The
%   average heat transfer coefficient is calculated over the specified mass
%   flow rates using the method described below.
%
% Inputs:
%   q - heat flux, double
%   A - heat transfer area, double
%   mdotmax - maximum analysis mass flow rate, double
%   di - inside tube diameter, double
%   n - analysis grid dimensions n x n, int
%   orien - flow orientation: horizontal (1) and vertical (0), bool
%   rhoG - gas density, double
%   rhoL - liquid density, double
%   muL - liquid viscosity, double
%   cpL - liquid specific heat capacity, double
%   kL - liquid conductivity, double
%   hLG - latent heat of vaporisation, double
%
% Outputs:
%   hbar - array of average heat transfer coefficients, double
%   mdot - corresponding array of mass flow rates, double
%
%   More information on average heat transfer coefficient calculation:
%  
%   In his original 1976 paper, Shah describes a simple and reasonably
%   accurate method for determining the average heat transfer coefficient.
%   The average between the inlet and outlet vapour qualities is
%   calculated, and used in the Shah correlation calculations. Even for
%   vapour quality changes of 80%, this method differs from other more
%   robust methods by only 5%. This function assume an inlet vapour quality
%   of 0.
%
%   See also SHAHCALC
%
%   DLSimulink Toolbox

arguments (Input)
    q (1,1) double
    A (1,1) double
    mdotmax (1,1) double
    di (1,1) double
    n (1,1) double
    orien (1,1) logical 
    % Default fluid data for N2 at atmospheric pressure
    rhoG (1,1) double = 4.6
    rhoL (1,1) double = 806
    muL (1,1) double = 1.61e-4
    cpL (1,1) double = 2000
    kL (1,1) double = 0.145
    hLG (1,1) double = 200000
end

arguments (Output)
    h_avg (1,:) double 
    mdot (1,:) double 
end

% Work out cross-sectional flow area
Acs = 0.25*pi*(di^2);

% Calculate mass flux
Gmax = mdotmax/Acs;

% Create mass flux vector
dG = Gmax/n;
Gvec = dG:dG:Gmax;

% Create mass flux vector
dx = 1/n;
x = (dx:dx:1)';

%% Plot Shah correlation for x=0-1 and given mass flow rates
% Create analysis grid
x = repmat(x,1,n);
G = repmat(Gvec,n,1);

% Calculate convection number
C0 = (((1-x)./x).^0.8) * ((rhoG/rhoL)^0.5);

% Calculate 
[h_L,h_tp] = shahcalc(G,x,di,muL,cpL,kL,q,hLG,rhoL,C0,orien);

% Plotting
figure()
surf(C0, G, h_tp./h_L);
xlabel('Convection number (C0)');
ylabel('Mass Flux [kg/m^2s]');
zlabel('\psi = h_{tp}/h_L');
set(gca,'XScale','log')
set(gca,'ZScale','log')
title('Shah \psi plot')
colorbar;

%% Now calculate average heat transfer coeff at each mass flow rate
% Calculate system outlet vapour quality
xout = (q*A)./(Gvec.*Acs.*hLG);
xout(xout > 1) = 1;

% Calculate mass flow rate
mdot = Gvec.*Acs;

% Find first instance of >80% vapour quality change
idxvp = find(xout>0.8,1,'last');

fprintf(['Warning at mdot <= %0.2e kg/s, vapour quality change is > 80%%.' ...
         ' Average vapour quality method may be inaccurate.\n'], mdot(idxvp))

% Calculate average vapour quality, assuming xin = 0
xavg = xout/2;

% Calculate convection number
C0 = (((1-xavg)./xavg).^0.8) * ((rhoG/rhoL)^0.5);

% Recalculate heat transfer coefficient for each mass flux
[~,h_avg] = shahcalc(Gvec,xavg,di,muL,cpL,kL,q,hLG,rhoL,C0,orien);

% Plotting
figure()
yyaxis left
plot(mdot,h_avg,'k-')
ylabel('h_{avg} [W/m^2K]');

yyaxis right
plot(mdot,xout,'r-')
ylabel('x_{out} ');

xlabel('Mass flow [kg/s]');

title('h_{avg}')
grid on
grid minor

ax = gca;

ax.YAxis(1).Color = 'k';
ax.YAxis(2).Color = 'r';

end