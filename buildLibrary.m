% This function creates the .lib file

function buildLibrary

% Save current directory
currFolder = pwd;

% Return to current directory on cleanup
tidyUp = onCleanup(@() cd(currFolder));

% Save current open project root
projRoot = currentProject().RootFolder;

% CD and build the SSC library
% DO NOT CHANGE NAME (SSClib) OF THIS INTERMEDIATE LIBRARY
sscLibPath = fullfile(projRoot, "toolbox", "dlsimulink", "csl", "library", "SSClib");

% CD into SSC raw code folder and generate library
cd(fullfile(projRoot, "toolbox", "dlsimulink", "csl", "components"));
sscbuild("DLSimscape", "-output", sscLibPath);
cd(fullfile(projRoot));

% Load and find main subsystem in generated SSC library
load_system(sscLibPath);

source = find_system(sscLibName,"SearchDepth", 1,"Type", "Block");
source = string(source);

subSysName = extractAfter(source, "/");
subSysName = string(subSysName);

% Load working main library and insert SSC library
dlsLibName = "DLSlib";

load_system(dlsLibName)
set_param(dlsLibName,"Lock","off");

destination = join([dlsLibName, subSysName], "/");
add_block(source, destination, "MakeNameUnique", "on",...
          "CopyOption", "nolink");

% Save and lock
save_system(dlsLibName);

% Delete intermediate SSC library
delete SSClib.slx