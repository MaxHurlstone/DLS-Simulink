function loadcontrollers()
%LOADCONTROLLERS Loads Shapeit controllers
%   Loads controllers designed in Shapeit. When prompted, select a file.
%   This function imports all Shapeit controllers in that directory into
%   the MATLAB workspace. These controllers can then be accessed in
%   Simulink, for example.
%
%   DLSimulink Toolbox

%% Load file
[~,location] = uigetfile('.mat');

listing = dir(location + "*.mat");

for i=1:length(listing)

    name = listing(i).name;
    folder = listing(i).folder;

    data = load(fullfile(folder,name));

    [~,name,~] = fileparts(name);

    assignin('base',name,data.shapeit_data.C_tf);
end    

end