function printdb()
%PRINTDB Prints materials in the database
%   Prints all materials in the database.
%
%   See also MATCOMPARE, PROPGEN
%
%   DLSimulink Toolbox

fpath = fileparts(mfilename('fullpath'));

tbl = struct2table(dir(fpath + "\Materials\**"));
files = tbl(~tbl.isdir,:);

fprintf('List of materials in database:\n')
disp(files.name)

end