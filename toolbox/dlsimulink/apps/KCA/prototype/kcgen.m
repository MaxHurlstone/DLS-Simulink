%% kcgen.m - Kinematic Coupling Design
% Parametric design studies of three-groove kinematic couplings.
% Applies to standard symmetric (equal angle, equal groove) and asymmetric
% couplings.  Adapted from kincoup.xls by John Hart, MIT PERG, March 2001.
% All metric units (N-m-s).

%% Configuration & Materials

% Symmetry flag: 1 = symmetric (equilateral, equal radius, equal preload,
%                 all balls same material, all grooves same material)
%                 0 = asymmetric (individual data entry required)
symmetric = 1;

% ----- Ball materials ----------------------------------------------------
% Hertz limit (Pa), elastic modulus (Pa), Poisson ratio
% Set 'Matball' to 1=Carbide  2=Plastic  3=RC62 Steel  4=RC57 420 Stainless
Matball = [2.758e9, 3.103e11, 0.3];    % Carbide
Matball(2,:) = [1.034e8, 1.034e10, 0.2]; % Plastic
Matball(3,:) = [1.724e9, 2.041e11, 0.29];% RC62 Steel
Matball(4,:) = [1.36e9*0.75, 2.0e11, 0.29];% RC57 420 Stainless
Matball(5,:) = [2.758e9, 3.103e11, 0.3]; % Other (dummy = carbide)

% ----- Groove materials --------------------------------------------------
% Same format as ball materials above
% Set 'Matgrv' using same index scheme
Matgroove = [2.758e9, 3.103e11, 0.3];    % Carbide
Matgroove(2,:) = [1.034e8, 1.034e10, 0.2]; % Plastic
Matgroove(3,:) = [1.724e9, 2.041e11, 0.29];% RC62 Steel
Matgroove(4,:) = [1.36e9*0.75, 2.0e11, 0.29];% RC57 420 Stainless
Matgroove(5,:) = [2.758e9, 3.103e11, 0.3]; % Other (dummy = carbide)

% ----- Material selection ------------------------------------------------
% All grooves are the same material; all balls are the same material
Matgrv = 3;  % groove material index (RC62 Steel)
Matbal = 1;  % ball material index (Carbide)

%% Disturbance Loads

FLx = 0;  % applied force (N), X component
FLy = 0;  % applied force (N), Y component
FLz = 0;  % applied force (N), Z component
MLx = 0;  % applied torque (N-m), X component
MLy = 0;  % applied torque (N-m), Y component
MLz = 0;  % applied torque (N-m), Z component

XL = 0;   % X coordinate of load application point (m)
YL = 0;   % Y coordinate of load application point (m)
ZL = 0;   % Z coordinate of load application point (m)

Xerr = 0; % X coordinate of error reporting point (m)
Yerr = 0; % Y coordinate of error reporting point (m)
Zerr = 0; % Z coordinate of error reporting point (m)

%% Coupling Geometry Data

% Per-coupling geometry parameters (index 1,2,3 for the three couplings)
r = [0.025, 0.025, 0.025];               % radial coordinate (m)
th = [pi/2, 7*pi/6, 11*pi/6];            % angular coordinate (rad)
thg = [pi/4, pi/4, pi/4];                % groove angle (rad)
Dball = [0.008, 0.008, 0.008];           % equivalent ball diameter (m)
Rbminor = Dball / 2;                      % minor ball radius (m)
Rbmajor = Dball / 2;                      % major ball radius (m)
Rgrv = [1000000, 1000000, 1000000];       % groove radius (m, negative for trough)

% Preload
Fpx = [0, 0, 0];
Fpy = [0, 0, 0];
Fpz = [-100, -100, -100];
rp_pre = r;                               % preload radial coordinate (m)
thp_pre = th;                             % preload angular coordinate (rad)

% ----- Symmetric override ------------------------------------------------
% When symmetric=1, propagate coupling-1 parameters to couplings 2 and 3
if symmetric == 1
    r(2:3) = r(1);
    th(2) = th(1) + 2*pi/3;  th(3) = th(1) + 4*pi/3;
    thg(2:3) = thg(1);
    Dball(2:3) = Dball(1);
    Rbminor(2:3) = Rbminor(1);
    Rbmajor(2:3) = Rbmajor(1);
    Rgrv(2:3) = Rgrv(1);
    Fpx(2:3) = Fpx(1);  Fpy(2:3) = Fpy(1);  Fpz(2:3) = Fpz(1);
    rp_pre(2:3) = rp_pre(1);
    thp_pre(2) = thp_pre(1) + 2*pi/3;  thp_pre(3) = thp_pre(1) + 4*pi/3;
