function printdb()
%PRINTDB Prints materials in the database
%   Max Hurlstone 12-2025

tbl = struct2table(dir(pwd + "\Materials\**"));
files = tbl(~tbl.isdir,:);

fprintf('List of materials in database:\n')
disp(files.name)

end