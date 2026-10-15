fprintf('\n\n')

S = readlines('dlsascii.txt');

for i=1:length(S)
    disp(S(i))
    pause(0.075)
end    

fprintf('\n\n')
fprintf('----------------- DLSimulink Help -----------------\n')
fprintf('\n')
fprintf(['DLSimulink is a MATLAB toolbox that aims to standardise and streamline\n' ...
    'engineering analysis at the UKs national synchrotron, Diamond Light Source (DLS).\n'])
fprintf('\nThis is a very quick guide to get you started:\n')

fprintf([' 1. Go to the Home tab, and open Add-Ons\n' ...
         ' 2. In the Add-Ons window, search and click on DLSimulink\n' ...
         ' 3. Go to the Functions Tab\n\n' ...
         'This will show you all the MATLAB functions organised by groups.\n' ...
         'You can click on individual functions to see info on each function and the source code.\n' ...
         'A summary of the functionality of each group of functions is given below.\n\n'])

fprintf('MATLAB Functionality:\n')
fprintf(' *ctrlsimtools: importing/configuring/plotting .spm files, reading controllers from shapeit.\n')
fprintf(' *deb: run a Dynamic Error Budget through a standardised function.\n\n')

fprintf('Simulink Functionality:\n')
fprintf(['This toolbox also includes some custom Simscape components:\n' ...
         ' 1. Open a Simulink model\n' ...
         ' 2. Go to the library browser\n' ...
         ' 3. Find "Simscape DLS" to use custom components\n' ...
         'Hint: In Simulink, use "source code" in the description window of the block to see exactly how it works.\n'])

fprintf('\nEnjoy!\n')

fprintf('\nDLSimulink Toolbox | Max Hurlstone\n')

fprintf('\n^^^^^ Expand the Command Window ^^^^^\n')