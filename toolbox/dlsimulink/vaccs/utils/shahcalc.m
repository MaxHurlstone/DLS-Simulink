function [h_L,h_tp] = shahcalc(G,x,di,muL,cpL,kL,q,hLG,rhoL,C0,orien)
%SHAHCALC Helper function for SHAH
%   Takes an analysis grid of mass flux and vapour quality and calculates
%   the corresponding heat transfer coefficients.
%
%   Not to be used directly.
%
%   See also SHAH
%
%   DLSimulink Toolbox

% Get analysis grid dimensions
P = size(G,1);
Q = size(G,2);

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
h_nb = zeros(P,Q);

% Calculate F constant
Fs = ones(P,Q)*15.43;
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

end