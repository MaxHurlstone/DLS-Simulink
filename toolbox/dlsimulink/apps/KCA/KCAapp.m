classdef KCAapp < matlab.apps.App

    % Used to locate and load the app's XML configuration file
    properties (Access = public, Constant)
        AppConfigFilename = './KCAapp.xml'; % File path to the app configuration file containing component layout and settings
    end

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                        matlab.ui.Figure
        RootGrid                        matlab.ui.container.GridLayout
        MainPanel                       matlab.ui.container.Panel
        MainGrid                        matlab.ui.container.GridLayout
        OutputTable                     matlab.ui.control.Table
        SchematicAxes                   matlab.ui.control.UIAxes
        SidebarGrid                     matlab.ui.container.GridLayout
        thp_pre3                        matlab.ui.control.NumericEditField
        thp_pre3Label                   matlab.ui.control.Label
        rp_pre3                         matlab.ui.control.NumericEditField
        rp_pre3Label                    matlab.ui.control.Label
        Fpz3                            matlab.ui.control.NumericEditField
        Fpz3Label                       matlab.ui.control.Label
        Fpy3                            matlab.ui.control.NumericEditField
        Fpy3Label                       matlab.ui.control.Label
        Fpx3                            matlab.ui.control.NumericEditField
        Fpx3Label                       matlab.ui.control.Label
        thp_pre2                        matlab.ui.control.NumericEditField
        thp_pre2Label                   matlab.ui.control.Label
        rp_pre2                         matlab.ui.control.NumericEditField
        rp_pre2Label                    matlab.ui.control.Label
        Fpz2                            matlab.ui.control.NumericEditField
        Fpz2Label                       matlab.ui.control.Label
        Fpy2                            matlab.ui.control.NumericEditField
        Fpy2Label                       matlab.ui.control.Label
        Fpx2                            matlab.ui.control.NumericEditField
        Fpx2Label                       matlab.ui.control.Label
        thp_pre1                        matlab.ui.control.NumericEditField
        thp_pre1Label                   matlab.ui.control.Label
        rp_pre1                         matlab.ui.control.NumericEditField
        rp_pre1Label                    matlab.ui.control.Label
        Fpz1                            matlab.ui.control.NumericEditField
        Fpz1Label                       matlab.ui.control.Label
        Fpy1                            matlab.ui.control.NumericEditField
        Fpy1Label                       matlab.ui.control.Label
        Fpx1                            matlab.ui.control.NumericEditField
        Fpx1Label                       matlab.ui.control.Label
        PreloadHeader                   matlab.ui.control.Label
        Zerr                            matlab.ui.control.NumericEditField
        ZerrLabel                       matlab.ui.control.Label
        Yerr                            matlab.ui.control.NumericEditField
        YerrLabel                       matlab.ui.control.Label
        Xerr                            matlab.ui.control.NumericEditField
        XerrLabel                       matlab.ui.control.Label
        ErrorHeader                     matlab.ui.control.Label
        ZL                              matlab.ui.control.NumericEditField
        ZLLabel                         matlab.ui.control.Label
        YL                              matlab.ui.control.NumericEditField
        YLLabel                         matlab.ui.control.Label
        XL                              matlab.ui.control.NumericEditField
        XLLabel                         matlab.ui.control.Label
        MLz                             matlab.ui.control.NumericEditField
        MLzLabel                        matlab.ui.control.Label
        MLy                             matlab.ui.control.NumericEditField
        MLyLabel                        matlab.ui.control.Label
        MLx                             matlab.ui.control.NumericEditField
        MLxLabel                        matlab.ui.control.Label
        FLz                             matlab.ui.control.NumericEditField
        FLzLabel                        matlab.ui.control.Label
        FLy                             matlab.ui.control.NumericEditField
        FLyLabel                        matlab.ui.control.Label
        FLx                             matlab.ui.control.NumericEditField
        FLxLabel                        matlab.ui.control.Label
        LoadsHeader                     matlab.ui.control.Label
        Rgrv3                           matlab.ui.control.NumericEditField
        RgrvLabel3                      matlab.ui.control.Label
        Dball3                          matlab.ui.control.NumericEditField
        DballLabel3                     matlab.ui.control.Label
        thg3                            matlab.ui.control.NumericEditField
        thgLabel3                       matlab.ui.control.Label
        th3                             matlab.ui.control.NumericEditField
        thLabel3                        matlab.ui.control.Label
        r3                              matlab.ui.control.NumericEditField
        rLabel3                         matlab.ui.control.Label
        Coupling3Header                 matlab.ui.control.Label
        Rgrv2                           matlab.ui.control.NumericEditField
        RgrvLabel2                      matlab.ui.control.Label
        Dball2                          matlab.ui.control.NumericEditField
        DballLabel2                     matlab.ui.control.Label
        thg2                            matlab.ui.control.NumericEditField
        thgLabel2                       matlab.ui.control.Label
        th2                             matlab.ui.control.NumericEditField
        thLabel2                        matlab.ui.control.Label
        r2                              matlab.ui.control.NumericEditField
        rLabel2                         matlab.ui.control.Label
        Coupling2Header                 matlab.ui.control.Label
        Rgrv1                           matlab.ui.control.NumericEditField
        RgrvLabel1                      matlab.ui.control.Label
        Dball1                          matlab.ui.control.NumericEditField
        DballLabel1                     matlab.ui.control.Label
        thg1                            matlab.ui.control.NumericEditField
        thgLabel1                       matlab.ui.control.Label
        th1                             matlab.ui.control.NumericEditField
        thLabel1                        matlab.ui.control.Label
        r1                              matlab.ui.control.NumericEditField
        rLabel1                         matlab.ui.control.Label
        Coupling1Header                 matlab.ui.control.Label
        SymmetricCheckBox               matlab.ui.control.CheckBox
        AddCustomButton                 matlab.ui.control.Button
        GrooveDropdown                  matlab.ui.control.DropDown
        GrooveLabel                     matlab.ui.control.Label
        BallDropdown                    matlab.ui.control.DropDown
        BallLabel                       matlab.ui.control.Label
        MaterialsHeader                 matlab.ui.control.Label
    end

    properties (Access = private)
        CustomMaterialCount = 0
        Matball = [ 2758000000, 310300000000, 0.3; 103400000, 10340000000, 0.2; 1724000000, 204100000000, 0.29; 1020000000, 200000000000, 0.29; 2758000000, 310300000000, 0.3 ]
        Matgroove = [ 2758000000, 310300000000, 0.3; 103400000, 10340000000, 0.2; 1724000000, 204100000000, 0.29; 1020000000, 200000000000, 0.29; 2758000000, 310300000000, 0.3 ]
    end

    methods (Access = private)

        function computeResults(app)
            materialNames = {'Carbide', 'Plastic', 'RC62 Steel', 'RC57 420 Stainless', 'Other'};
            matbalIdx = max(1, find(strcmp(app.BallDropdown.Value, materialNames), 1));
            matgrvIdx = max(1, find(strcmp(app.GrooveDropdown.Value, materialNames), 1));
            symmetric = app.SymmetricCheckBox.Value;
            r = [app.r1.Value, app.r2.Value, app.r3.Value];
            th = [app.th1.Value, app.th2.Value, app.th3.Value];
            thg = [app.thg1.Value, app.thg2.Value, app.thg3.Value];
            Dball = [app.Dball1.Value, app.Dball2.Value, app.Dball3.Value];
            Rgrv = [app.Rgrv1.Value, app.Rgrv2.Value, app.Rgrv3.Value];
            FLx = app.FLx.Value; FLy = app.FLy.Value; FLz = app.FLz.Value;
            MLx = app.MLx.Value; MLy = app.MLy.Value; MLz = app.MLz.Value;
            XL = app.XL.Value; YL = app.YL.Value; ZL = app.ZL.Value;
            Xerr = app.Xerr.Value; Yerr = app.Yerr.Value; Zerr = app.Zerr.Value;
            Fpx = [app.Fpx1.Value, app.Fpx2.Value, app.Fpx3.Value];
            Fpy = [app.Fpy1.Value, app.Fpy2.Value, app.Fpy3.Value];
            Fpz = [app.Fpz1.Value, app.Fpz2.Value, app.Fpz3.Value];
            rp_pre = [app.rp_pre1.Value, app.rp_pre2.Value, app.rp_pre3.Value];
            thp_pre = [app.thp_pre1.Value, app.thp_pre2.Value, app.thp_pre3.Value];
            Rbminor = Dball/2; Rbmajor = Dball/2;
            if symmetric
                r(2:3) = r(1); th(2) = th(1)+2*pi/3; th(3) = th(1)+4*pi/3;
                thg(2:3) = thg(1); Dball(2:3) = Dball(1);
                Rbminor(2:3) = Rbminor(1); Rbmajor(2:3) = Rbmajor(1);
                Rgrv(2:3) = Rgrv(1);
                Fpx(2:3) = Fpx(1); Fpy(2:3) = Fpy(1); Fpz(2:3) = Fpz(1);
                rp_pre(2:3) = rp_pre(1);
                thp_pre(2) = thp_pre(1)+2*pi/3; thp_pre(3) = thp_pre(1)+4*pi/3;
            end
            Xb = zeros(1,6); Yb = zeros(1,6); Zb = zeros(1,6);
            Ab = zeros(1,6); Bb = zeros(1,6); Gb = zeros(1,6);
            for j = 1:3
                k = 2*j-1;
                Xb(k) = r(j)*cos(th(j))+Dball(j)*sqrt(2)*sin(th(j))/4;
                Xb(k+1) = r(j)*cos(th(j))-Dball(j)*sqrt(2)*sin(th(j))/4;
                Yb(k) = r(j)*sin(th(j))-Dball(j)*sqrt(2)*cos(th(j))/4;
                Yb(k+1) = r(j)*sin(th(j))+Dball(j)*sqrt(2)*cos(th(j))/4;
                Zb(k) = -Dball(j)*sqrt(2)/4; Zb(k+1) = -Dball(j)*sqrt(2)/4;
                tden = sqrt(1+tan(thg(j))^2);
                Ab(k) = -sin(th(j))/tden; Ab(k+1) = sin(th(j))/tden;
                Bb(k) = cos(th(j))/tden; Bb(k+1) = -cos(th(j))/tden;
                Gb(k) = tan(thg(j))/tden; Gb(k+1) = tan(thg(j))/tden;
            end
            xp_pre = rp_pre.*cos(thp_pre);
            yp_pre = rp_pre.*sin(thp_pre);
            zp_pre = 2*Dball;
            Eg = app.Matgroove(matgrvIdx,2); vg = app.Matgroove(matgrvIdx,3);
            Eb = app.Matball(matbalIdx,2); vb = app.Matball(matbalIdx,3);
            S = min(app.Matgroove(matgrvIdx,1), app.Matball(matbalIdx,1));
            Ee = 1/((1-vg^2)/Eg+(1-vb^2)/Eb);
            Re = zeros(1,3); theta_c = zeros(1,3);
            alpha = zeros(1,3); beta = zeros(1,3); lambda = zeros(1,3);
            for j = 1:3
                Re(j) = 1/(1/Rgrv(j)+1/Rbminor(j)+1/Rbmajor(j));
                ct = Re(j)*sqrt((1/Rgrv(j))^2+(1/Rbmajor(j)-1/Rbminor(j))^2+2*(-1/Rgrv(j))*(1/Rbmajor(j)-1/Rbminor(j)));
                theta_c(j) = acos(ct);
                alpha(j) = 1.939*2.71831^(-5.26*theta_c(j))+1.78*2.71831^(-1.09*theta_c(j))+0.723/theta_c(j)+0.221;
                beta(j) = 35.228*2.71831^(-0.98*theta_c(j))-32.424*2.71831^(-1.0475*theta_c(j))+1.486*theta_c(j)-2.634;
                lambda(j) = -0.214*2.71831^(-4.95*theta_c(j))-0.179*theta_c(j)^2+0.555*theta_c(j)+0.319;
            end
            A = [Ab; Bb; Gb; -Bb.*Zb+Gb.*Yb; Ab.*Zb-Gb.*Xb; -Ab.*Yb+Bb.*Xb];
            Bwithloads = [-(sum(Fpx)+FLx); -(sum(Fpy)+FLy); -(sum(Fpz)+FLz);
                -(-sum(Fpy.*zp_pre)+sum(Fpz.*yp_pre)-FLy*ZL+FLz*YL+MLx);
                -(sum(Fpx.*zp_pre)-sum(Fpz.*xp_pre)+FLx*ZL-FLz*XL+MLy);
                -(-sum(Fpx.*yp_pre)+sum(Fpy.*xp_pre)-FLx*YL+FLy*XL+MLz)];
            Bnoloads = [-sum(Fpx); -sum(Fpy); -sum(Fpz);
                -(-sum(Fpy.*zp_pre)+sum(Fpz.*yp_pre));
                -(sum(Fpx.*zp_pre)-sum(Fpz.*xp_pre));
                -(-sum(Fpx.*yp_pre)+sum(Fpy.*xp_pre))];
            Fbn = A\Bwithloads; Fb = A\Bnoloads;
            del = zeros(1,6);
            for c = 1:6
                j = ceil(c/2);
                del(c) = lambda(j)*(2*Fbn(c)^2/(3*Re(j)*Ee^2))^(1/3)-lambda(j)*(2*Fb(c)^2/(3*Re(j)*Ee^2))^(1/3);
            end
            rmaj = zeros(1,6); rmin = zeros(1,6);
            for c = 1:6
                j = ceil(c/2);
                rmaj(c) = alpha(j)*(1.5*Fbn(c)*Re(j)/Ee)^(1/3);
                rmin(c) = beta(j)*(1.5*Fbn(c)*Re(j)/Ee)^(1/3);
            end
            sig = zeros(1,6);
            for c = 1:6
                sig(c) = 3*Fbn(c)/(2*pi*rmaj(c)*rmin(c));
            end
            xbO = zeros(1,3); ybO = zeros(1,3); zbO = zeros(1,3);
            for j = 1:3
                k = 2*j-1;
                xbO(j) = (Xb(k)+Xb(k+1)+Dball(j)*Ab(k)+Dball(j)*Ab(k+1))/2;
                ybO(j) = (Yb(k)+Yb(k+1)+Dball(j)*Bb(k)+Dball(j)*Bb(k+1))/2;
                zbO(j) = (Zb(k)+Zb(k+1)+0.5*Dball(j)*Gb(k)+0.5*Dball(j)*Gb(k+1))/2;
            end
            xbN = zeros(1,3); ybN = zeros(1,3); zbN = zeros(1,3);
            for j = 1:3
                k = 2*j-1;
                xbN(j) = xbO(j)+(Ab(k)*del(k)+Ab(k+1)*del(k+1))/2;
                ybN(j) = ybO(j)+(Bb(k)*del(k)+Bb(k+1)*del(k+1))/2;
                zbN(j) = zbO(j)+(Gb(k)*del(k)+Gb(k+1)*del(k+1))/2;
            end
            dx = xbN-xbO; dy = ybN-ybO; dz = zbN-zbO;
            LotI = sqrt((xbO(1)-xbO(2))^2+(ybO(1)-ybO(2))^2+(zbO(1)-zbO(2))^2);
            LttI = sqrt((xbO(2)-xbO(3))^2+(ybO(2)-ybO(3))^2+(zbO(2)-zbO(3))^2);
            LtoI = sqrt((xbO(3)-xbO(1))^2+(ybO(3)-ybO(1))^2+(zbO(3)-zbO(1))^2);
            LotN = sqrt((xbN(1)-xbN(2))^2+(ybN(1)-ybN(2))^2+(zbN(1)-zbN(2))^2);
            LttN = sqrt((xbN(2)-xbN(3))^2+(ybN(2)-ybN(3))^2+(zbN(2)-zbN(3))^2);
            LtoN = sqrt((xbN(3)-xbN(1))^2+(ybN(3)-ybN(1))^2+(zbN(3)-zbN(1))^2);
            Aot = 180*atan2((ybO(1)-ybO(2)),(xbO(1)-xbO(2)))/pi;
            Att = 180*atan2((ybO(3)-ybO(2)),(xbO(3)-xbO(2)))/pi;
            Ato = 180*atan2((ybO(1)-ybO(3)),(xbO(1)-xbO(3)))/pi;
            Angone = 180*acos((LttI^2-LotI^2-LtoI^2)/(-2*LotI*LtoI))/pi;
            Angtwo = 180*acos((LtoI^2-LotI^2-LttI^2)/(-2*LotI*LttI))/pi;
            Angthree = 180*acos((LotI^2-LtoI^2-LttI^2)/(-2*LtoI*LttI))/pi;
            Aone = LotN*sin(pi*abs(Aot-Att)/180);
            Atwo = LttN*sin(pi*abs(Aot-Att)/180);
            Athree = LttN*sin(pi*abs(Ato-Att)/180);
            Ttt = dz(1)/Aone; Tto = dz(2)/Atwo; Tot = dz(3)/Athree;
            AmtwoO = Att+Angtwo/2; AmthreeO = Ato+Angthree/2;
            AbtwoO = ybO(2)-tan(pi*AmtwoO/180)*xbO(2);
            AbthreeO = ybO(3)-tan(pi*AmthreeO/180)*xbO(3);
            xci = (AbthreeO-AbtwoO)/(pi*(AmtwoO-AmthreeO)/180);
            yci = (pi*AmtwoO/180)*xci+AbtwoO;
            zci = (zbO(1)+zbO(2)+zbO(3))/3;
            DLotI = LotI-LotN; DLttI = LttI-LttN; DLtoI = LtoI-LtoN;
            ratio1 = max(abs(del(1)),abs(del(2)))/(Dball(1)/2)/abs(DLotI/LotI);
            ratio2 = max(abs(del(3)),abs(del(4)))/(Dball(2)/2)/abs(DLttI/LttI);
            ratio3 = max(abs(del(5)),abs(del(6)))/(Dball(3)/2)/abs(DLtoI/LtoI);
            Dcone = sqrt((xbN(1)-xci)^2+(ybN(1)-yci)^2+(zbN(1)-zci)^2);
            Dctwo = sqrt((xbN(2)-xci)^2+(ybN(2)-yci)^2+(zbN(2)-zci)^2);
            Dcthree = sqrt((xbN(3)-xci)^2+(ybN(3)-yci)^2+(zbN(3)-zci)^2);
            dxc = dx(1)*(LotI-Dcone)/LotI+dx(2)*(LttI-Dctwo)/LttI+dx(3)*(LtoI-Dcthree)/LtoI;
            dyc = dy(1)*(LotI-Dcone)/LotI+dy(2)*(LttI-Dctwo)/LttI+dy(3)*(LtoI-Dcthree)/LtoI;
            dzc = dz(1)*(LotI-Dcone)/LotI+dz(2)*(LttI-Dctwo)/LttI+dz(3)*(LtoI-Dcthree)/LtoI;
            EpsZ1 = sqrt((0.5*(Ab(1)*del(1)+Ab(2)*del(2)))^2+(0.5*(Bb(1)*del(1)+Bb(2)*del(2)))^2)*sign(-(Ab(1)*del(1)+Ab(2)*del(2)))/sqrt((xbO(1)-xci)^2+(ybO(1)-yci)^2);
            EpsZ2 = sqrt((0.5*(Ab(3)*del(3)+Ab(4)*del(4)))^2+(0.5*(Bb(3)*del(3)+Bb(4)*del(4)))^2)*sign(Ab(3)*del(3)+Ab(4)*del(4))/sqrt((xbO(2)-xci)^2+(ybO(2)-yci)^2);
            EpsZ3 = sqrt((0.5*(Ab(5)*del(5)+Ab(6)*del(6)))^2+(0.5*(Bb(5)*del(5)+Bb(6)*del(6)))^2)*sign(Ab(5)*del(5)+Ab(6)*del(6))/sqrt((xbO(3)-xci)^2+(ybO(3)-yci)^2);
            EpsX = Ttt*cos(pi*Att/180)+Tto*cos(pi*Ato/180)-Tot*cos(pi*Aot/180);
            EpsY = Ttt*sin(pi*Att/180)+Tto*sin(pi*Ato/180)-Tot*sin(pi*Aot/180);
            EpsZ = (EpsZ1+EpsZ2+EpsZ3)/3;
            HTM = [1,-EpsZ,EpsY,dxc; EpsZ,1,-EpsX,dyc; -EpsY,EpsX,1,dzc; 0,0,0,1];
            XYZInt = [Xerr; Yerr; Zerr; 1]; ErrorInt = HTM*XYZInt-XYZInt;
            DeltaX = ErrorInt(1); DeltaY = ErrorInt(2); DeltaZ = ErrorInt(3);
            DeltaRMS = sqrt(DeltaX^2+DeltaY^2+DeltaZ^2);
            app.updateSchematic(r, th, xbO, ybO, Fbn, Fb, sig, S, DeltaX, DeltaY, DeltaZ, DeltaRMS);
            tData = {'Fbn [N]',Fbn(1),Fbn(2),Fbn(3),Fbn(4),Fbn(5),Fbn(6); 'Fb [N]',Fb(1),Fb(2),Fb(3),Fb(4),Fb(5),Fb(6); 'sig [Pa]',sig(1),sig(2),sig(3),sig(4),sig(5),sig(6); 'sig/S',(0.3*sig(1))/(0.5*S),(0.3*sig(2))/(0.5*S),(0.3*sig(3))/(0.5*S),(0.3*sig(4))/(0.5*S),(0.3*sig(5))/(0.5*S),(0.3*sig(6))/(0.5*S); 'Hertz ratio',ratio1,ratio1,ratio2,ratio2,ratio3,ratio3; 'DeltaX [um]',1e6*DeltaX,1e6*DeltaX,1e6*DeltaX,1e6*DeltaX,1e6*DeltaX,1e6*DeltaX; 'DeltaY [um]',1e6*DeltaY,1e6*DeltaY,1e6*DeltaY,1e6*DeltaY,1e6*DeltaY,1e6*DeltaY; 'DeltaZ [um]',1e6*DeltaZ,1e6*DeltaZ,1e6*DeltaZ,1e6*DeltaZ,1e6*DeltaZ,1e6*DeltaZ; 'DeltaRMS [um]',1e6*DeltaRMS,1e6*DeltaRMS,1e6*DeltaRMS,1e6*DeltaRMS,1e6*DeltaRMS,1e6*DeltaRMS};
            app.OutputTable.Data = tData;
        end

        function updateSchematic(app, r, th, xbO, ybO, Fbn, Fb, sig, S, DeltaX, DeltaY, DeltaZ, DeltaRMS)
            ax = app.SchematicAxes; cla(ax); hold(ax, 'on');
            colors = {'ro', 'bs', 'gd'};
            xPos = r.*cos(th); yPos = r.*sin(th);
            for j = 1:3
                k = 2*j-1;
                plot(ax, xPos(j), yPos(j), colors{j}, 'MarkerSize', 12, 'LineWidth', 2);
                text(ax, xPos(j), yPos(j), sprintf('  %d', j), 'FontSize', 14, 'FontWeight', 'bold');
                avgFb = (Fb(k)+Fb(k+1))/2; avgSig = (sig(k)+sig(k+1))/2;
                text(ax, xPos(j), yPos(j), sprintf('Fb=%.1fN sig=%.2ePa', avgFb, avgSig), 'FontSize', 10, 'VerticalAlignment', 'top', 'HorizontalAlignment', 'center');
            end
            midX = mean(xbO); midY = mean(ybO);
            plot(ax, midX, midY, 'kp', 'MarkerSize', 10, 'MarkerFaceColor', 'k');
            text(ax, midX, midY, '  Centroid', 'FontSize', 11, 'FontWeight', 'bold');
