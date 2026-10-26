fprintf('\n\n')

S = readlines('dlsascii.txt');

for i=1:length(S)
    disp(S(i))
    pause(0.075)
end    

fprintf('\n\n')
fprintf('----------------- DLSimulink Help -----------------\n')
fprintf('\n')
fprintf(['DLSimulink is a MATLAB toolbox that aims to standardise engineering analysis \n' ...
         'at the UKs national synchrotron, Diamond Light Source (DLS).\n' ...
        'For questions on how to use certain functions/apps speak to Max Hurlstone.\n\n'])

fprintf('There is no documentation, but to see the commented toolbox code:\n')
fprintf([' 1. Go to the Home tab, and open Add-Ons\n' ...
         ' 2. In the Add-Ons window, search and click on DLSimulink\n' ...
         ' 3. Go to the Functions Tab\n\n' ...
         'This will show you all the MATLAB functions organised by groups.\n' ...
         'You can click on individual functions to see info on each function and the source code.\n' ...
         'A summary of the toolbox functionality is given below.\n\n'])

fprintf('Custom Apps:\n')
fprintf('This toolbox includes some apps to help with engineering design processes:\n')
fprintf(' *KCAApp:       Kinematic Coupling App for kinematic coupling design calculations.\n')
fprintf(' *SPP:          Silicon Post Processor for analysing ANSYS slope error data for optics.\n\n')

fprintf('MATLAB Functions (by subfolder):\n')
fprintf(' *ctrlsimtools: importing/configuring/plotting .spm files, reading controllers from shapeit.\n')
fprintf(' *dcm:          miscellaneous DCM calculations.\n')
fprintf(' *deb:          run a Dynamic Error Budget for motion systems.\n')
fprintf(' *utils:        utility functions.\n')
fprintf(' *vaccs:        functions for VACCS design.\n\n')

fprintf('Simulink Functionality:\n')
fprintf(['This toolbox also includes some custom Simscape components:\n' ...
         ' 1. Open a Simulink model\n' ...
         ' 2. Go to the library browser\n' ...
         ' 3. Find "Simscape DLS" to use custom components\n' ...
         'Hint: In Simulink, use "source code" in the description window of the block to see exactly how it works.\n'])

fprintf('\nDLSimulink Toolbox | Max Hurlstone\n')

fprintf('\n^^^^^ Expand the Command Window ^^^^^\n')