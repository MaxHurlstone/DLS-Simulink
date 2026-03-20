% This function creates the .lib file

function buildLibrary

% Save current directory
currFolder = pwd;

% Return to current directory on cleanup
tidyUp = onCleanup(@() cd(currFolder));

% Save current open project root
projRoot = currentProject().RootFolder;

% CD to folder containing custom components
cd(fullfile(projRoot, "toolbox", "csl", "components"));

% Create full path of library file
libraryFileName = fullfile(projRoot, "toolbox", "csl", "library", "DLSimscape");

% Build library
sscbuild("DLSimscape", "-output", libraryFileName);