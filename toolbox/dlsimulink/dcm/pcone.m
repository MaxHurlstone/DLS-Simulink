function [pperc] = pcone(scoords,d,t,theta,xdim)
%PCONE Visualise contact pressure for DCM xtal clamping
%   Visualise the contact pressure for a DCM xtal heat exchanger clamping
%   in order to determine the percentage of the contact surface that is
%   actually clamped. This can feed into thermal calculations/simulations
%   where the effective contact area is required.

% Inputs:
%   scoords - screw coordinates, double (:,2)
%   d - screw head diameter, double
%   t - clamping block/heat exchanger thickness, double
%   theta - pressure cone angle, double
%   xdim - clamping block/heat exchanger/xtal dimensions, double (1,2)

% Outputs:
%   pperc - percentage of overall area fully clamped, double
%
%   DLSimulink Toolbox

arguments (Input)
    scoords (:,2) double
    d (1,1) double = 7
    t (1,1) double = 10
    theta (1,1) double = 30
    xdim (1,2) double = [60 40]
end 

arguments (Output)
    pperc (1,1) double
end

% Calculate individual pressure contact diameter
D = d + 2*t*tand(theta);

% Create patch for crystal area
xpatch = polyshape([0 0 1 1]*xdim(1),[1 0 0 1]*xdim(2));

figure()
hold on;

nop = xpatch;
% Loop through fasteners and plot pressure area
for i=1:size(scoords,1)
    ppatch = nsidedpoly(100,Center=scoords(i,:),Radius=D/2);

    pgp = plot(ppatch);
    pgp.FaceColor = [1 0 0];

    % Subtract pressure area from xtal area
    nop = subtract(nop,ppatch);
    
end

plot(nop);

xlabel('x [mm]')
ylabel('y [mm]')

% Calculate areas
xarea = area(xpatch);
parea = xarea - area(nop);

% Calcalate contact percentage
pperc = 100*parea/xarea;

fprintf('Xtal area = %0.0f mm2\n',xarea)
fprintf('Pressure area = %0.0f mm2\n',parea)
fprintf('Pressure area percent = %0.0f %%\n',pperc)

title(sprintf('Pressure area = %0.0f %%\n',pperc))

end