end

%% Contact Geometry & Direction Cosines

% Contact coordinates and direction cosines for all 6 ball-groove contacts
% Order: a,b from coupling 1; c,d from coupling 2; e,f from coupling 3
Xb = zeros(1,6);  Yb = zeros(1,6);  Zb = zeros(1,6);
Ab = zeros(1,6);  Bb = zeros(1,6);  Gb = zeros(1,6);
for j = 1:3
    k = 2*j - 1;
    Xb(k)   = r(j)*cos(th(j)) + Dball(j)*sqrt(2)*sin(th(j))/4;
    Xb(k+1) = r(j)*cos(th(j)) - Dball(j)*sqrt(2)*sin(th(j))/4;
    Yb(k)   = r(j)*sin(th(j)) - Dball(j)*sqrt(2)*cos(th(j))/4;
    Yb(k+1) = r(j)*sin(th(j)) + Dball(j)*sqrt(2)*cos(th(j))/4;
    Zb(k)   = -Dball(j)*sqrt(2)/4;
    Zb(k+1) = -Dball(j)*sqrt(2)/4;
    tden = sqrt(1 + tan(thg(j))^2);
    Ab(k)   = -sin(th(j)) / tden;
    Ab(k+1) =  sin(th(j)) / tden;
    Bb(k)   =  cos(th(j)) / tden;
    Bb(k+1) = -cos(th(j)) / tden;
    Gb(k)   =  tan(thg(j)) / tden;
    Gb(k+1) =  tan(thg(j)) / tden;
end

% Preload point coordinates
xp_pre = rp_pre .* cos(thp_pre);
yp_pre = rp_pre .* sin(thp_pre);
zp_pre = 2 * Dball;

% Per-coupling material and contact ellipse properties (shared by both
% contacts of each coupling)
S = zeros(1,3);  Ee = zeros(1,3);  Re = zeros(1,3);
theta_c = zeros(1,3);  alpha = zeros(1,3);  beta = zeros(1,3);
lambda = zeros(1,3);

for j = 1:3
    Eg = Matgroove(Matgrv,2);  vg = Matgroove(Matgrv,3);
    Eb = Matball(Matbal,2);    vb = Matball(Matbal,3);
    S(j) = min(Matgroove(Matgrv,1), Matball(Matbal,1));
    Ee(j) = 1 / ((1-vg^2)/Eg + (1-vb^2)/Eb);
    Re(j) = 1 / (1/Rgrv(j) + 1/Rbminor(j) + 1/Rbmajor(j));
    ct = Re(j) * sqrt((1/Rgrv(j))^2 + (1/Rbmajor(j)-1/Rbminor(j))^2 ...
        + 2*(-1/Rgrv(j))*(1/Rbmajor(j)-1/Rbminor(j)));
    theta_c(j) = acos(ct);
    alpha(j) = 1.939*2.71831^(-5.26*theta_c(j)) + 1.78*2.71831^(-1.09*theta_c(j)) ...
        + 0.723/theta_c(j) + 0.221;
    beta(j) = 35.228*2.71831^(-0.98*theta_c(j)) - 32.424*2.71831^(-1.0475*theta_c(j)) ...
        + 1.486*theta_c(j) - 2.634;
    lambda(j) = -0.214*2.71831^(-4.95*theta_c(j)) - 0.179*theta_c(j)^2 ...
        + 0.555*theta_c(j) + 0.319;
end

%% Interface Force-Deflection Calculations

% Build force-moment equilibrium matrix A and load vectors B
% Solves A*F = B for contact forces at all six ball-groove contacts
A = [Ab; Bb; Gb; -Bb.*Zb + Gb.*Yb; Ab.*Zb - Gb.*Xb; -Ab.*Yb + Bb.*Xb];

