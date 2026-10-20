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

% ----- Bolt materials ----------------------------------------------------
% Tensile yield strength (Pa), UTS (Pa).  Assumes size > M16.
% Set 'Qualbolt' to 1=9.8  2=10.9  3=12.9
Matbolt(1,:) = [7.20e9, 9.00e9];
Matbolt(2,:) = [9.40e9, 1.040e10];
Matbolt(3,:) = [1.10e10, 1.220e10];

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

Xerr = 0.5; % X coordinate of error reporting point (m)
Yerr = 2.5; % Y coordinate of error reporting point (m)
Zerr = 2.0; % Z coordinate of error reporting point (m)

        %% Coupling Geometry Data

% Per-coupling geometry parameters (index 1,2,3 for the three couplings)
r = [0.5, 0.5, 0.5];                     % radial coordinate (m)
th = [pi/2, 7*pi/6, 11*pi/6];            % angular coordinate (rad)
thg = [pi/4, pi/4, pi/4];                % groove angle (rad)
Dball = [0.075, 0.075, 0.075];           % equivalent ball diameter (m)
Rbminor = [0.5, 0.5, 0.5];               % minor ball radius (m)
Rbmajor = [0.5, 0.5, 0.5];               % major ball radius (m)
Rgrv = [1000, 1000, 1000];               % groove radius (m, negative for trough)
Matgrv = [4, 4, 4];                       % groove material index
Matbal = [1, 1, 1];                       % ball material index

% Preload (all zero with no external loads applied)
Fpx = [0, 0, 0];
Fpy = [0, 0, 0];
Fpz = [0, 0, 0];
rp_pre = [0.5, 0.5, 0.5];                % preload radial coordinate (m)
thp_pre = [pi/2, 7*pi/6, 11*pi/6];       % preload angular coordinate (rad)

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
    Matbal(2:3) = Matbal(1);  Matgrv(2:3) = Matgrv(1);
end

% Unpack per-coupling arrays to individual variables for downstream arithmetic
r1 = r(1);  r2 = r(2);  r3 = r(3);
th1 = th(1);  th2 = th(2);  th3 = th(3);
thg1 = thg(1);  thg2 = thg(2);  thg3 = thg(3);
Dball1 = Dball(1);  Dball2 = Dball(2);  Dball3 = Dball(3);
Rbminor1 = Rbminor(1);  Rbminor2 = Rbminor(2);  Rbminor3 = Rbminor(3);
Rbmajor1 = Rbmajor(1);  Rbmajor2 = Rbmajor(2);  Rbmajor3 = Rbmajor(3);
Rgrv1 = Rgrv(1);  Rgrv2 = Rgrv(2);  Rgrv3 = Rgrv(3);
Matgrv1 = Matgrv(1);  Matgrv2 = Matgrv(2);  Matgrv3 = Matgrv(3);
Matbal1 = Matbal(1);  Matbal2 = Matbal(2);  Matbal3 = Matbal(3);
Fpxone = Fpx(1);  Fpxtwo = Fpx(2);  Fpxthree = Fpx(3);
Fpyone = Fpy(1);  Fpytwo = Fpy(2);  Fpythree = Fpy(3);
Fpzone = Fpz(1);  Fpztwo = Fpz(2);  Fpzthree = Fpz(3);
rpone = rp_pre(1);  rptwo = rp_pre(2);  rpthree = rp_pre(3);
thpone = thp_pre(1);  thptwo = thp_pre(2);  thpthree = thp_pre(3);
zpone = 2*Dball1;  zptwo = 2*Dball2;  zpthree = 2*Dball3;

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
xpone = rpone*cos(thpone);  ypone = rpone*sin(thpone);
xptwo = rptwo*cos(thptwo);  yptwo = rptwo*sin(thptwo);
xpthree = rpthree*cos(thpthree);  ypthree = rpthree*sin(thpthree);

% Per-coupling material and contact ellipse properties (shared by both
% contacts of each coupling)
S = zeros(1,3);  Ee = zeros(1,3);  Re = zeros(1,3);
theta_c = zeros(1,3);  alpha = zeros(1,3);  beta = zeros(1,3);
lambda = zeros(1,3);

