classdef kinematicCouplingTest < matlab.unittest.TestCase
    %KINEMATICCOUPLINGTEST Unit tests for the kinematic coupling engine.
    %
    %   DLSimulink Toolbox

    methods (TestClassSetup)
        function addUtilsToPath(testCase)
            utilDir = fullfile(fileparts(mfilename('fullpath')), '..', 'utils');
            testCase.addTeardown(@() rmpath(utilDir));
            addpath(utilDir);
        end
    end

    methods (Test)
        function returnsExpectedStructFields(testCase)
            m = standardMaterials();
            g = standardGeometry();
            l = zeroLoads();
            e = zeroErrorPt();
            p = zeroPreload();
            res = kinematicCoupling(m, g, l, e, p, true);
            fields = {'Fbn','Fb','q','sigsmax','S','ratio', ...
                'DeltaX','DeltaY','DeltaZ','DeltaRMS','r','th','xbO','ybO'};
            for i = 1:numel(fields)
                testCase.verifyTrue(isfield(res, fields{i}), ...
                    sprintf('results struct missing field .%s', fields{i}));
            end
        end

        function symmetricPropagation(testCase)
            m = standardMaterials();
            g = standardGeometry();
            l = zeroLoads();
            e = zeroErrorPt();
            p = zeroPreload();
            res = kinematicCoupling(m, g, l, e, p, true);
            testCase.verifyEqual(res.r(2), res.r(1), 'AbsTol', 1e-12);
            testCase.verifyEqual(res.r(3), res.r(1), 'AbsTol', 1e-12);
            testCase.verifyEqual(res.th(2), res.th(1) + 2*pi/3, 'AbsTol', 1e-12);
            testCase.verifyEqual(res.th(3), res.th(1) + 4*pi/3, 'AbsTol', 1e-12);
        end

        function zeroLoadSanity(testCase)
            m = standardMaterials();
            g = standardGeometry();
            l = zeroLoads();
            e = zeroErrorPt();
            p = lightPreload();
            res = kinematicCoupling(m, g, l, e, p, true);
            testCase.verifyGreaterThanOrEqual(res.q, zeros(1,6));
            testCase.verifyFalse(any(isnan(res.q)));
            testCase.verifyGreaterThan(res.Fbn(1), 0);
        end

        function asymmetricOutput(testCase)
            m = standardMaterials();
            g = asymmetricGeometry();
            l = zeroLoads();
            e = zeroErrorPt();
            p = zeroPreload();
            res = kinematicCoupling(m, g, l, e, p, false);
            % Asymmetric radii and groove angles should give different outputs
            testCase.verifyNotEqual(res.r(2), res.r(1));
            testCase.verifyNotEqual(res.r(3), res.r(1));
        end

        function asymmetricWithSymmetricFlag(testCase)
            m = standardMaterials();
            g = asymmetricGeometry();
            l = zeroLoads();
            e = zeroErrorPt();
            p = zeroPreload();
            res = kinematicCoupling(m, g, l, e, p, true);
            testCase.verifyEqual(res.r(2), res.r(1), 'AbsTol', 1e-12);
            testCase.verifyEqual(res.th(2), res.th(1) + 2*pi/3, 'AbsTol', 1e-12);
        end
    end
end

function m = standardMaterials()
    m.Matball = [2758000000, 310300000000, 0.3;
                 103400000, 10340000000, 0.2;
                 1724000000, 204100000000, 0.29;
                 1020000000, 200000000000, 0.29;
                 1500000000, 200000000000, 0.29];
    m.Matgroove = m.Matball;
    m.ballIdx = 3;
    m.grooveIdx = 3;
end

function g = standardGeometry()
    g.r = [0.025, 0.025, 0.025];
    g.th = [0, 2*pi/3, 4*pi/3];
    g.thg = [0.785398, 0.785398, 0.785398];
    g.Dball = [0.008, 0.008, 0.008];
    g.Rgrv = [-0.004, -0.004, -0.004];
end

function g = asymmetricGeometry()
    g.r = [0.025, 0.030, 0.020];
    g.th = [0, 2*pi/3, 4*pi/3];
    g.thg = [0.785398, 0.698132, 0.872665];
    g.Dball = [0.008, 0.008, 0.008];
    g.Rgrv = [-0.004, -0.004, -0.004];
end

function l = zeroLoads()
    l.FLx = 0; l.FLy = 0; l.FLz = 0;
    l.MLx = 0; l.MLy = 0; l.MLz = 0;
    l.XL = 0; l.YL = 0; l.ZL = 0;
end

function e = zeroErrorPt()
    e.X = 0; e.Y = 0; e.Z = 0;
end

function p = zeroPreload()
    p.Fpx = [0,0,0]; p.Fpy = [0,0,0]; p.Fpz = [0,0,0];
    p.rp = [0,0,0]; p.thp = [0,0,0];
end

function p = lightPreload()
    p.Fpx = [50, 50, 50]; p.Fpy = [0,0,0]; p.Fpz = [0,0,0];
    p.rp = [0.025, 0.025, 0.025]; p.thp = [0, 2*pi/3, 4*pi/3];
end