% RHS with applied loads
Bwithloads = [-(sum(Fpx) + FLx); ...
    -(sum(Fpy) + FLy); ...
    -(sum(Fpz) + FLz); ...
    -(-sum(Fpy .* zp_pre) + sum(Fpz .* yp_pre) - FLy*ZL + FLz*YL + MLx); ...
    -(sum(Fpx .* zp_pre) - sum(Fpz .* xp_pre) + FLx*ZL - FLz*XL + MLy); ...
    -(-sum(Fpx .* yp_pre) + sum(Fpy .* xp_pre) - FLx*YL + FLy*XL + MLz)];

% RHS without applied loads (preload only)
Bnoloads = [-sum(Fpx); -sum(Fpy); -sum(Fpz); ...
    -(-sum(Fpy .* zp_pre) + sum(Fpz .* yp_pre)); ...
    -(sum(Fpx .* zp_pre) - sum(Fpz .* xp_pre)); .C0//ap..
    -(-sum(Fpx .* yp_pre) + sum(Fpy .* xp_pre))];

% Contact forces: with loads (Fbn) and preload-only (Fb)
Fbn = A \ Bwithloads;
Fb  = A \ Bnoloads;

% ----- Ball deflections -------------------------------------------
% Difference in deflection between loaded and preload-only states
del = zeros(1,6);
for c = 1:6
    j = ceil(c/2);
    del(c) = lambda(j)*(2*Fbn(c)^2/(3*Re(j)*Ee(j)^2))^(1/3) ...
           - lambda(j)*(2*Fb(c)^2/(3*Re(j)*Ee(j)^2))^(1/3);
end

% ----- Contact ellipse radii --------------------------------------
rmaj = zeros(1,6);
rmin = zeros(1,6);
for c = 1:6
    j = ceil(c/2);
    rmaj(c) = alpha(j)*(1.5*Fbn(c)*Re(j)/Ee(j))^(1/3);
    rmin(c) = beta(j)*(1.5*Fbn(c)*Re(j)/Ee(j))^(1/3);
end

% ----- Contact stresses -------------------------------------------
sig = zeros(1,6);
for c = 1:6
    sig(c) = 3*Fbn(c)/(2*pi*rmaj(c)*rmin(c));
end
disp(sig)

% ----- Ball center coordinates (original) -------------------------
xbO = zeros(1,3);
ybO = zeros(1,3);
zbO = zeros(1,3);
for j = 1:3
    k = 2*j - 1;
    xbO(j) = (Xb(k)+Xb(k+1)+Dball(j)*Ab(k)+Dball(j)*Ab(k+1))/2;
    ybO(j) = (Yb(k)+Yb(k+1)+Dball(j)*Bb(k)+Dball(j)*Bb(k+1))/2;
    zbO(j) = (Zb(k)+Zb(k+1)+0.5*Dball(j)*Gb(k)+0.5*Dball(j)*Gb(k+1))/2;
end

% ----- Ball center coordinates (loaded) ---------------------------
xbN = zeros(1,3);
ybN = zeros(1,3);
zbN = zeros(1,3);
for j = 1:3
    k = 2*j - 1;
    xbN(j) = xbO(j)+(Ab(k)*del(k)+Ab(k+1)*del(k+1))/2;
    ybN(j) = ybO(j)+(Bb(k)*del(k)+Bb(k+1)*del(k+1))/2;
    zbN(j) = zbO(j)+(Gb(k)*del(k)+Gb(k+1)*del(k+1))/2;
end

% ----- Triangle side angles (original) ----------------------------
Aot = 180*atan2((ybO(1)-ybO(2)),(xbO(1)-xbO(2)))/pi;
Att = 180*atan2((ybO(3)-ybO(2)),(xbO(3)-xbO(2)))/pi;
Ato = 180*atan2((ybO(1)-ybO(3)),(xbO(1)-xbO(3)))/pi;

% ----- Ball center displacements ----------------------------------
dx = xbN - xbO;  dy = ybN - ybO;  dz = zbN - zbO;

%% Error Motion Analysis

% ----- Inter-ball distances (original) ----------------------------
LotI = sqrt((xbO(1)-xbO(2))^2+(ybO(1)-ybO(2))^2+(zbO(1)-zbO(2))^2);
LttI = sqrt((xbO(2)-xbO(3))^2+(ybO(2)-ybO(3))^2+(zbO(2)-zbO(3))^2);
LtoI = sqrt((xbO(3)-xbO(1))^2+(ybO(3)-ybO(1))^2+(zbO(3)-zbO(1))^2);

