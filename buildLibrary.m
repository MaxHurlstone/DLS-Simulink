% This function creates the .lib file

function buildLibrary

% Save current directory
currFolder = pwd;

% Return to current directory on cleanup
tidyUp = onCleanup(@() cd(currFolder));

% Save current open project root
projRoot = currentProject().RootFolder;

% CD to folder containing custom components
cd(fullfile(projRoot, "tbx", "ecsl", "components"));

% Create full path of library file
libraryFileName = fullfile(projRoot, "tbx", "ecsl", "library", "DLS_Simscape");

% Build library
sscbuild("DLS_Simscape", "-output", libraryFileName);