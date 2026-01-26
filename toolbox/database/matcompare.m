function matcompare(varargin)
%MATCOMPARE Compares material properties graphically
%   Max Hurlstone 12-2025

figure()

for i=1:length(varargin)

    matname = varargin{i};

    matspec = split(matname,"_");
    matpath = pwd + "\Materials\" + matspec(1) + "\" + matname + ".csv";
    
    opts = delimitedTextImportOptions;  
    opts.DataLines = 6;
    opts.VariableNames = {'T', 'k'};
    Tdata = readtable(matpath,opts);
    
    x = Tdata{:,1};
    x = cell2mat(cellfun(@(x) str2double(x), x, 'UniformOutput', false));
    Y = table2array(Tdata(:,2:end));
    Y = cell2mat(cellfun(@(x) str2double(x), Y, 'UniformOutput', false));
    
    plot(x,Y,'DisplayName',matname); hold on;
    grid on
    grid minor
    xlabel('T [K]')
    ylabel('k [W/mK]')

end

title('Material Comparison')
legend('Interpreter','latex')

end