% ----- Inter-ball distances (loaded) ------------------------------
LotN = sqrt((xbN(1)-xbN(2))^2+(ybN(1)-ybN(2))^2+(zbN(1)-zbN(2))^2);
LttN = sqrt((xbN(2)-xbN(3))^2+(ybN(2)-ybN(3))^2+(zbN(2)-zbN(3))^2);
LtoN = sqrt((xbN(3)-xbN(1))^2+(ybN(3)-ybN(1))^2+(zbN(3)-zbN(1))^2);

% ----- Triangle angles (original) ---------------------------------
Angone   = 180*acos((LttI^2-LotI^2-LtoI^2)/(-2*LotI*LtoI))/pi;
Angtwo   = 180*acos((LtoI^2-LotI^2-LttI^2)/(-2*LotI*LttI))/pi;
Angthree = 180*acos((LotI^2-LtoI^2-LttI^2)/(-2*LtoI*LttI))/pi;

% ----- Altitude lengths -------------------------------------------
Aone   = LotN*sin(pi*abs(Aot-Att)/180);
Atwo   = LttN*sin(pi*abs(Aot-Att)/180);
Athree = LttN*sin(pi*abs(Ato-Att)/180);

% ----- Triangle angles (loaded) -----------------------------------
AngoneN   = 180*acos((LttN^2-LotN^2-LtoN^2)/(-2*LotN*LtoN))/pi;
AngtwoN   = 180*acos((LtoN^2-LotN^2-LttN^2)/(-2*LotN*LttN))/pi;
AngthreeN = 180*acos((LotN^2-LtoN^2-LttN^2)/(-2*LtoN*LttN))/pi;

% ----- Rotations about opposite sides (radians) -------------------
% Ttt: rotation about side 23 due to Z motion at ball 1
% Tto: rotation about side 13 due to Z motion at ball 2
% Tot: rotation about side 12 due to Z motion at ball 3
Ttt = dz(1)/Aone;
Tto = dz(2)/Atwo;
Tot = dz(3)/Athree;

% ----- Coupling centroid calculations -----------------------------
AmtwoO   = Att+Angtwo/2;
AmthreeO = Ato+Angthree/2;
AbtwoO   = ybO(2)-tan(pi*AmtwoO/180)*xbO(2);
AbthreeO = ybO(3)-tan(pi*AmthreeO/180)*xbO(3);

xci = (AbthreeO-AbtwoO)/(pi*(AmtwoO-AmthreeO)/180);
yci = (pi*AmtwoO/180)*xci+AbtwoO;
zci = (zbO(1)+zbO(2)+zbO(3))/3;

% ----- Ball-centroid distances ------------------------------------
Dcone   = sqrt((xbN(1)-xci)^2+(ybN(1)-yci)^2+(zbN(1)-zci)^2);
Dctwo   = sqrt((xbN(2)-xci)^2+(ybN(2)-yci)^2+(zbN(2)-zci)^2);
Dcthree = sqrt((xbN(3)-xci)^2+(ybN(3)-yci)^2+(zbN(3)-zci)^2);

% ----- Error motion at coupling centroid --------------------------
dxc = dx(1)*(LotI-Dcone)/LotI + dx(2)*(LttI-Dctwo)/LttI + dx(3)*(LtoI-Dcthree)/LtoI;
dyc = dy(1)*(LotI-Dcone)/LotI + dy(2)*(LttI-Dctwo)/LttI + dy(3)*(LtoI-Dcthree)/LtoI;
dzc = dz(1)*(LotI-Dcone)/LotI + dz(2)*(LttI-Dctwo)/LttI + dz(3)*(LtoI-Dcthree)/LtoI;

% ----- Distance changes -------------------------------------------
DLotI = LotI - LotN;
DLttI = LttI - LttN;
DLtoI = LtoI - LtoN;
DL_DD1 = abs(DLotI/LotI);
DL_DD2 = abs(DLttI/LttI);
DL_DD3 = abs(DLtoI/LtoI);

% ----- Theory applicability check ---------------------------------
% All ratio fields should be > 5 for Hertz theory to be valid
numer1 = max(abs(del(1)), abs(del(2)))/(Dball(1)/2);
numer2 = max(abs(del(3)), abs(del(4)))/(Dball(2)/2);
numer3 = max(abs(del(5)), abs(del(6)))/(Dball(3)/2);
denom1 = abs(DLotI/LotI);
denom2 = abs(DLttI/LttI);
denom3 = abs(DLtoI/LtoI);
ratio1 = numer1/denom1;
ratio2 = numer2/denom2;
ratio3 = numer3/denom3;

