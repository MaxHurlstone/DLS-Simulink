function matcompare(varargin)
%MATCOMPARE Compares material properties graphically
%   Takes input material data and plots it, to enable quick comparison of
%   material properties.
%
%   Inputs:
%   varargin - any quantity of valid material database names, string
%
%   See also READMDB, PRINTDB
%
%   DLSimulink Toolbox


figure()

for i=1:length(varargin)

    matname = varargin{i};

    Tdata = readmdb(matname);
    
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