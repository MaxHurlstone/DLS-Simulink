function [hbar] = shah(q,mdot,di,rhoG,rhoL,muL,cpL,kL,hLG,n)
%SHAH Summary of this function goes here
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

% Create vapour quality vector
dx = 1/n;
x = (dx:dx:1)';

% Calculate Shah C0 factor
C0 = (((1-x)./x).^0.8) * ((rhoG/rhoL)^0.5);
N = C0;

% Calculate Froude
FrL = (mdot*mdot) / (rhoL*rhoL*9.81*di);

% Calculate effective liquid only Reynolds number and Prandtl number
ReL = (mdot.*(1-x).*di) ./ muL;
PrL = (cpL*muL) / kL;

% Calculate a_L using Dittus-Boelter
a_L = 0.023 * (ReL.^0.8) * (PrL.^0.4) * (kL/di);

% Calculate convective boiling a_cb
a_cb = a_L.*(1.8./(N.^0.8));

% Calculate boiling number
Bo = q/(mdot*hLG);

% Calculate Fs
if Bo > 0.0011
    Fs = 14.7;
else
    Fs = 15.43;
end

a_nb = zeros(n,1);

for i=1:n
    Ni = N(i);
    a_Li = a_L(i);

    % Calculate nucleate boiling a_nb
    if Ni > 1
    
        if Bo > 0.0003
            a_nb(i) = 230*(Bo^0.5)*a_Li;
        else
            a_nb(i) = (1 + (46*(Bo^0.5)))*a_Li;
        end
    
    elseif (0.1 < Ni) && (Ni < 1)
         a_nb(i) = (Fs*(Bo^0.5)*exp((2.74*Ni) - 0.1))*a_Li;
    
    elseif Ni < 0.1
        a_nb(i) = (Fs*(Bo^0.5)*exp((2.74*Ni) - 0.15))*a_Li;
    end

end

% Calculate local heat transfer coefficient
a_tp = max(a_nb,a_cb);

% Calcualte average heat transfer coefficient
hbar = mean(a_tp);

figure()
plot(x,a_tp./a_L); hold on;
grid on
xlabel('x')
ylabel('a_tp/a_L')


end