function [outputArg1,outputArg2] = propgen(inputArg1,inputArg2)
%PROPGEN Generates thermal property data from database
%   Generates thermal property data vector (e.g. conductivity), along with
%   the corresponding temperature vector. This function is intended to be
%   used to initialise Simscape blocks.
%
%   Inputs:
%
%   Outputs:
%
%   See also MATCOMPARE, PRINTDB
%
%   DLSimulink Toolbox

arguments (Input)
    inputArg1
    inputArg2
end

arguments (Output)
    outputArg1
    outputArg2
end

outputArg1 = inputArg1;
outputArg2 = inputArg2;
end