for j = 1:3
    Eg = Matgroove(Matgrv(j),2);  vg = Matgroove(Matgrv(j),3);
    Eb = Matball(Matbal(j),2);    vb = Matball(Matbal(j),3);
    S(j) = min(Matgroove(Matgrv(j),1), Matball(Matbal(j),1));
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

% Unpack per-coupling arrays
Sone = S(1);  Stwo = S(2);  Sthree = S(3);
Eeone = Ee(1);  Eetwo = Ee(2);  Eethree = Ee(3);
Reone = Re(1);  Retwo = Re(2);  Rethree = Re(3);
alpha_1 = alpha(1);  alpha_2 = alpha(2);  alpha_3 = alpha(3);
beta_1 = beta(1);  beta_2 = beta(2);  beta_3 = beta(3);
lambda_1 = lambda(1);  lambda_2 = lambda(2);  lambda_3 = lambda(3);
theta_1 = theta_c(1);  theta_2 = theta_c(2);  theta_3 = theta_c(3);

%% Interface Force-Deflection Calculations

% Build force-moment equilibrium matrix A and load vectors B
% Solves A*F = B for contact forces at all six ball-groove contacts
A = [Ab(1:6); ...
    Bb(1:6); ...
    Gb(1:6); ...
    -Bb(1:6).*Zb(1:6) + Gb(1:6).*Yb(1:6); ...
     Ab(1:6).*Zb(1:6) - Gb(1:6).*Xb(1:6); ...
    -Ab(1:6).*Yb(1:6) + Bb(1:6).*Xb(1:6)];

% RHS with applied loads
Bwithloads = [-(Fpxone+Fpxtwo+Fpxthree+FLx); ...
    -(Fpyone+Fpytwo+Fpythree+FLy); ...
    -(Fpzone+Fpztwo+Fpzthree+FLz); ...
    -(-Fpyone*zpone-Fpytwo*zptwo-Fpythree*zpthree ...
    +Fpzone*ypone+Fpztwo*yptwo+Fpzthree*ypthree ...
    -FLy*ZL+FLz*YL+MLx); ...
    -(Fpxone*zpone+Fpxtwo*zptwo+Fpxthree*zpthree ...
    -Fpzone*xpone-Fpztwo*xptwo-Fpzthree*xpthree ...
    +FLx*ZL-FLz*XL+MLy); ...
    -(-Fpxone*ypone-Fpxtwo*yptwo-Fpxthree*ypthree ...
    +Fpyone*xpone+Fpytwo*xptwo+Fpythree*xpthree ...
    -FLx*YL+FLy*XL+MLz)];

% RHS without applied loads (preload only)
Bnoloads = [-(Fpxone+Fpxtwo+Fpxthree); ...
    -(Fpyone+Fpytwo+Fpythree); ...
    -(Fpzone+Fpztwo+Fpzthree); ...
    -(-Fpyone*zpone-Fpytwo*zptwo-Fpythree*zpthree ...
    +Fpzone*ypone+Fpztwo*yptwo+Fpzthree*ypthree); ...
    -(Fpxone*zpone+Fpxtwo*zptwo+Fpxthree*zpthree ...
    -Fpzone*xpone-Fpztwo*xptwo-Fpzthree*xpthree); ...
    -(-Fpxone*ypone-Fpxtwo*yptwo-Fpxthree*ypthree ...
    +Fpyone*xpone+Fpytwo*xptwo+Fpythree*xpthree)];

% Contact forces: with loads (Fbn) and preload-only (Fb)
Fbn = inv(A)*Bwithloads;
Fb  = inv(A)*Bnoloads;

fbnone  = Fbn(1);  fbntwo  = Fbn(2);
fbnthree = Fbn(3); fbnfour = Fbn(4);
fbnfive = Fbn(5);  fbnsix  = Fbn(6);

fone  = Fb(1);  ftwo  = Fb(2);
fthree = Fb(3); ffour = Fb(4);
ffive = Fb(5);  fsix  = Fb(6);

% ----- Ball deflections -------------------------------------------
% Difference in deflection between loaded and preload-only states
delone  = lambda_1*(2*fbnone^2/(3*Reone*Eeone^2))^(1/3) ...
    - lambda_1*(2*fone^2/(3*Reone*Eeone^2))^(1/3);
