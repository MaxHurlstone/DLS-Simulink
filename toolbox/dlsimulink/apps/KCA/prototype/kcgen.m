% kcgen.m - code for parametric design studies of three groove kinematic
% couplings
% applies to standard symmetric (equal angle, equal groove) and asymmetric
% couplings
% Adapted from kincoup.xls by John Hart, MIT PERG, March 2001
% Adds bolt integrity calculations
% specify bolt diameter,
% All metric units (N-m-s)
% Symmetry Specification --------------------------------------------------
symmetric = 0; % 1 IF SYMMETRIC (EQUILATERAL, EQUAL RADIUS, EQUAL PRELOAD,
% ALL BALLS SAME MAT, ALL GRVS SAME MAT)
% 0 IF ASYMMETRIC - REQUIRES INDIVIDUAL DATA ENTRY
% Coupling materials library ----------------------------------------------
% Set 'Matgrv' and 'Matball' to 1 for Carbide
% 2 for Plastic
% 3 for RC 62 Steel
% 3 for RC 57 420 Stainless
% 4 for other values, and enter in Matball(4,:) and Matgroove(4,:)
Matball = [2.758e9, 3.103e11, 0.3]; % Carbide [Hertz limit, elastic modulus,
% Poisson ratio]
Matball(2,:) = [1.034e8, 1.034e10, 0.2]; % Plastic
Matball(3,:) = [1.724e9, 2.041e11, 0.29]; % RC62 Steel
Matball(4,:) = [1.36e9*0.75, 2.0e11, 0.29]; % RC57 420 Stainless
Matball(5,:) = [2.758e9, 3.103e11, 0.3]; % Other - set to appropriate val-
% ues, dummy = carbide
Matgroove = [2.758e9, 3.103e11, 0.3]; % Carbide [Hertz limit, elastic modu-
% lus, Poisson ratio]
Matgroove(2,:) = [1.034e8, 1.034e10, 0.2]; % Plastic
Matgroove(3,:) = [1.724e9, 2.041e11, 0.29]; % RC62 Steel
Matgroove(4,:) = [1.36e9*0.75, 2.0e11, 0.29];% RC57 420 Stainless
Matgroove(5,:) = [2.758e9, 3.103e11, 0.3]; % Other - set to appropriate val-
% ues, dummy = carbide
% Bolt materials library --------------------------------------------------
% ---------------------------
% Assumes size > M16
% Set 'Qualbolt' to 1 for quality = 9.8
% 2 for 10.9
% 3 for 12.9
Matbolt(1,:) = [7.20e9, 9.00e9]; % [Tensile yield strength, UTS]
Matbolt(2,:) = [9.40e9, 1.040e10];
Matbolt(3,:) = [1.10e10, 1.220e10];
% Setup opening of design loop (s) here -----------------------------------
% --------------------------------
%Default no loop
i = 1;
for param1 = -100000:-100000;%-2000:-400000 % first varying parameter
for param2 = 1:1:1 % second varying parameter
% set varied paramaters to 'param 1' and 'param 2' below
% nest more loops if desired
% Disturbance parameters --------------------------------------------------
FLx = param1(i,1);% (X,Y,Z) applied force
FLy = param1(i,2);
FLz = param1(i,3);
MLx = param1(i,4); % (X,Y,Z) applied torque
MLy = param1(i,5);
MLz = param1(i,6);
XL = 0; % (X,Y,Z) location of force and torque application
YL = 0;
ZL = 0;
Xerr = 0.5; % (X,Y,Z) location of error reporting
Yerr = 2.5;
Zerr = 2.0;
% Disturbance force matrix (for bolt calculations) - include effect of non-
% centroidal disturbance
Fdist = [FLx;
FLy;
FLz;
MLx + FLz*YL - FLy*ZL;
MLy + FLx*ZL - FLz*XL;
MLz + FLy*XL - FLx*XL];
% Coupling Data Entry -----------------------------------------------------
% ------------------------------
% Coupling 1 - applies to all couplings if symmetric = 1
r1 = 0.5; % Radial coordinate of coupling position
th1 = pi/2; % Angular coordinate of coupling position
thg1 = pi/4; % Groove angle
Dball1 = 0.075; % Equivalent ball diameter that would contact groove at same
% points
Rbminor1 = 0.5;% Minor ball radius
Rbmajor1 = 0.5;% Major ball radius
Rgrv1 = 1000; % Groove radius (negative for trough)
Matgrv1 = 1; % Groove material
Matbal1 = 1; % Ball material
Fpxone = 0; % X-component of preload force
Fpyone = 0; % Y-component of preload force
Fpzone = param1; % Z-component of preload force
rpone = 0.5; % Radial coordinate of preload application
thpone = pi/2; % Angular coordinate of preload application
zpone = 2*Dball1; % Z-coordinate of preload application (default =
% 2*Dball)
Dbolt1 = 28/1000; % Bolt diameter (divided to mm)
Matbolt1 = 2; % Bolt material
Leng1 = 50/1000; % Length of bolt thread engagement
% Coupling 2 - enter values here if asymmetric design, else these are set
% appropriately later
r2 = 0.5; % Radial coordinate of coupling position
th2 = 7*pi/6; % Angular coordinate of coupling position
thg2 = pi/4; % Groove angle
Dball2 = 0.075;% Equivalent ball diameter that would contact groove at same
% points
Rbminor2 = 0.5;% Minor ball radius
Rbmajor2 = 0.5;% Major ball radius
Rgrv2 = 1000; % Groove radius (negative for trough)
Matgrv2 = 4; % Groove material
Matbal2 = 4; % Ball material
Fpxtwo = 0; % X-component of preload force
Fpytwo = 0; % Y-component of preload force
Fpztwo = -100000; % Z-component of preload force
rptwo = 0.5; % Radial coordinate of preload application
thptwo = 7*pi/6; % Angular coordinate of preload application
zptwo = 2*Dball2; % Z-coordinate of preload application (default =
% 2*Dball)
Dbolt2 = 28/1000; % Bolt diameter (divided to mm)
Matbolt2 = 2; % Bolt material
Leng2 = 50/1000; % Length of bolt thread engagement
% Coupling 3 - enter values here if asymmetric design, else these are set
% appropriately later
r3 = 0.5; % Radial coordinate of coupling position
th3 = 11*pi/6; % Angular coordinate of coupling position
thg3 = pi/4; % Groove angle
Dball3 = 0.075;% Equivalent ball diameter that would contact groove at same
% points
Rbminor3 = 0.5;% Minor ball radius
Rbmajor3 = 0.5;% Major ball radius
Rgrv3 = 1000; % Groove radius (negative for trough)
Matgrv3 = 4; % Groove material
Matbal3 = 4; % Ball material
Fpxthree = 0; % X-component of preload force
Fpythree = 0; % Y-component of preload force
Fpzthree = -100000; % Z-component of preload force
rpthree = 0.5; % Radial coordinate of preload application
thpthree = 11*pi/6; % Angular coordinate of preload application
zpthree = 2*Dball3; % Z-coordinate of preload application (default =
% 2*Dball)
Dbolt3 = 28/1000; % Bolt diameter (divided to mm)
Matbolt3 = 2; % Bolt material
Leng3 = 50/1000; % Length of bolt thread engagement
% Skip this section - propagates uniform parameters if symmetric design
if symmetric == 1
r2 = r1;
r3 = r1;
th2 = th1 + 2*pi/3;
th3 = th1 + 4*pi/3;
Dball2 = Dball1;
Dball3 = Dball1;
Rbminor2 = Rbminor1;
Rbminor3 = Rbminor1;
Rbmajor2 = Rbmajor1;
Rbmajor3 = Rbmajor1;
Rgrv2 = Rgrv1;
Rgrv3 = Rgrv1;
Fpxtwo = Fpxone;
Fpytwo = Fpyone;
Fpztwo = Fpzone;
Fpxthree = Fpxone;
Fpythree = Fpyone;
Fpzthree = Fpzone;
rptwo = rpone;
rpthree = rpone;
thptwo = thpone + 2*pi/3;
thpthree = thpone + 4*pi/3;
Matbal2 = Matbal1;
Matgrv2 = Matgrv1;
Matbal3 = Matbal1;
Matgrv3 = Matgrv1;
Dbolt2 = Dbolt1;
Dbolt3 = Dbolt1;
Matbolt2 = Matbolt1;
Matbolt3 = Matbolt1;
Leng2 = Leng1;
Leng3 = Leng1;
end
% Computation of coupling locations and direction cosines -----------------
% ----------------------------------------
% Coupling 1
Xba = r1*cos(th1) + Dball1*sqrt(2)*sin(th1)/4;% (XYZ) of bal1-groove1 con-
% points
Xbb = r1*cos(th1) - Dball1*sqrt(2)*sin(th1)/4;
Yba = r1*sin(th1) - Dball1*sqrt(2)*cos(th1)/4;
Ybb = r1*sin(th1) + Dball1*sqrt(2)*cos(th1)/4;
Zba = -Dball1*sqrt(2)/4;
Zbb = -Dball1*sqrt(2)/4;
Aba = -sin(th1)/sqrt(1+tan(thg1)^2); % (ABG) direction cosines
% ball1-groove1 contact points (a and b)
Abb = sin(th1)/sqrt(1+tan(thg1)^2);
Bba = cos(th1)/sqrt(1+tan(thg1)^2);
Bbb = -cos(th1)/sqrt(1+tan(thg1)^2);
Gba = tan(thg1)/sqrt(1+tan(thg1)^2);
Gbb = tan(thg1)/sqrt(1+tan(thg1)^2);
xpone = rpone*cos(thpone);
ypone = rpone*sin(thpone);
Sone = min(Matgroove(Matgrv1,1),Matball(Matbal1,1));% Hertz stress limit,
% pair1
Egone = Matgroove(Matgrv1,2); % Elastic modulus,
% groove1
vgone = Matgroove(Matgrv1,3); % Poisson ratio, groove1
Ebone = Matball(Matbal1,2); % Elastic modulus, ball1
vbone = Matball(Matbal1,3); % Poisson ratio, ball1
Eeone = 1/((1-vgone^2)/Egone+(1-vbone^2)/Ebone); % Equivalent modulus,
% pair1
Reone = 1/(1/Rgrv1 + 1/Rbminor1 + 1/Rbmajor1);
ctone = Reone*sqrt((1/Rgrv1)^2+(1/Rbmajor1-1/Rbminor1)^2+2*(-1/Rgrv1)*(1/Rbmajor1-1/Rbminor1));
theta_1 = acos(ctone);
alpha_1 = 1.939*2.71831^(-5.26*theta_1)+1.78*2.71831^(-1.09*theta_1)+0.723/theta_1+0.221;
beta_1 = 35.228*2.71831^(-0.98*theta_1)-32.424*2.71831^(-1.0475*theta_1)+1.486*theta_1-2.634;
lambda_1 = -0.214*2.71831^(-4.95*theta_1)-0.179*theta_1^2+0.555*theta_1+0.319;
% Coupling 2
Xbc = r2*cos(th2) + Dball2*sqrt(2)*sin(th2)/4;% (XYZ) of bal1-groove1 con-
% points
Xbd = r2*cos(th2) - Dball2*sqrt(2)*sin(th2)/4;
Ybc = r2*sin(th2) - Dball2*sqrt(2)*cos(th2)/4;
Ybd = r2*sin(th2) + Dball2*sqrt(2)*cos(th2)/4;
Zbc = -Dball2*sqrt(2)/4;
Zbd = -Dball2*sqrt(2)/4;
Abc = -sin(th2)/sqrt(1+tan(thg2)^2); % (ABG) direction cosines
% ball1-groove1 contact points (c and d)
Abd = sin(th2)/sqrt(1+tan(thg2)^2);
Bbc = cos(th2)/sqrt(1+tan(thg2)^2);
Bbd = -cos(th2)/sqrt(1+tan(thg2)^2);
Gbc = tan(thg2)/sqrt(1+tan(thg2)^2);
Gbd = tan(thg2)/sqrt(1+tan(thg2)^2);
xptwo = rptwo*cos(thptwo);
yptwo = rptwo*sin(thptwo);
Stwo = min(Matgroove(Matgrv2,1),Matball(Matbal2,1));
Egtwo = Matgroove(Matgrv2,2);
vgtwo = Matgroove(Matgrv2,3);
Ebtwo = Matball(Matbal2,2);
vbtwo = Matball(Matbal2,3);
Eetwo = 1/((1-vgtwo^2)/Egtwo+(1-vbtwo^2)/Ebtwo);
Retwo = 1/(1/Rgrv2 + 1/Rbminor2 + 1/Rbmajor2);
cttwo = Retwo*sqrt((1/Rgrv2)^2+(1/Rbmajor2-1/Rbminor2)^2+2*(-1/Rgrv2)*(1/Rbmajor2-1/Rbminor2));
theta_2 = acos(cttwo);
alpha_2 = 1.939*2.71831^(-5.26*theta_2)+1.78*2.71831^(-1.09*theta_2)+0.723/theta_2+0.221;
beta_2 = 35.228*2.71831^(-0.98*theta_2)-32.424*2.71831^(-1.0475*theta_2)+1.486*theta_2-2.634;
lambda_2 = -0.214*2.71831^(-4.95*theta_2)-0.179*theta_2^2+0.555*theta_2+0.319;
% Coupling 3
Xbe = r3*cos(th3) + Dball3*sqrt(2)*sin(th3)/4;% (XYZ) of bal1-groove1 con-
% points
Xbf = r3*cos(th3) - Dball3*sqrt(2)*sin(th3)/4;
Ybe = r3*sin(th3) - Dball3*sqrt(2)*cos(th3)/4;
Ybf = r3*sin(th3) + Dball3*sqrt(2)*cos(th3)/4;
Zbe = -Dball3*sqrt(2)/4;
Zbf = -Dball3*sqrt(2)/4;
Abe = -sin(th3)/sqrt(1+tan(thg3)^2); % (ABG) direction cosines
% ball1-groove1 contact points (c and d)
Abf = sin(th3)/sqrt(1+tan(thg3)^2);
Bbe = cos(th3)/sqrt(1+tan(thg3)^2);
Bbf = -cos(th3)/sqrt(1+tan(thg3)^2);
Gbe = tan(thg3)/sqrt(1+tan(thg3)^2);
Gbf = tan(thg3)/sqrt(1+tan(thg3)^2);
xpthree = rpthree*cos(thpthree);
ypthree = rpthree*sin(thpthree);
Sthree = min(Matgroove(Matgrv3,1),Matball(Matbal3,1));
Egthree = Matgroove(Matgrv3,2);
vgthree = Matgroove(Matgrv3,3);
Ebthree = Matball(Matbal3,2);
vbthree = Matball(Matbal3,3);
Eethree = 1/((1-vgthree^2)/Egthree+(1-vbthree^2)/Ebthree);
Rethree = 1/(1/Rgrv3 + 1/Rbminor3 + 1/Rbmajor3);
ctthree = Rethree*sqrt((1/Rgrv3)^2+(1/Rbmajor3-1/Rbminor3)^2+2*(-1/Rgrv3)*(1/Rbmajor3-1/Rbminor3));
theta_3 = acos(ctthree);
alpha_3 = 1.939*2.71831^(-5.26*theta_3)+1.78*2.71831^(-1.09*theta_3)+0.723/theta_3+0.221;
beta_3 = 35.228*2.71831^(-0.98*theta_3)-32.424*2.71831^(-1.0475*theta_3)+1.486*theta_3-2.634;
lambda_3 = -0.214*2.71831^(-4.95*theta_3)-0.179*theta_3^2+0.555*theta_3+0.319;
% Interface force-deflection calculations ---------------------------------
% -----------------------------------
% Build force-moment equilibrium equation AF = B
A = [Aba, Abb, Abc, Abd, Abe, Abf;...
Bba, Bbb, Bbc, Bbd, Bbe, Bbf;...
Gba, Gbb, Gbc, Gbd, Gbe, Gbf;...
-Bba*Zba+Gba*Yba, -Bbb*Zbb+Gbb*Ybb, -Bbc*Zbc+Gbc*Ybc, -Bbd*Zbd+Gbd*Ybd, -Bbe*Zbe+Gbe*Ybe, -Bbf*Zbf+Gbf*Ybf;...
Aba*Zba-Gba*Xba, Abb*Zbb-Gbb*Xbb, Abc*Zbc-Gbc*Xbc, Abd*Zbd-Gbd*Xbd, Abe*Zbe-Gbe*Xbe, Abf*Zbf-Gbf*Xbf;...
-Aba*Yba+Bba*Xba, -Abb*Ybb+Bbb*Xbb, -Abc*Ybc+Bbc*Xbc, -Abd*Ybd+Bbd*Xbd, -Abe*Ybe+Bbe*Xbe, -Abf*Ybf+Bbf*Xbf];
Bwithloads = [ -(Fpxone+Fpxtwo+Fpxthree+FLx);
-(Fpyone+Fpytwo+Fpythree+FLy);...
-(Fpzone+Fpztwo+Fpzthree+FLz);...
-(-Fpyone*zpone-Fpytwo*zptwo-Fpythree*zpthree+Fpzone*ypone+Fpztwo*yptwo+Fpzthree*ypthree-FLy*ZL+FLz*YL+MLx);...
-(Fpxone*zpone+Fpxtwo*zptwo+Fpxthree*zpthree-Fpzone*xpone-Fpztwo*xptwo-Fpzthree*xpthree+FLx*ZL-FLz*XL+MLy);...
-(-Fpxone*ypone-Fpxtwo*yptwo-Fpxthree*ypthree+Fpyone*xpone+Fpytwo*xptwo+Fpythree*xpthree-FLx*YL+FLy*XL+MLz)];
Bnoloads = [-(Fpxone+Fpxtwo+Fpxthree); -(Fpyone+Fpytwo+Fpythree); -(Fpzone+Fpztwo+Fpzthree);...
-(-Fpyone*zpone-Fpytwo*zptwo-Fpythree*zpthree+Fpzone*ypone+Fpztwo*yptwo+Fpzthree*ypthree);...
-(Fpxone*zpone+Fpxtwo*zptwo+Fpxthree*zpthree-Fpzone*xpone-Fpztwo*xptwo-Fpzthree*xpthree);...
-(-Fpxone*ypone-Fpxtwo*yptwo-Fpxthree*ypthree+Fpyone*xpone+Fpytwo*xptwo+Fpythree*xpthree)];
Fbn = inv(A)*Bwithloads;
Fb = inv(A)*Bnoloads;
fbnone = Fbn(1);
fbntwo = Fbn(2);
fbnthree = Fbn(3);
fbnfour = Fbn(4);
fbnfive = Fbn(5);
fbnsix = Fbn(6);
fone = Fb(1);
ftwo = Fb(2);
fthree = Fb(3);
ffour = Fb(4);
ffive = Fb(5);
fsix = Fb(6);
% Deflections into balls
delone = lambda_1*(2*fbnone^2/(3*Reone*Eeone^2))^0.33333 - ...
lambda_1*(2*fone^2/(3*Reone*Eeone^2))^0.33333;
deltwo = lambda_1*(2*fbntwo^2/(3*Reone*Eeone^2))^0.33333 - ...
lambda_1*(2*ftwo^2/(3*Reone*Eeone^2))^0.33333;
delthree = lambda_2*(2*fbnthree^2/(3*Retwo*Eetwo^2))^0.33333 - ...
lambda_2*(2*fthree^2/(3*Retwo*Eetwo^2))^0.33333;
delfour = lambda_2*(2*fbnfour^2/(3*Retwo*Eetwo^2))^0.33333 - ...
lambda_2*(2*ffour^2/(3*Retwo*Eetwo^2))^0.33333;
delfive = lambda_3*(2*fbnfive^2/(3*Rethree*Eethree^2))^0.33333 - ...
lambda_3*(2*ffive^2/(3*Rethree*Eethree^2))^0.33333;
delsix = lambda_3*(2*fbnsix^2/(3*Rethree*Eethree^2))^0.33333 - ...
lambda_3*(2*fsix^2/(3*Rethree*Eethree^2))^0.33333;
% Contact ellipse radii
rmajone = alpha_1*(1.5*fbnone*Reone/Eeone)^0.333333;
rmajtwo = alpha_1*(1.5*fbntwo*Reone/Eeone)^0.333333;
rmajthree = alpha_2*(1.5*fbnthree*Retwo/Eetwo)^0.333333;
rmajfour = alpha_2*(1.5*fbnfour*Retwo/Eetwo)^0.333333;
rmajfive = alpha_3*(1.5*fbnfive*Rethree/Eethree)^0.333333;
rmajsix = alpha_3*(1.5*fbnsix*Rethree/Eethree)^0.333333;
rminone = beta_1*(1.5*fbnone*Reone/Eeone)^0.333333;
rmintwo = beta_1*(1.5*fbntwo*Reone/Eeone)^0.333333;
rminthree = beta_2*(1.5*fbnthree*Retwo/Eetwo)^0.333333;
rminfour = beta_2*(1.5*fbnfour*Retwo/Eetwo)^0.333333;
rminfive = beta_3*(1.5*fbnfive*Rethree/Eethree)^0.333333;
rminsix = beta_3*(1.5*fbnsix*Rethree/Eethree)^0.333333;
% Contact stress values
sigone = 3*fbnone/(2*pi*rmajone*rminone)
sigtwo = 3*fbntwo/(2*pi*rmajtwo*rmintwo)
sigthree = 3*fbnthree/(2*pi*rmajthree*rminthree)
sigfour = 3*fbnfour/(2*pi*rmajfour*rminfour)
sigfive = 3*fbnfive/(2*pi*rmajfive*rminfive)
sigsix = 3*fbnsix/(2*pi*rmajsix*rminsix)
% Original ball coordinates
xboneO = (Xba+Xbb+Dball1*Aba+Dball1*Abb)/2;
yboneO = (Yba+Ybb+Dball1*Bba+Dball1*Bbb)/2;
zboneO = (Zba+Zbb+0.5*Dball1*Gba+0.5*Dball1*Gbb)/2;
xbtwoO = (Xbc+Xbd+Dball2*Abc+Dball2*Abd)/2;
ybtwoO = (Ybc+Ybd+Dball2*Bbc+Dball2*Bbd)/2;
zbtwoO = (Zbc+Zbd+0.5*Dball2*Gbc+0.5*Dball2*Gbd)/2;
xbthreeO = (Xbe+Xbf+Dball3*Abe+Dball3*Abf)/2;
ybthreeO = (Ybe+Ybf+Dball3*Bbe+Dball3*Bbf)/2;
zbthreeO = (Zbe+Zbf+0.5*Dball3*Gbe+0.5*Dball3*Gbf)/2;
% New ball coordinates
xboneN = xboneO+(Aba*delone+Abb*deltwo)/2;
yboneN = yboneO+(Bba*delone+Bbb*deltwo)/2;
zboneN = zboneO+(Gba*delone+Gbb*deltwo)/2;
xbtwoN = xbtwoO+(Abc*delthree+Abd*delfour)/2;
ybtwoN = ybtwoO+(Bbc*delthree+Bbd*delfour)/2;
zbtwoN = zbtwoO+(Gbc*delthree+Gbd*delfour)/2;
xbthreeN = xbthreeO+(Abe*delfive+Abf*delsix)/2;
ybthreeN = ybthreeO+(Bbe*delfive+Bbf*delsix)/2;
zbthreeN = zbthreeO+(Gbe*delfive+Gbf*delsix)/2;
% Original sides' angle with x axis
Aot = 180*atan2((yboneO-ybtwoO),(xboneO-xbtwoO))/pi;
Att = 180*atan2((ybthreeO-ybtwoO),(xbthreeO-xbtwoO))/pi;
Ato = 180*atan2((yboneO-ybthreeO),(xboneO-xbthreeO))/pi;
% Ball center displacements
dxone = xboneN - xboneO;
dyone = yboneN - yboneO;
dzone = zboneN - zboneO;
dxtwo = xbtwoN - xbtwoO;
dytwo = ybtwoN - ybtwoO;
dztwo = zbtwoN - zbtwoO;
dxthree = xbthreeN - xbthreeO;
dythree = ybthreeN - ybthreeO;
dzthree = zbthreeN - zbthreeO;
% Theory applicability check
% Initial distance between balls
LotI = sqrt((xboneO-xbtwoO)^2+(yboneO-ybtwoO)^2+(zboneO-zbtwoO)^2);
LttI = sqrt((xbtwoO-xbthreeO)^2+(ybtwoO-ybthreeO)^2+(zbtwoO-zbthreeO)^2);
LtoI = sqrt((xbthreeO-xboneO)^2+(ybthreeO-yboneO)^2+(zbthreeO-zboneO)^2);
% Final distance between balls
LotN = sqrt((xboneN-xbtwoN)^2+(yboneN-ybtwoN)^2+(zboneN-zbtwoN)^2);
LttN = sqrt((xbtwoN-xbthreeN)^2+(ybtwoN-ybthreeN)^2+(zbtwoN-zbthreeN)^2);
LtoN = sqrt((xbthreeN-xboneN)^2+(ybthreeN-yboneN)^2+(zbthreeN-zboneN)^2);
% Original angle between balls
Angone = 180*acos((LttI^2-LotI^2-LtoI^2)/(-2*LotI*LtoI))/pi;
Angtwo = 180*acos((LtoI^2-LotI^2-LttI^2)/(-2*LotI*LttI))/pi;
Angthree = 180*acos((LotI^2-LtoI^2-LttI^2)/(-2*LtoI*LttI))/pi;
% Original altitude lengths
Aone = LotN*sin(pi*abs(Aot-Att)/180);
Atwo = LttN*sin(pi*abs(Aot-Att)/180);
Athree = LttN*sin(pi*abs(Ato-Att)/180);
% New angles between balls
AngoneN = 180*acos((LttN^2-LotN^2-LtoN^2)/(-2*LotN*LtoN))/pi;
AngtwoN = 180*acos((LtoN^2-LotN^2-LttN^2)/(-2*LotN*LttN))/pi;
AngthreeN = 180*acos((LotN^2-LtoN^2-LttN^2)/(-2*LtoN*LttN))/pi;
% Rotation about opposite side (radians)
Ttt = dzone/Aone;% rotation about side 23 due to Z motion at ball 1
Tto = dztwo/Atwo;% rotation about side 13 due to Z motion at ball 2
Tot = dzthree/Athree; % rotation about side 12 due to Z motion at ball 3
AmtwoO = Att+Angtwo/2;
AmthreeO = Ato+Angthree/2;
AbtwoO = ybtwoO-tan(pi*AmtwoO/180)*xbtwoO;
AbthreeO = ybthreeO-tan(pi*AmthreeO/180)*xbthreeO;
% Initial coupling centroid
xci = (AbthreeO-AbtwoO)/(pi*(AmtwoO-AmthreeO)/180);
yci = (pi*AmtwoO/180)*xci+AbtwoO;
zci = (zboneO+zbtwoO+zbthreeO)/3;
% New ball-centroid distances
Dcone = sqrt((xboneN-xci)^2+(yboneN-yci)^2+(zboneN-zci)^2);
Dctwo = sqrt((xbtwoN-xci)^2+(ybtwoN-yci)^2+(zbtwoN-zci)^2);
Dcthree = sqrt((xbthreeN-xci)^2+(ybthreeN-yci)^2+(zbthreeN-zci)^2);
% Error motion at centroid from weighted ball motions
dxc = dxone*(LotI-Dcone)/LotI+dxtwo*(LttI-Dctwo)/LttI+dxthree*(LtoI-Dcthree)/LtoI;
dyc = dyone*(LotI-Dcone)/LotI+dytwo*(LttI-Dctwo)/LttI+dythree*(LtoI-Dcthree)/LtoI;
dzc = dzone*(LotI-Dcone)/LotI+dztwo*(LttI-Dctwo)/LttI+dzthree*(LtoI-Dcthree)/LtoI;
% Difference
DLotI = LotI - LotN;
DLttI = LttI - LttN;
DLtoI = LtoI - LtoN;
% Change in distance / distance between balls
DL_DD1 = abs(DLotI/LotI);
DL_DD2 = abs(DLttI/LttI);
DL_DD3 = abs(DLtoI/LtoI);
% Coupling theory applicability check - all fields should be >5
numer1 = max(abs(delone), abs(deltwo))/(Dball1/2);
numer2 = max(abs(delthree), abs(delfour))/(Dball2/2);
numer3 = max(abs(delfive), abs(delsix))/(Dball3/2);
denom1 = abs(DLotI/LotI);
denom2 = abs(DLttI/LttI);
denom3 = abs(DLtoI/LtoI);
ratio1 = numer1/denom1;
ratio2 = numer2/denom2;
ratio3 = numer3/denom3;
% Coupling error rotations
EpsZ1 = sqrt((0.5*(Aba*delone+Abb*deltwo))^2+(0.5*(Bba*delone+Bbb*deltwo))^2)*sign(...
-(Aba*delone+Abb*deltwo))/sqrt((xboneO-xci)^2+(yboneO-yci)^2);
EpsZ2 = sqrt((0.5*(Abc*delthree+Abd*delfour))^2+(0.5*(Bbc*delthree+Bbd*delfour))^2)*sign(Abc*delthree+Abd*delfour)/sqrt((xbtwoO-xci)^2+(ybtwoO-yci)^2);
EpsZ3 = sqrt((0.5*(Abe*delfive+Abf*delsix))^2+(0.5*(Bbe*delfive+Bbf*delsix))^2)*sign(Abe*delfive+Abf*delsix)/sqrt((xbthreeO-xci)^2+(ybthreeO-yci)^2);
EpsX = Ttt*cos(pi*Att/180)+Tto*cos(pi*Ato/180)-Tot*cos(pi*Aot/180);
EpsY = Ttt*sin(pi*Att/180)+Tto*sin(pi*Ato/180)-Tot*sin(pi*Aot/180);
EpsZ = (EpsZ1 + EpsZ2 + EpsZ3)/3;
% Coupling homogenous transformation matrix
HTM = [1, -EpsZ, EpsY, dxc;...
EpsZ, 1, -EpsX, dyc;...
-EpsY, EpsX, 1, dzc;...
0, 0, 0, 1];
% Point of interest
XYZInt = [Xerr; Yerr; Zerr; 1];
% Error motions at point of interest
ErrorInt = HTM*XYZInt - XYZInt;
DeltaX = ErrorInt(1);
DeltaY = ErrorInt(2);
DeltaZ = ErrorInt(3);
DeltaRMS = sqrt(DeltaX^2 + DeltaY^2 + DeltaZ^2);
DeltaRMS_mm = 1000*DeltaRMS;
% Output data to console --------------------------------------------------
% -----------------
if symmetric == 1
% This assumes spherical contact, z-preload only (ABB base case)
coupdata_symm(i,:) = [param1, param2, r1, th1, Dball1, Rbminor1, Fpzone,
sigone/Sone, sigtwo/Sone, sigthree/Stwo,...
sigfour/Stwo, sigfive/Sthree, sigsix/Sthree, DeltaX, DeltaY, DeltaZ,
EpsX, EpsY, EpsZ, DeltaX, DeltaY, DeltaZ, DeltaRMS_mm ];
end
% This assumes z-preload only
if symmetric == 0
coupdata_asymm(i,:) = [param1, param2, r1, th1, Dball1, Rbminor1, Rbmajor1,
Fpzone, r2, th2, Dball2, Rbminor2, Rbmajor2, Fpztwo,...
r3, th3, Dball3, Rbminor3, Rbmajor3, Fpzthree, sigone/Sone, sigtwo/Sone, sigthree/Stwo,...
sigfour/Stwo, sigfive/Sthree, sigsix/Sthree, DeltaX, DeltaY, DeltaZ,
EpsX, EpsY, EpsZ, DeltaX, DeltaY, DeltaZ, DeltaRMS_mm ];
end
% Coupling theory applicability check - all fields should be >5
theory_check(i,:) = [ratio1, ratio2, ratio3];
% Upper-bound bolt loads and stress checks
% Fbolt = -Inv(Abolt)*Fdist
% Fbolt = [Fn1; Fn2; Fn3; Ft1; Ft2; Ft3];
Abolt = [ 0, 0, 0, sin(thpone), sin(thptwo), sin(thpthree);
0, 0, 0, cos(thpone), cos(thptwo), cos(thpthree);
1, 1, 1, 0, 0, 0;
rpone*sin(thpone), rptwo*sin(thptwo), rpthree*sin(thpthree), 0, 0, 0;
-rpone*cos(thpone), -rptwo*cos(thptwo), -rpthree*cos(thpthree), 0, 0, 0;
0, 0, 0, -rpone, -rptwo, -rpthree];
Fbolt = -1*inv(Abolt)*Fdist;
% Add the preloads
Fbolt(1) = abs(Fbolt(1)) - Fpzone;
Fbolt(2) = abs(Fbolt(2)) - Fpzone;
Fbolt(3) = abs(Fbolt(3)) - Fpzone;
% Compute stress ratios in shank
nshank1 = ((Fbolt(1)/(pi*Dbolt1^2))*(1/Matbolt(Matbolt1,2)))^2 + ...
((16*Fbolt(4)/(3*pi*Dbolt1^2))*(1/(0.62*Matbolt(Matbolt1,2))))^2;
nshank2 = ((Fbolt(2)/(pi*Dbolt2^2))*(1/Matbolt(Matbolt2,2)))^2 + ...
((16*Fbolt(5)/(3*pi*Dbolt2^2))*(1/(0.62*Matbolt(Matbolt2,2))))^2;
nshank3 = ((Fbolt(3)/(pi*Dbolt3^2))*(1/Matbolt(Matbolt3,2)))^2 + ...
((16*Fbolt(6)/(3*pi*Dbolt3^2))*(1/(0.62*Matbolt(Matbolt3,2))))^2;
% Compute stress ratios in threads
nthreads1 = (Fbolt(1)/(pi*Dbolt1*Leng1))*(1/(0.62*Matbolt(Matbolt1,2)));
nthreads2 = (Fbolt(2)/(pi*Dbolt2*Leng2))*(1/(0.62*Matbolt(Matbolt2,2)));
nthreads3 = (Fbolt(3)/(pi*Dbolt3*Leng3))*(1/(0.62*Matbolt(Matbolt3,2)));
% This output assumes all bolts same diameter, same threaded engagement
% length
boltdata(i,:) = [Dbolt1, Leng1, Fbolt', nshank1, nshank2, nshank3,
nthreads1, nthreads2, nthreads3,...
max(nshank1, nthreads1), max(nshank2, nthreads2),
max(nshank3, nthreads3)];
i = i+1;
end
end
