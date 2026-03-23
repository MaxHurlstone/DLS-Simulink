function [plopts] = bodeopts()
%BODEOPTS Summary of this function goes here
%   Detailed explanation goes here

plopts = bodeoptions;
plopts.FreqUnits = 'Hz';
plopts.PhaseMatching = 'on';
plopts.PhaseMatchingFreq = 0.1;
plopts.Grid = 'on';
plopts.XLim = {[0.1 100000]};

end