deltwo  = lambda_1*(2*fbntwo^2/(3*Reone*Eeone^2))^(1/3) ...
    - lambda_1*(2*ftwo^2/(3*Reone*Eeone^2))^(1/3);
delthree = lambda_2*(2*fbnthree^2/(3*Retwo*Eetwo^2))^(1/3) ...
    - lambda_2*(2*fthree^2/(3*Retwo*Eetwo^2))^(1/3);
delfour = lambda_2*(2*fbnfour^2/(3*Retwo*Eetwo^2))^(1/3) ...
    - lambda_2*(2*ffour^2/(3*Retwo*Eetwo^2))^(1/3);
delfive = lambda_3*(2*fbnfive^2/(3*Rethree*Eethree^2))^(1/3) ...
    - lambda_3*(2*ffive^2/(3*Rethree*Eethree^2))^(1/3);
delsix  = lambda_3*(2*fbnsix^2/(3*Rethree*Eethree^2))^(1/3) ...
    - lambda_3*(2*fsix^2/(3*Rethree*Eethree^2))^(1/3);

% ----- Contact ellipse radii --------------------------------------
rmajone   = alpha_1*(1.5*fbnone*Reone/Eeone)^(1/3);
rmajtwo   = alpha_1*(1.5*fbntwo*Reone/Eeone)^(1/3);
rmajthree = alpha_2*(1.5*fbnthree*Retwo/Eetwo)^(1/3);
rmajfour  = alpha_2*(1.5*fbnfour*Retwo/Eetwo)^(1/3);
rmajfive  = alpha_3*(1.5*fbnfive*Rethree/Eethree)^(1/3);
rmajsix   = alpha_3*(1.5*fbnsix*Rethree/Eethree)^(1/3);

rminone   = beta_1*(1.5*fbnone*Reone/Eeone)^(1/3);
rmintwo   = beta_1*(1.5*fbntwo*Reone/Eeone)^(1/3);
rminthree = beta_2*(1.5*fbnthree*Retwo/Eetwo)^(1/3);
rminfour  = beta_2*(1.5*fbnfour*Retwo/Eetwo)^(1/3);
rminfive  = beta_3*(1.5*fbnfive*Rethree/Eethree)^(1/3);
rminsix   = beta_3*(1.5*fbnsix*Rethree/Eethree)^(1/3);

% ----- Contact stresses -------------------------------------------
sigone  = 3*fbnone/(2*pi*rmajone*rminone)
sigtwo  = 3*fbntwo/(2*pi*rmajtwo*rmintwo)
sigthree = 3*fbnthree/(2*pi*rmajthree*rminthree)
sigfour = 3*fbnfour/(2*pi*rmajfour*rminfour)
sigfive = 3*fbnfive/(2*pi*rmajfive*rminfive)
sigsix  = 3*fbnsix/(2*pi*rmajsix*rminsix)

% ----- Ball center coordinates (original) -------------------------
xboneO = (Xb(1)+Xb(2)+Dball1*Ab(1)+Dball1*Ab(2))/2;
yboneO = (Yb(1)+Yb(2)+Dball1*Bb(1)+Dball1*Bb(2))/2;
zboneO = (Zb(1)+Zb(2)+0.5*Dball1*Gb(1)+0.5*Dball1*Gb(2))/2;

xbtwoO = (Xb(3)+Xb(4)+Dball2*Ab(3)+Dball2*Ab(4))/2;
ybtwoO = (Yb(3)+Yb(4)+Dball2*Bb(3)+Dball2*Bb(4))/2;
zbtwoO = (Zb(3)+Zb(4)+0.5*Dball2*Gb(3)+0.5*Dball2*Gb(4))/2;

xbthreeO = (Xb(5)+Xb(6)+Dball3*Ab(5)+Dball3*Ab(6))/2;
ybthreeO = (Yb(5)+Yb(6)+Dball3*Bb(5)+Dball3*Bb(6))/2;
zbthreeO = (Zb(5)+Zb(6)+0.5*Dball3*Gb(5)+0.5*Dball3*Gb(6))/2;

