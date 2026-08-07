function [hbar,mdot] = shah(q,A,mdotmax,di,n,orien,rhoG,rhoL,muL,cpL,kL,hLG)
%SHAH Shah 1982 Flow Boiling Correlation Calculator
%   Uses the Shah 1982 pre-dryout flow boiling correlation to estimate the
%   local heat transfer coefficient. Surface plots show the variation of
%   this quantity against both mass flow rate and vapour quality. An average
%   heat transfer coefficient for a range of mass flow rates is calculated
%   and returned. More detail on how the average heat transfer coefficient
%   is calculated is given below.
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
%   The input power is used to estimate the process outlet vapour quality: 
%   xout = qA/mdot*hLG
%   In the grid of data, if the vapour quality is greater than this value,
%   or if it is greater than an assumed xcrit = 0.5 (dryout), the
%   corresponding local heat transfer coefficient is set to zero. The
%   average is then done along vapour quality, for each mass flow rate
%   column.
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
    hbar (1,:) double 
    mdot (1,:) double 
end

% Work out cross-sectional flow area
Acs = 0.25*pi*(di^2);

% Calculate mass flux
Gmax = mdotmax/Acs;

% Create analysis grid for mass flow and vapour quality
dx = 1/n;
x = (dx:dx:1)';

dG = Gmax/n;
G = dG:dG:Gmax;

x = repmat(x,1,n);
G = repmat(G,n,1);

% Calculate Shah C0 factor
C0 = (((1-x)./x).^0.8) * ((rhoG/rhoL)^0.5);

% Calculate effective liquid only Reynolds number and Prandtl number
ReL = (G.*(1-x).*di) ./ muL;
PrL = (cpL*muL) / kL;

% Calculate h_L using Dittus-Boelter
h_L = 0.023 * (ReL.^0.8) * (PrL.^0.4) * (kL/di);

% Calculate boiling number
Bo = q./(G.*hLG);

% Calculate Froude
FrL = (G.*G) ./ (rhoL*rhoL*9.81*di);

% Adjust N and show warning if conditions not valid
N = C0;
if orien 
    FrLbool = FrL < 0.04;
    N(FrLbool) = 0.38.*(FrL(FrLbool).^(-0.3)).*C0(FrLbool);

    if any(Bo < 0.0001)
        fprintf('Conditions fall outside of the model validity.\n')
    end    
end

% Calculate convective boiling h_cb
h_cb = h_L.*(1.8./(N.^0.8));

% Preallocate h_nb
h_nb = zeros(n);

% Calculate F constant
Fs = ones(n)*15.43;
Fs(Bo > 0.0011) = 14.7;

% Case 1 N > 1
bool_1 = N > 1;
% Case 2 N > 1 & Bo > 0.0003
bool_2 = bool_1 & (Bo > 0.0003);
% Case 3 0.1 < N < 1
bool_3 = (0.1 < N) & (N < 1);
% Case 4 N < 0.1
bool_4 = N < 0.1;

% Evaluate all cases
h_nb(bool_1) = (1 + (46.*(Bo(bool_1).^0.5))).*h_L(bool_1);
h_nb(bool_2) = 230.*(Bo(bool_2).^0.5).*h_L(bool_2);
h_nb(bool_3) = (Fs(bool_3).*(Bo(bool_3).^0.5).*exp(2.74.*(N(bool_3).^(-0.1)))).*h_L(bool_3);
h_nb(bool_4) = (Fs(bool_4).*(Bo(bool_4).^0.5).*exp(2.47.*(N(bool_4).^(-0.15)))).*h_L(bool_4);

% Calculate local heat transfer coefficient by max of h_cb and h_nb
h_tp = max(h_nb,h_cb);

% Calculate system outlet vapour quality
xout = (q*A)./(G.*Acs.*hLG);
xout(xout > 1) = 1;

h_tp_actual = h_tp;
h_tp_actual(x > xout) = nan;
h_tp_actual(x > 0.5) = nan; % assuming dryout at x = 0.5

% Calculate final return data
mdot = G(1,:).*Acs;
hbar = mean(h_tp_actual,1,'omitmissing');

% Plotting
figure()
surf(C0, G, h_tp./h_L);
xlabel('Convection number (C0)');
ylabel('Mass Flux (G)');
zlabel('\psi = h_{tp}/h_L');
set(gca,'XScale','log')
set(gca,'ZScale','log')
title('Shah \psi plot')
colorbar;

figure()
surf(x, G, h_tp,'FaceAlpha',0.1,'EdgeAlpha',0.1); hold on
h_tp_actual(isnan(h_tp_actual))=0;
surf(x, G, h_tp_actual);
plot3(ones(1,n),G(1,:),hbar,'LineWidth',5,'Color','r')
xlabel('Vapour quality (x)');
ylabel('Mass Flux (G)');
zlabel('Local Heat Transfer Coefficient (h_{tp})');
set(gca,'XScale','log')
set(gca,'ZScale','log')
title('Plot of local h_{tp} - "out-of-heat-exchanger" values suppressed')
colorbar;

figure()
plot(mdot,hbar)
xlabel('Mass flux [kg/s]');
ylabel('Avergae h [W/m2K]');
title('Average h_{tp}')
grid on

end