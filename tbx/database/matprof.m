function [Tinfo, Tdata] = matprof(matname)
%MATPROF Prints profile of chosen material
%   Max Hurlstone 12-2025

arguments (Input)
    matname (1,1) string   
end

matspec = split(matname,"_");
matpath = pwd + "\Materials\" + matspec(1) + "\" + matname + ".csv";

opts = delimitedTextImportOptions;
opts.DataLines = [1 6];
Tinfo = readtable(matpath,opts);

opts.DataLines = 6;
opts.VariableNames = {'T', 'k'};
Tdata = readtable(matpath,opts);

x = Tdata{:,1};
x = cell2mat(cellfun(@(x) str2double(x), x, 'UniformOutput', false));
Y = table2array(Tdata(:,2:end));
Y = cell2mat(cellfun(@(x) str2double(x), Y, 'UniformOutput', false));

figure()
plot(x,Y)
grid on
grid minor
xlabel('T [K]')
ylabel('k [W/mK]')
title(matname,'Interpreter','latex')

end