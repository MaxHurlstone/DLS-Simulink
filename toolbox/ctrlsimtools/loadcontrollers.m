function loadcontrollers()
%LOADCONTROLLERS Summary of this function goes here
%   Detailed explanation goes here

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