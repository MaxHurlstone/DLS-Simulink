function [mdata] = readmdb(matname)
%READMDB Read material database and return it as a formatted table
%   Takes a material name and extracts data from the .csv file in the
%   database. It then returns this data as a table.
%
%   Inputs:
%   matname - material database name, string
%
%   See also MATCOMPARE, PRINTDB
%
%   DLSimulink Toolbox

arguments (Input)
    matname (1,1) string
end

arguments (Output)
    mdata (:,:) table
end

matspec = split(matname,"_");
matpath = "\Materials\" + matspec(1) + "\" + matname + ".csv";

opts = delimitedTextImportOptions;  
opts.DataLines = 6;
opts.VariableNames = {'T', 'k'};
mdata = readtable(matpath,opts);

end