function system = importspm(Norder, doplot, file)
%IMPORTSPM Import ANSYS spm
%   Import an ANSYS .spm file into a MATLAB state space variable.
%
%   Inputs:
%   doplot - Configure if bode plot is generated, boolean (default 0)
%   Norder - Order of reduced order model, integer (default 0)
%
%   Outputs:
%   system - MATLAB state space
%
%   See also SISOTF, PLOTSPM
%
%   DLSimulink Toolbox

arguments (Input)
    Norder (1,1) int32 = 0
    doplot (1,1) logical = 0
    file (1,1) string = ""
end

arguments (Output)
    system (:,:) ss
end

% Load file
if file == ""
    [file,location] = uigetfile('.spm');
else
    location = "./SPMs/";
end

linarr = strip(readlines(fullfile(location,file)));

% Identify sections of spm data
% Find locations of input/output labels
idxi = find(strcmp("INPUT LABELS", linarr));
idxo = find(strcmp("OUTPUT LABELS", linarr));

% Find locations of A,B,C,D matrices
idxa = find(strcmp("A MATRIX", linarr));
idxb = find(strcmp("B MATRIX", linarr));
idxc = find(strcmp("C MATRIX", linarr));
idxd = find(strcmp("D MATRIX", linarr));

% Extract data
% Extract A matrix data
dims = sscanf(linarr(idxa+1),'%f');
n = dims(1);
A = zeros(n,n);

count_A = dims(3);
for i = 1:count_A
    entry = sscanf(linarr(idxa+1+i),'%f');
    A(entry(1),entry(2)) = entry(3);
end

% Extract B matrix data
dims = sscanf(linarr(idxb+1),'%f');
r = dims(2);
B = zeros(n,r);

count_B = dims(3);
for i = 1:count_B
    entry = sscanf(linarr(idxb+1+i),'%f');
    B(entry(1),entry(2)) = entry(3);
end

% Extract C matrix data
dims = sscanf(linarr(idxc+1),'%f');
m = dims(1);
C = zeros(m,n);

count_C = dims(3); 
for i = 1:count_C
    entry = sscanf(linarr(idxc+1+i),'%f');
    C(entry(1),entry(2)) = entry(3);
end

% Extract D matrix data
dims = sscanf(linarr(idxd+1),'%f');
m = dims(1);
D = zeros(m,r); 

count_D = dims(3); 
for i = 1:count_D
    entry = sscanf(linarr(idxd+1+i),'%f');
    D(entry(1),entry(2)) = entry(3);
end

% Extract input label data
u = linarr(idxi+1:idxi+r);

% Extract output label data
p = m/3;
ids = repmat(["_DISP" "_VEL" "_ACC"]',p,1);
outputs = repelem(linarr(idxo+1:idxo+p),3);

y = strcat(outputs,ids);

% Create state space

% Create state space
system = ss(A,B,C,D);
system.u = u;
system.y = y;

% Reduce order of state space
if Norder == 0
    % Do not reduce model order
else
    % Reduce model order
    R = reducespec(system,"balanced");
    system = getrom(R,Order=Norder);
end

% Assign to workspace
fprintf('State space generated.\n')

if doplot
    plotspm(system)
end

end