% ----- Coupling error rotations -----------------------------------
EpsZ1 = sqrt((0.5*(Ab(1)*del(1)+Ab(2)*del(2)))^2 ...
    +(0.5*(Bb(1)*del(1)+Bb(2)*del(2)))^2) ...
    * sign(-(Ab(1)*del(1)+Ab(2)*del(2))) ...
    / sqrt((xbO(1)-xci)^2+(ybO(1)-yci)^2);
EpsZ2 = sqrt((0.5*(Ab(3)*del(3)+Ab(4)*del(4)))^2 ...
    +(0.5*(Bb(3)*del(3)+Bb(4)*del(4)))^2) ...
    * sign(Ab(3)*del(3)+Ab(4)*del(4)) ...
    / sqrt((xbO(2)-xci)^2+(ybO(2)-yci)^2);
EpsZ3 = sqrt((0.5*(Ab(5)*del(5)+Ab(6)*del(6)))^2 ...
    +(0.5*(Bb(5)*del(5)+Bb(6)*del(6)))^2) ...
    * sign(Ab(5)*del(5)+Ab(6)*del(6)) ...
    / sqrt((xbO(3)-xci)^2+(ybO(3)-yci)^2);

EpsX = Ttt*cos(pi*Att/180) + Tto*cos(pi*Ato/180) - Tot*cos(pi*Aot/180);
EpsY = Ttt*sin(pi*Att/180) + Tto*sin(pi*Ato/180) - Tot*sin(pi*Aot/180);
EpsZ = (EpsZ1 + EpsZ2 + EpsZ3)/3;

% ----- Homogeneous transformation matrix --------------------------
HTM = [1, -EpsZ, EpsY, dxc; ...
    EpsZ, 1, -EpsX, dyc; ...
    -EpsY, EpsX, 1, dzc; ...
    0, 0, 0, 1];

% ----- Error at point of interest ---------------------------------
XYZInt = [Xerr; Yerr; Zerr; 1];
ErrorInt = HTM*XYZInt - XYZInt;
DeltaX = ErrorInt(1);
DeltaY = ErrorInt(2);
DeltaZ = ErrorInt(3);
DeltaRMS = sqrt(DeltaX^2 + DeltaY^2 + DeltaZ^2);

%% Output

fprintf('=== KINEMATIC COUPLING RESULTS ===\n');
fprintf('\n--- Contact Stresses ---\n');
fprintf('  sig-one   = %.2e Pa\n', sig(1));
fprintf('  sig-two   = %.2e Pa\n', sig(2));
fprintf('  sig-three = %.2e Pa\n', sig(3));
fprintf('  sig-four  = %.2e Pa\n', sig(4));
fprintf('  sig-five  = %.2e Pa\n', sig(5));
fprintf('  sig-six   = %.2e Pa\n', sig(6));
fprintf('\n--- Stress Ratios ---\n');
fprintf('  sig/S-one   = %.3f\n', sig(1)/S(1));
fprintf('  sig/S-two   = %.3f\n', sig(2)/S(1));
fprintf('  sig/S-three = %.3f\n', sig(3)/S(2));
fprintf('  sig/S-four  = %.3f\n', sig(4)/S(2));
fprintf('  sig/S-five  = %.3f\n', sig(5)/S(3));
fprintf('  sig/S-six   = %.3f\n', sig(6)/S(3));
fprintf('\n--- Hertz Theory Ratios (> 5 recommended) ---\n');
fprintf('  ratio1 = %.3f\n', ratio1);
fprintf('  ratio2 = %.3f\n', ratio2);
fprintf('  ratio3 = %.3f\n', ratio3);
fprintf('\n--- Position Error at POI ---\n');
fprintf('  DeltaX = %.6f m (%.3f um)\n', DeltaX, 1e6*DeltaX);
fprintf('  DeltaY = %.6f m (%.3f um)\n', DeltaY, 1e6*DeltaY);
fprintf('  DeltaZ = %.6f m (%.3f um)\n', DeltaZ, 1e6*DeltaZ);
fprintf('  DeltaRMS = %.6f m (%.3f um)\n', DeltaRMS, 1e6*DeltaRMS);