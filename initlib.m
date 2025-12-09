% Build custom library
sscbuild('DLS_Simscape')

% Load and set params for library
load_system("DLS_Simscape_lib")
set_param("DLS_Simscape_lib","Lock","off")
set_param("DLS_Simscape_lib","EnableLBRepository","on");

% Make library writeable
fileattrib('DLS_Simscape_lib.slx', '+w')

% Save library
save_system("DLS_Simscape_lib");