% ----- Ball center coordinates (loaded) ---------------------------
xboneN = xboneO+(Ab(1)*delone+Ab(2)*deltwo)/2;
yboneN = yboneO+(Bb(1)*delone+Bb(2)*deltwo)/2;
zboneN = zboneO+(Gb(1)*delone+Gb(2)*deltwo)/2;

xbtwoN = xbtwoO+(Ab(3)*delthree+Ab(4)*delfour)/2;
ybtwoN = ybtwoO+(Bb(3)*delthree+Bb(4)*delfour)/2;
zbtwoN = zbtwoO+(Gb(3)*delthree+Gb(4)*delfour)/2;

xbthreeN = xbthreeO+(Ab(5)*delfive+Ab(6)*delsix)/2;
ybthreeN = ybthreeO+(Bb(5)*delfive+Bb(6)*delsix)/2;
zbthreeN = zbthreeO+(Gb(5)*delfive+Gb(6)*delsix)/2;

% ----- Triangle side angles (original) ----------------------------
Aot = 180*atan2((yboneO-ybtwoO),(xboneO-xbtwoO))/pi;
Att = 180*atan2((ybthreeO-ybtwoO),(xbthreeO-xbtwoO))/pi;
Ato = 180*atan2((yboneO-ybthreeO),(xboneO-xbthreeO))/pi;

% ----- Ball center displacements ----------------------------------
dxone = xboneN - xboneO;  dyone = yboneN - yboneO;  dzone = zboneN - zboneO;
dxtwo = xbtwoN - xbtwoO;  dytwo = ybtwoN - ybtwoO;  dztwo = zbtwoN - zbtwoO;
dxthree = xbthreeN - xbthreeO;  dythree = ybthreeN - ybthreeO;  dzthree = zbthreeN - zbthreeO;

%% Error Motion Analysis

% ----- Inter-ball distances (original) ----------------------------
LotI = sqrt((xboneO-xbtwoO)^2+(yboneO-ybtwoO)^2+(zboneO-zbtwoO)^2);
LttI = sqrt((xbtwoO-xbthreeO)^2+(ybtwoO-ybthreeO)^2+(zbtwoO-zbthreeO)^2);
LtoI = sqrt((xbthreeO-xboneO)^2+(ybthreeO-yboneO)^2+(zbthreeO-zboneO)^2);

% ----- Inter-ball distances (loaded) ------------------------------
LotN = sqrt((xboneN-xbtwoN)^2+(yboneN-ybtwoN)^2+(zboneN-zbtwoN)^2);
LttN = sqrt((xbtwoN-xbthreeN)^2+(ybtwoN-ybthreeN)^2+(zbtwoN-zbthreeN)^2);
LtoN = sqrt((xbthreeN-xboneN)^2+(ybthreeN-yboneN)^2+(zbthreeN-zboneN)^2);

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
Ttt = dzone/Aone;
Tto = dztwo/Atwo;
Tot = dzthree/Athree;

% ----- Coupling centroid calculations -----------------------------
AmtwoO   = Att+Angtwo/2;
AmthreeO = Ato+Angthree/2;
AbtwoO   = ybtwoO-tan(pi*AmtwoO/180)*xbtwoO;
AbthreeO = ybthreeO-tan(pi*AmthreeO/180)*xbthreeO;

xci = (AbthreeO-AbtwoO)/(pi*(AmtwoO-AmthreeO)/180);
yci = (pi*AmtwoO/180)*xci+AbtwoO;
zci = (zboneO+zbtwoO+zbthreeO)/3;

% ----- Ball-centroid distances ------------------------------------
Dcone   = sqrt((xboneN-xci)^2+(yboneN-yci)^2+(zboneN-zci)^2);
Dctwo   = sqrt((xbtwoN-xci)^2+(ybtwoN-yci)^2+(zbtwoN-zci)^2);
Dcthree = sqrt((xbthreeN-xci)^2+(ybthreeN-yci)^2+(zbthreeN-zci)^2);

% ----- Error motion at coupling centroid --------------------------
dxc = dxone*(LotI-Dcone)/LotI + dxtwo*(LttI-Dctwo)/LttI + dxthree*(LtoI-Dcthree)/LtoI;
dyc = dyone*(LotI-Dcone)/LotI + dytwo*(LttI-Dctwo)/LttI + dythree*(LtoI-Dcthree)/LtoI;
dzc = dzone*(LotI-Dcone)/LotI + dztwo*(LttI-Dctwo)/LttI + dzthree*(LtoI-Dcthree)/LtoI;

