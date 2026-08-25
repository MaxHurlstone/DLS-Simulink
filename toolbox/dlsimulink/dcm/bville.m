function [Rmax] = bville(E,mu,t,De,Di,l0,cfg)
%BVILLE Summary of this function goes here
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

% Find h0
h0 = l0-t;

% Create displacement array
ds = h0/1000;
s = 0:ds:h0;

% Calculate delta
delta = De/Di;

% Calculate coefficients
K1 = (1/pi) * ((delta-1)/delta)^2 / (((delta+1)/(delta-1)) - 2/log(delta));
K2 = (6/pi) * (((delta-1)/(log(delta))) - 1) / log(delta);
K3 = (3/pi) * (delta - 1) / log(delta);
K4 = 1;

% Find force F and stiffness R
F = (4*E/(1-mu^2)) * (t^4/(K1*De^2)) * (s./t).*((K4^2).*(h0/t - s./t).*(h0/t - s./(2*t)) + 1);
R = (4*E/(1-mu^2)) * (t^3/(K1*De^2)) * (K4^2) .* ...
    ((K4^2).*((h0/t)^2 - 3.*(h0/t).*(s./t) + 1.5*(s./t).^2) + 1);

% Solve spring configuration and scale F and s accordingly
cfg = strsplit(cfg,'-');
Fs = str2double(cfg(1)); Ff = str2double(cfg(2));

st = Fs.*s;
Ft = Ff.*F;
Rt = (Ff/Fs).*R;

% Plot
figure()
subplot(2,1,1)
yyaxis left
plot(s.*1e3,F,'k')
ylabel('F [N]')
hold on;
xline(0.75*h0.*1e3,'k--',{'s = 0.75h_0'})

yyaxis right
plot(s.*1e3,R,'r')
ylabel('R [N/m]')

xlabel('s [mm]')
grid on
grid minor
ax = gca;
ax.YAxis(1).Color = 'k';
ax.YAxis(2).Color = 'r';

subplot(2,1,2)
yyaxis left
plot(st.*1e3,Ft,'k')
ylabel('F_t [N]')

yyaxis right
plot(st.*1e3,Rt,'r')
ylabel('R_t [N/m]')

xlabel('s_t [mm]')
grid on
grid minor
ax = gca;
ax.YAxis(1).Color = 'k';
ax.YAxis(2).Color = 'r';

% Calculate maximum total stiffness
Rmax = max(Rt);

end