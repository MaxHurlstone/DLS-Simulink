function [plopts] = bodeopts()
%BODEOPTS Sets bodeplot options for DLSimulink
%
%   DLSimulink Toolbox

plopts = bodeoptions;
plopts.FreqUnits = 'Hz';
plopts.PhaseMatching = 'on';
plopts.PhaseMatchingFreq = 0.1;
plopts.Grid = 'on';
plopts.XLim = {[0.1 100000]};

end