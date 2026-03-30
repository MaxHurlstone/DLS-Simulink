function system = multidamp(system, modes, multiplications)
%MULTIDAMP Modify system damping ratios
%   Modify a system's damping ratios by a set factor. Feed the function the 
% state space system you want to affect, a list of modes and a list of 
% multipliers for each mode. This function then consecutively takes each
% mode and multiplies that mode's damping by a corresponding multiplier. 
%
%   Inputs:
%   system - input state space, ss
%   modes - modes to edit, array
%   multiplications - factors to edit modes by, array
%
%   Outputs:
%   system
%
%   Example:
%       modes = [2,3]
%       multipliers = [2,0.5]
%       system = multidamp(system, modes, multipliers)
%
%   See also SISOTF, PLOTSPM
%
%   DLSimulink Toolbox

% Number of rows and columns in A matrix
rows = length(system.A);
columns = height(system.A);

% Loop through modes to edit
for count = 1:length(modes)

    % Get row and column index
    rowIndex = rows/2+mode(count);
    columnIndex = columns/2+mode(count);

    % Edit modes
    system.A(rowIndex,columnIndex) = system.A(rowIndex,columnIndex)*multiplications(count) ;
end

end