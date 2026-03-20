function plan = buildfile
import matlab.buildtool.tasks.CodeIssuesTask
import matlab.buildtool.tasks.TestTask

% Create a plan from task functions
plan = buildplan(localfunctions);

% Add the "check" task to identify code issues
plan("check") = CodeIssuesTask;

% Add the "test" task to run tests
plan("test") = TestTask;

% Make the "archive" task the default task in the plan
plan.DefaultTasks = "archive";

% Make the "archive" task dependent on the "check" and "test" tasks
plan("archive").Dependencies = ["check", "test", "buildlibrary"];
end

function buildlibraryTask(~)
buildLibrary()
end

function archiveTask(~)

projectRoot = currentProject().RootFolder;

toolboxFolder = fullfile(projectRoot, "toolbox");
myUUID = "f1be6fd5-7861-44c4-bfec-a98ded851b12";
opts = matlab.addons.toolbox.ToolboxOptions(toolboxFolder, myUUID);

% Required options
opts.AuthorName = "Maxime Hurlstone";
opts.AuthorEmail = "max.hurlstone@diamond.ac.uk";
opts.ToolboxName = "DLSimscape";
opts.ToolboxVersion = ver("toolbox").Version; % this relies on you have a Content.m file
mltbxFileName = 'dlsimscape.mltbx';
opts.OutputFile = fullfile(projectRoot, 'releases', mltbxFileName);
opts.MinimumMatlabRelease = "R2024a";
opts.ToolboxImageFile = "./images/dlsimulink.png";

% Set up what should be on the path
toAddToPath = genpath( fullfile(projectRoot, "toolbox") );
toAddToPath = string( split(toAddToPath(1:end-1), ";") );
opts.ToolboxMatlabPath = toAddToPath;

% Optional stuff
% opts.ToolboxGettingStartedGuide = ""; % path to guide
% Set what you need
% opts.GalleryFiles = "";
% opts.AuthorCompany = "";
% opts.Description = "";
% opts.RequiredAdditionalSoftware = "";
% opts.RequiredAddons = "";
% opts.Summary = "";
% opts.SupportedPlatforms = "";
% opts.ToolboxFiles = "";
% opts.ToolboxJavaPath = "";
% opts.MaximumMatlabRelease = "";

% Package
matlab.addons.toolbox.packageToolbox(opts)

% Add license
% lic = fileread("./LICENSE");
% mlAddonSetLicense( char(opts.OutputFile), struct( "type", 'MLL', "text", lic ) );

end