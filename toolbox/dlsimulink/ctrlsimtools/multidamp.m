function [system,Amult] = multidamp(sysin, modes, multipliers)
%MULTIDAMP Modify system damping ratios
%   Modify a system's damping ratios by a set factor. Feed the function the 
%   state space system you want to affect, a list of modes and a list of 
%   multipliers for each mode. This function then consecutively takes each
%   mode and multiplies that mode's damping by a corresponding multiplier. 
%
%   Inputs:
%   system - input state space, ss
%   modes - modes to edit, array
%   multipliers - factors to edit modes by, array
%
%   Outputs:
%   system
%   Amult
%
%   See also SISOTF, PLOTSPM
%
%   DLSimulink Toolbox

arguments (Input)
    sysin (:,:) ss
    modes (:,1) int32
    multipliers (:,1) double
end 

arguments (Output)
    system (:,:) ss
    Amult (:,:) double
end  

% Set system to current system
system = sysin;

% Get number of modes
Nm = size(system.A,1)/2;

% Create vector for diagonal with multipliers at mode positions
vmult = ones(1,Nm);
vmult(modes) = multipliers;

% Assign vector to diagonal matrix
Amult = diag(vmult);

% Element-wise multiply original A matrix with multiplier matrix
system.A(Nm+1:end,Nm+1:end) = sysin.A(Nm+1:end,Nm+1:end).*Amult;

end