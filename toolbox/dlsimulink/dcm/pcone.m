function [D] = pcone(scoords,d,t,theta,xdim)
%PCONE Summary of this function goes here
%   Detailed explanation goes here

arguments (Input)
    scoords (:,2) double
    d (1,1) double = 7
    t (1,1) double = 10
    theta (1,1) double = 30
    xdim (1,2) double = [60 40]
end 

% Calculate individual pressure contact diameter
D = d + 2*t*tand(theta);

% Create patch for crystal area
xpatch = polyshape([0 0 1 1]*xdim(1),[1 0 0 1]*xdim(2));

nop = xpatch;
% Loop through fasteners and plot pressure area
for i=1:size(scoords,1)
    ppatch = nsidedpoly(100,Center=scoords(i,:),Radius=D/2);

    % Subtract pressure area from xtal area
    nop = subtract(nop,ppatch);
    
end

figure()
plot(nop)

% Calculate areas
xarea = area(xpatch);
parea = xarea - area(nop);

fprintf('Xtal area = %0.0f mm2\n',xarea)
fprintf('Pressure area = %0.0f mm2\n',parea)
fprintf('Pressure area percent = %0.0f %%\n',100*parea/xarea)

end