function [Tinfo, Tdata] = matprof(matname)
%MATPROFILE Prints short profile of input material
%   The user inputs a material name according to one listed in the
%   database. Max Hurlstone 12-2025
arguments (Input)
    matname (1,1) string   
end

matspec = split(matname,"_");


matpath = "./" + matspec(1) + "/" + matname + ".csv";

opts = delimitedTextImportOptions;
opts.DataLines = [1 6];
Tinfo = readtable(matpath,opts);

opts.DataLines = 6;
opts.VariableNames = {'T', 'k'};
Tdata = readtable(matpath,opts);

% Loop through data and plot
figure()
x = Tdata{:,1};
Y = table2array(Tdata(:,2:end));

plot(x,Y)

end