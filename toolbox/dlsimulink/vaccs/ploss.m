function [dp,dparr] = ploss(pipes,mdot)
%PLOSS Calculates pipe friction pressure losses
%   Calculates the total pipe friction losses in a system. 
%
%   Inputs:
%   pipes - Pipe layout, struct (more info below)
%   mdot  - Mass flow rate, double
%
%   Outputs:
%   dp    - Totol pressure loss, double
%   dparr - Pressure loss components, double
%
%   The system pipe layout is represented by a length N structure
%   containing information about each pipe section. The structures fields
%   are given below:
%
%   pipe(i).D      - Pipe section diameter
%   pipe(i).rho    - Pipe section fluid density
%   pipe(i).mu     - Pipe section fluid dynamic viscosity
%   pipe(i).L      - Pipe section length
%   pipe(i).Le     - Pipe section fitting effective length
%
%   See also SHAH
%
%   DLSimulink Toolbox

arguments (Input)
    pipes (:,1) struct
    mdot  (1,1) double
end

arguments (Output)
    dp    (1,1) double
    dparr (:,1) double
end

% Initialise dparr [kPa]
N = length(pipes);
dparr = zeros(1,N);

for i=1:length(pipes)

    % Extract pipe section
    pipe = pipes(i);
    
    % Calculate pipe area
    area = 0.25*pi*(pipe.D^2);

    % Calculate velocity
    vel = mdot / (pipe.rho * area);

    % Calculate Reynolds
    Re = pipe.rho*vel*pipe.D/pipe.mu;

    % Calculate total length
    L = pipe.L + pipe.Le;

    % Use laminar calculation for laminar and transitional flows
    if Re < 10000
        f = 64 / Re;
    % For turbulent flows - use Haaland 1983 explicit
    else
        f = (1.8*log10((6.9/Re) + (pipe.e/3.7*pipe.D)^1.11))^2;
    end

    % Calculate pressure loss for pipe section
    dparr(i) = f * (L / pipe.D) * 0.5 * pipe.rho * vel^2 * 1e-3;

end

% Find total pressure loss
dp = sum(dparr);

end