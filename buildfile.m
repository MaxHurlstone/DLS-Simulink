function plan = buildfile
import matlab.buildtool.tasks.CodeIssuesTask
import matlab.buildtool.tasks.TestTask

% Create a plan from task functions
plan = buildplan(localfunctions);

projectRoot = currentProject().RootFolder;
plan("doc").Inputs = fullfile(projectRoot, "/doc"); % source folder
plan("doc").Outputs = fullfile(projectRoot, "/toolbox/toolboxdoc"); % destination folder

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

toolboxFolder = fullfile(projectRoot, "toolbox");
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

docin = c.Task.Inputs.Path; % source folder
docout = c.Task.Outputs.Path; % destination folder
md = fullfile(docin,"**","*.md"); % Markdown documents
[html,res] = docconvert(md); % convert to HTML
docrun(html) % run code and insert output
[xml,db] = docindex(doc); % index
mkdir(docout) % make destination folder
arrayfun(@movefile,html,fullfile(docout,extractAfter(html,docin))) % move HTML documents
movefile(res,fullfile(docout,extractAfter(res,docin))) % move resources folder
arrayfun(@movefile,xml,fullfile(docout,extractAfter(xml,docin))) % move index files
movefile(db,fullfile(docout,extractAfter(db,docin))) % move search database folder

end 