% Build custom library
sscbuild('Custom')

% Load and set params for library
load_system("Custom_lib")
set_param("Custom_lib","Lock","off")
set_param("Custom_lib","EnableLBRepository","on");
save_system("Custom_lib");
fileattrib('Custom_lib.slx', '+w')