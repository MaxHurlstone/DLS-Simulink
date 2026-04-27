function plan = buildfile
import matlab.buildtool.tasks.CodeIssuesTask
import matlab.buildtool.tasks.TestTask

% Create a plan from task functions
plan = buildplan(localfunctions);

% Make the "archive" task the default task in the plan
plan.DefaultTasks = "archive";

% Make the "archive" task dependent on the "check" and "test" tasks
plan("archive").Dependencies = ["buildlibrary", "doc"];
end

function buildlibraryTask(~)
buildLibrary()
end

function archiveTask(~)

projectRoot = currentProject().RootFolder;

toolboxFolder = fullfile(projectRoot, "toolbox", "dlsimulink");
myUUID = "f1be6fd5-7861-44c4-bfec-a98ded851b12";
opts = matlab.addons.toolbox.ToolboxOptions(toolboxFolder, myUUID);

% Required options
opts.AuthorName = "Maxime Hurlstone";
opts.AuthorEmail = "max.hurlstone@diamond.ac.uk";
opts.ToolboxName = "DLSimulink";
opts.ToolboxVersion = ver("toolbox").Version; % this relies on you have a Content.m file
mltbxFileName = 'dlsimulink.mltbx';
opts.OutputFile = fullfile(projectRoot, 'releases', mltbxFileName);
opts.MinimumMatlabRelease = "R2025b";
opts.ToolboxImageFile = "./images/dlsimulink.png";

% Set up what should be on the path
toAddToPath = genpath( fullfile("toolbox") ); % genpath( fullfile(projectRoot, "toolbox") );
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

function docTask(c)

projectRoot = currentProject().RootFolder;

toolboxFolder = fullfile(projectRoot, "toolbox", "/dlsimulink");
toolboxdocFolder = fullfile(projectRoot, "toolbox", "/dlsimulinkdoc");

% Get .m files in toolbox
fprintf('Finding .m files...\n')
listing = dir(fullfile(toolboxFolder, '**', '*.m'));
N = length(listing);

% Publish options
options = struct('format','html' ...
                 ,'outputDir',toolboxdocFolder ...
                 ,'useNewFigure',false ...
                 ,'evalCode',false ...
                 ,'createThumbnail',false);

fprintf('Found %u .m files.\n',N)

% Clear old documentation
fprintf('Deleting old documentation...\n')
docclear(toolboxdocFolder);% delete(fullfile(toolboxdocFolder,'*.html'))

% Loop through .m files present and publish
fprintf('Publishing code documentation to html...\n')
for n=1:N
    fullfname = fullfile(listing(n).folder,listing(n).name);

    if contains(lower(listing(n).name),"contents") || contains(lower(listing(n).name),"slblocks")
        fprintf('Ignored: %s\n', fullfname)
        continue
    else
        fprintf('Publishing: %s\n', fullfname)
        publish(fullfname,options);
    end
end



end 