for j = 1:3
            dx = midX - xPos(j); dy = midY - yPos(j);
            quiver(ax, xPos(j), yPos(j), dx*0.7, dy*0.7, 0, 'k-', 'LineWidth', 1.5, 'MaxHeadSize', 0.3);
        end
        xPad = max(max(xPos), midX) - min(min(xPos), midX);
        yPad = max(max(yPos), midY) - min(min(yPos), midY);
            pad = 0.3*max(xPad, yPad);
xlim(ax, [min(min(xPos), midX)-pad, max(max(xPos), midX)+pad]);
        ylim(ax, [min(min(yPos), midY)-pad, max(max(yPos), midY)+pad]);
            title(ax, sprintf('DX=%.3fum DY=%.3fum DZ=%.3fum RMS=%.3fum', 1e6*DeltaX, 1e6*DeltaY, 1e6*DeltaZ, 1e6*DeltaRMS), 'FontSize', 10);
            hold(ax, 'off'); axis(ax, 'equal'); grid(ax, 'on');
        end

    end

    % Callbacks that handle component events
    methods

        % Code that executes after component creation
        function startupFcn(app)
            app.computeResults();
        end

        % Value changed function: BallDropdown, Dball1, Dball2, Dball3, 
        % ...and 40 other components
        function onFieldChanged(app, event)
            app.computeResults();
        end

        % Button pushed function: AddCustomButton
        function onAddCustomMaterial(app, event)
            prompt = {'Name:', 'Hertz Limit [Pa]:', 'Modulus [Pa]:', 'Poisson Ratio:'};
            defaults = {'Custom', '1e9', '2e11', '0.3'};
            inputs = inputdlg(prompt, 'Add Custom Material', 1, defaults);
            if isempty(inputs); return; end
            name = inputs{1}; hz = str2double(inputs{2}); md = str2double(inputs{3}); pr = str2double(inputs{4});
            if any(isnan([hz,md,pr])); return; end
            n = size(app.Matball,1)+1; app.Matball(n,:)=[hz,md,pr]; app.Matgroove(n,:)=[hz,md,pr];
            items = app.BallDropdown.Items; app.BallDropdown.Items=[items,{name}];
            app.GrooveDropdown.Items=[app.GrooveDropdown.Items,{name}]; app.computeResults();
        end

        % Value changed function: SymmetricCheckBox
        function onSymmetricChanged(app, event)
            rh = app.SidebarGrid.RowHeight;
            if app.SymmetricCheckBox.Value
                for i = 12:23; rh{i} = 0; end
            else
                for i = 12:23; rh{i} = 'fit'; end
            end
            app.SidebarGrid.RowHeight = rh; app.computeResults();
        end
    end

    % App creation
    methods (Access = public)

        % Construct app
        function app = KCAapp(varargin)
            app = app@matlab.apps.App(varargin{:});

            if nargout == 0
                clear app
            end
        end
    end
end