% ----- Distance changes -------------------------------------------
DLotI = LotI - LotN;
DLttI = LttI - LttN;
DLtoI = LtoI - LtoN;
DL_DD1 = abs(DLotI/LotI);
DL_DD2 = abs(DLttI/LttI);
DL_DD3 = abs(DLtoI/LtoI);

% ----- Theory applicability check ---------------------------------
% All ratio fields should be > 5 for Hertz theory to be valid
numer1 = max(abs(delone), abs(deltwo))/(Dball1/2);
numer2 = max(abs(delthree), abs(delfour))/(Dball2/2);
numer3 = max(abs(delfive), abs(delsix))/(Dball3/2);
denom1 = abs(DLotI/LotI);
denom2 = abs(DLttI/LttI);
denom3 = abs(DLtoI/LtoI);
ratio1 = numer1/denom1;
ratio2 = numer2/denom2;
ratio3 = numer3/denom3;

% ----- Coupling error rotations -----------------------------------
EpsZ1 = sqrt((0.5*(Ab(1)*delone+Ab(2)*deltwo))^2 ...
    +(0.5*(Bb(1)*delone+Bb(2)*deltwo))^2) ...
    * sign(-(Ab(1)*delone+Ab(2)*deltwo)) ...
    / sqrt((xboneO-xci)^2+(yboneO-yci)^2);
EpsZ2 = sqrt((0.5*(Ab(3)*delthree+Ab(4)*delfour))^2 ...
    +(0.5*(Bb(3)*delthree+Bb(4)*delfour))^2) ...
    * sign(Ab(3)*delthree+Ab(4)*delfour) ...
    / sqrt((xbtwoO-xci)^2+(ybtwoO-yci)^2);
EpsZ3 = sqrt((0.5*(Ab(5)*delfive+Ab(6)*delsix))^2 ...
    +(0.5*(Bb(5)*delfive+Bb(6)*delsix))^2) ...
    * sign(Ab(5)*delfive+Ab(6)*delsix) ...
    / sqrt((xbthreeO-xci)^2+(ybthreeO-yci)^2);

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
DeltaRMS_mm = 1000*DeltaRMS;

%% Output

fprintf('=== KINEMATIC COUPLING RESULTS ===\n');
fprintf('\n--- Contact Stresses ---\n');
fprintf('  sig-one   = %.2e Pa\n', sigone);
fprintf('  sig-two   = %.2e Pa\n', sigtwo);
fprintf('  sig-three = %.2e Pa\n', sigthree);
fprintf('  sig-four  = %.2e Pa\n', sigfour);
fprintf('  sig-five  = %.2e Pa\n', sigfive);
fprintf('  sig-six   = %.2e Pa\n', sigsix);
fprintf('\n--- Stress Ratios ---\n');
fprintf('  sig/S-one   = %.3f\n', sigone/Sone);
fprintf('  sig/S-two   = %.3f\n', sigtwo/Sone);
fprintf('  sig/S-three = %.3f\n', sigthree/Stwo);
fprintf('  sig/S-four  = %.3f\n', sigfour/Stwo);
fprintf('  sig/S-five  = %.3f\n', sigfive/Sthree);
fprintf('  sig/S-six   = %.3f\n', sigsix/Sthree);
fprintf('\n--- Hertz Theory Ratios (> 5 recommended) ---\n');
fprintf('  ratio1 = %.3f\n', ratio1);
fprintf('  ratio2 = %.3f\n', ratio2);
fprintf('  ratio3 = %.3f\n', ratio3);
fprintf('\n--- Position Error at POI ---\n');
fprintf('  DeltaX = %.6f m (%.3f um)\n', DeltaX, 1e6*DeltaX);
fprintf('  DeltaY = %.6f m (%.3f um)\n', DeltaY, 1e6*DeltaY);
fprintf('  DeltaZ = %.6f m (%.3f um)\n', DeltaZ, 1e6*DeltaZ);
fprintf('  DeltaRMS = %.6f m (%.3f um)\n', DeltaRMS, 1e6*DeltaRMS);
