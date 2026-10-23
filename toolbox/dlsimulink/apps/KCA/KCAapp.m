classdef KCAapp < matlab.apps.App
    %KCAAPP Kinematic Coupling Generator.
    %   Interactive GUI for parametric design studies of three-groove
    %   kinematic couplings. Enables real-time exploration of material
    %   selection, geometry, loads, preload, and error motion.
    %   Computation is delegated to utils\kinematicCoupling.m which
    %   reproduces the algorithm from kincoup.xls by John Hart, MIT PERG.
    %
    %   See also KINEMATICCOUPLING
    %
    %   DLSimulink Toolbox

    % Used to locate and load the app's XML configuration file
    properties (Access = public, Constant)
        AppConfigFilename = './KCAapp.xml'; % File path to the app configuration file containing component layout and settings
    end

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                        matlab.ui.Figure
        RootGrid                        matlab.ui.container.GridLayout
        InfoPanel                       matlab.ui.container.Panel
        InfoGrid                        matlab.ui.container.GridLayout
        InfoLabel                       matlab.ui.control.Label
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
        PreloadAtBallCheckBox           matlab.ui.control.CheckBox
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
        % Application-private state and material databases.
        % CustomMaterialCount tracks user-added materials; Matball and
        % Matgroove hold the per-material property arrays that are
        % indexed by the ball/groove dropdown selections.
        CustomMaterialCount = 0;
        Matball =  [2758000000, 310300000000, 0.3;...
                    103400000, 10340000000, 0.2;...
                    1724000000, 204100000000, 0.29;...
                    1020000000, 200000000000, 0.29;...
                    1500000000, 200000000000, 0.29];
    end

    properties (Access = private, Constant)
        % SidebarGrid row ranges for visibility toggling.
        % These centralise the magic numbers so a reorder in the XML
        % only requires updating the constants here.
        SymmetricHiddenRows = 12:23
        SymmetricHiddenPreloadRows = 45:54
        PreloadAtBallHiddenRows = [43, 44, 48, 49, 53, 54]
    end

    properties (Access = private, Dependent)
        Matgroove
    end

    methods
        function value = get.Matgroove(app)
            value = app.Matball;
        end
    end

    methods (Access = private)
        % Computation and visualization methods (not exposed as callbacks)

        function computeResults(app)
            uiState = app.readUIState();
            app.updateAngleDisplay(uiState.geometry.th);
            res = kinematicCoupling(uiState.materials, uiState.geometry, ...
                uiState.loads, uiState.errorPt, uiState.preload, uiState.symmetric);
            app.updateSchematic(res.r, res.th, res.xbO, res.ybO, res.Fbn, res.Fb, ...
                res.q, res.S, res.DeltaX, res.DeltaY, res.DeltaZ, res.DeltaRMS);
            tData = app.buildOutputTable(res);
            app.OutputTable.Data = tData;
            app.applyTableStyling(tData);
        end

        function uiState = readUIState(app)
            % Read all UI controls into a flat struct for the computation engine.
            % Returns both geometry.r (raw) and geometry.th (angle-locked via
            % kinematicAngles), plus materials, loads, errorPt, preload, symmetric.
            items = app.BallDropdown.Items;
            matbalIdx = max(1, find(strcmp(app.BallDropdown.Value, items), 1));
            matgrvIdx = max(1, find(strcmp(app.GrooveDropdown.Value, items), 1));
            uiState.materials.Matball = app.Matball;
            uiState.materials.Matgroove = app.Matgroove;
            uiState.materials.ballIdx = matbalIdx;
            uiState.materials.grooveIdx = matgrvIdx;
            uiState.geometry.r = [app.r1.Value, app.r2.Value, app.r3.Value];
            if app.SymmetricCheckBox.Value
                effR = [app.r1.Value, app.r1.Value, app.r1.Value];
            else
                effR = [app.r1.Value, app.r2.Value, app.r3.Value];
            end
            if any(effR <= 0) || any(~isfinite(effR))
                warning('KCAapp:InvalidRadii', ...
                    'Coupling radii must be finite and positive; keeping previous angles.');
                lockedTh = [app.th1.Value, app.th2.Value, app.th3.Value];
            else
                lockedTh = kinematicAngles(effR, 0);
            end
            uiState.geometry.th = lockedTh;
            uiState.geometry.thg = [app.thg1.Value, app.thg2.Value, app.thg3.Value];
            uiState.geometry.Dball = [app.Dball1.Value, app.Dball2.Value, app.Dball3.Value];
            uiState.geometry.Rgrv = [app.Rgrv1.Value, app.Rgrv2.Value, app.Rgrv3.Value];
            uiState.loads.FLx = app.FLx.Value; uiState.loads.FLy = app.FLy.Value; uiState.loads.FLz = app.FLz.Value;
            uiState.loads.MLx = app.MLx.Value; uiState.loads.MLy = app.MLy.Value; uiState.loads.MLz = app.MLz.Value;
            uiState.loads.XL = app.XL.Value; uiState.loads.YL = app.YL.Value; uiState.loads.ZL = app.ZL.Value;
            uiState.errorPt.X = app.Xerr.Value; uiState.errorPt.Y = app.Yerr.Value; uiState.errorPt.Z = app.Zerr.Value;
            uiState.preload.Fpx = [app.Fpx1.Value, app.Fpx2.Value, app.Fpx3.Value];
            uiState.preload.Fpy = [app.Fpy1.Value, app.Fpy2.Value, app.Fpy3.Value];
            uiState.preload.Fpz = [app.Fpz1.Value, app.Fpz2.Value, app.Fpz3.Value];
            uiState.preload.rp = [app.rp_pre1.Value, app.rp_pre2.Value, app.rp_pre3.Value];
            uiState.preload.thp = [app.thp_pre1.Value, app.thp_pre2.Value, app.thp_pre3.Value];
            uiState.preload.useBallLocations = app.PreloadAtBallCheckBox.Value;
            uiState.symmetric = app.SymmetricCheckBox.Value;
        end

        function updateAngleDisplay(app, th)
            app.th1.Value = th(1);
            app.th2.Value = th(2);
            app.th3.Value = th(3);
        end

        function tData = buildOutputTable(app, res)
            sigS = res.sigsmax / (0.5 * res.S);
            tData = {'Fbn [N]',res.Fbn(1),res.Fbn(2),res.Fbn(3),res.Fbn(4),res.Fbn(5),res.Fbn(6);
                'Fb [N]',res.Fb(1),res.Fb(2),res.Fb(3),res.Fb(4),res.Fb(5),res.Fb(6);
                'Contact P [Pa]',res.q(1),res.q(2),res.q(3),res.q(4),res.q(5),res.q(6);
                'Max. Shear [Pa]',res.sigsmax(1),res.sigsmax(2),res.sigsmax(3),res.sigsmax(4),res.sigsmax(5),res.sigsmax(6);
                'UTS [Pa]',res.S,res.S,res.S,res.S,res.S,res.S;
                'Max. Shear / 0.5*UTS',sigS(1),sigS(2),sigS(3),sigS(4),sigS(5),sigS(6);
                'Hertz ratio',res.ratio(1),res.ratio(1),res.ratio(2),res.ratio(2),res.ratio(3),res.ratio(3);
                'DeltaX [um]',1e6*res.DeltaX,1e6*res.DeltaX,1e6*res.DeltaX,1e6*res.DeltaX,1e6*res.DeltaX,1e6*res.DeltaX;
                'DeltaY [um]',1e6*res.DeltaY,1e6*res.DeltaY,1e6*res.DeltaY,1e6*res.DeltaY,1e6*res.DeltaY,1e6*res.DeltaY;
                'DeltaZ [um]',1e6*res.DeltaZ,1e6*res.DeltaZ,1e6*res.DeltaZ,1e6*res.DeltaZ,1e6*res.DeltaZ,1e6*res.DeltaZ;
                'DeltaRMS [um]',1e6*res.DeltaRMS,1e6*res.DeltaRMS,1e6*res.DeltaRMS,1e6*res.DeltaRMS,1e6*res.DeltaRMS,1e6*res.DeltaRMS};
        end

        function applyTableStyling(app, tData)
            % Color the 'Max. Shear / 0.5*UTS' row (data row 6, cols 2-7)
            % by margin: value < 1 → dark green on light greenish-grey (OK);
            % value > 1 → dark red on light reddish-grey (limit exceeded).
            if height(app.OutputTable.StyleConfigurations) > 0
                removeStyle(app.OutputTable, 1:height(app.OutputTable.StyleConfigurations));
            end
            margin = [tData{6, 2:7}];
            for c = 1:6
                v = margin(c);
                if v < 1
                    s = uistyle('BackgroundColor', [0.90 0.96 0.90], ...
                        'FontColor', [0.06 0.42 0.14]);
                elseif v > 1
                    s = uistyle('BackgroundColor', [0.96 0.90 0.90], ...
                        'FontColor', [0.62 0.07 0.07]);
                else
                    continue;
                end
                addStyle(app.OutputTable, s, 'cell', [6, c + 1]);
            end
        end

        function updateSchematic(app, r, th, xbO, ybO, Fbn, Fb, sig, S, DeltaX, DeltaY, DeltaZ, DeltaRMS)
            % updateSchematic  Refresh the coupling layout visualization.
            % Draws three line groups on the schematic axes:
            %   a) Groove direction lines (black) — from each ball center
            %      toward the incenter along the angle bisector
            %   b) Coupling triangle (blue dashed) — edges joining the
            %      three ball-center positions
            %   c) Normal force plane triangle (red dashed) — lines
            %      perpendicular to the angle bisectors at each ball
            %      center; pairwise intersections form a second triangle
            % Groove directions are the angle bisectors from
            % kinematicTriangle(), which handles non-equilateral triangles
            % correctly (the incenter is NOT the arithmetic mean of vertices
            % for asymmetric couplings).
            ax = app.SchematicAxes;
            cla(ax);
            hold(ax, 'on');
            xPos = r.*cos(th);
            yPos = r.*sin(th);

            % Triangle geometry via kinematicTriangle — proper incenter and
            % angle bisectors (not the centroid or radial approximation)
            tri = kinematicTriangle(xbO, ybO);
            xci = tri.xci;
            yci = tri.yci;

            % (a) Groove direction lines — ball center to incenter
            for j = 1:3
                plot(ax, [xbO(j), xci], [ybO(j), yci], 'k-', 'LineWidth', 1.5);
            end

            % (b) Coupling triangle — ball-center edges
            plot(ax, [xbO(1), xbO(2), xbO(3), xbO(1)], ...
                [ybO(1), ybO(2), ybO(3), ybO(1)], ...
                'b--', 'LineWidth', 1.5);

            % (c) Normal force plane triangle — lines perpendicular to each
            %     angle bisector; pairwise intersections form the vertices
            nTriX = zeros(1, 3);
            nTriY = zeros(1, 3);
            for j = 1:3
                j2 = mod(j, 3) + 1;
                M = [tri.normalX(j), -tri.normalX(j2); ...
                    tri.normalY(j), -tri.normalY(j2)];
                dp = [xbO(j2) - xbO(j); ybO(j2) - ybO(j)];
                t = M \ dp;
                nTriX(j) = xbO(j) + t(1) * tri.normalX(j);
                nTriY(j) = ybO(j) + t(1) * tri.normalY(j);
            end
            plot(ax, [nTriX(1), nTriX(2), nTriX(3), nTriX(1)], ...
                [nTriY(1), nTriY(2), nTriY(3), nTriY(1)], ...
                'r--', 'LineWidth', 1.5);

            % Coupling point markers (uniform red circles) with contact pair labels
            for j = 1:3
                k = 2*j - 1;
                if j == 1; a = 1; b = 2;
                elseif j == 2; a = 3; b = 4;
                elseif j == 3; a = 5; b = 6; end
                plot(ax, xPos(j), yPos(j), 'ro', 'MarkerSize', 12, 'LineWidth', 2);
                text(ax, 1.05*xPos(j), 1.05*yPos(j), ...
                    sprintf('  %d (%d,%d)', j, a, b), ...
                    'FontSize', 16, 'FontWeight', 'bold');
            end

            % Incenter marker
            plot(ax, xci, yci, 'o', 'MarkerSize', 10, ...
                'MarkerFaceColor', 'k', 'MarkerEdgeColor', 'k');
            text(ax, 1.05*xci, 1.05*yci, '  Incenter', ...
                'FontSize', 12, 'FontWeight', 'bold');

            % Auto-scale with padding around all points
            allPts = [xbO, xci];
            xRng = max(allPts) - min(allPts);
            xPad = 0.3 * xRng;
            allPtsY = [ybO, yci];
            yRng = max(allPtsY) - min(allPtsY);
            yPad = 0.3 * yRng;
            xlim(ax, [min(allPts) - xPad, max(allPts) + xPad]);
            ylim(ax, [min(allPtsY) - yPad, max(allPtsY) + yPad]);

            title(ax, sprintf('DX=%.3fum DY=%.3fum DZ=%.3fum RMS=%.3fum', ...
                1e6*DeltaX, 1e6*DeltaY, 1e6*DeltaZ, 1e6*DeltaRMS), 'FontSize', 10);
            hold(ax, 'off');
            axis(ax, 'equal');
            grid(ax, 'on');
        end
    end

    % Callbacks that handle component events.
    % All value-change callbacks converge on computeResults().
    methods

        % Code that executes after component creation
        function startupFcn(app)
            app.computeResults();

            % Angle fields are locked (computed from radii); disable user editing
            app.th1.Enable = 'off';
            app.th2.Enable = 'off';
            app.th3.Enable = 'off';
        end

        % Value changed function: BallDropdown, Dball1, Dball2, Dball3, 
        % ...and 40 other components
        function onFieldChanged(app, event)
            % Triggered when any numeric field or dropdown changes value.
            app.computeResults();
        end

        % Button pushed function: AddCustomButton
        function onAddCustomMaterial(app, event)
            % Prompt user for custom material properties, append to the
            % in-memory material DB, and add the name to both dropdowns.
            % Materials are ephemeral — lost on app restart.
            prompt = {'Name:', 'Hertz Limit [Pa]:', 'Modulus [Pa]:', 'Poisson Ratio:'};
            defaults = {'Custom', '1e9', '2e11', '0.3'};
            inputs = inputdlg(prompt, 'Add Custom Material', 1, defaults);
            if isempty(inputs); return; end
            name = inputs{1};
            hz = str2double(inputs{2});
            md = str2double(inputs{3});
            pr = str2double(inputs{4});
            if any(isnan([hz,md,pr])); return; end
            n = size(app.Matball,1)+1;
            app.Matball(n,:)=[hz,md,pr];
            items = app.BallDropdown.Items;
            app.BallDropdown.Items=[items,{name}];
            app.GrooveDropdown.Items=[app.GrooveDropdown.Items,{name}];
            app.computeResults();
        end

        % Value changed function: SymmetricCheckBox
        function onSymmetricChanged(app, event)
            rh = app.SidebarGrid.RowHeight;
            if app.SymmetricCheckBox.Value
                for i = [app.SymmetricHiddenRows, app.SymmetricHiddenPreloadRows]; rh{i} = 0; end
            else
                for i = [app.SymmetricHiddenRows, app.SymmetricHiddenPreloadRows]; rh{i} = 'fit'; end
                if app.PreloadAtBallCheckBox.Value
                    for i = app.PreloadAtBallHiddenRows; rh{i} = 0; end
                end
            end
            app.SidebarGrid.RowHeight = rh;
            app.computeResults();
        end

        % Value changed function: PreloadAtBallCheckBox
        function onPreloadAtBallChanged(app, event)
            rh = app.SidebarGrid.RowHeight;
            if app.PreloadAtBallCheckBox.Value
                for i = app.PreloadAtBallHiddenRows; rh{i} = 0; end
            else
                for i = app.PreloadAtBallHiddenRows; rh{i} = 'fit'; end
            end
            app.SidebarGrid.RowHeight = rh;
            app.computeResults();
        end
    end

    % App creation
    % App creation — constructor generated by App Designer infrastructure.
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