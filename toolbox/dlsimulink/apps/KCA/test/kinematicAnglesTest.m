classdef kinematicAnglesTest < matlab.unittest.TestCase
    %KINEMATICANGLESTEST Unit tests for the locked coupling-angle solver.
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
        function equalRadii(testCase)
            th = kinematicAngles([1 1 1], 0);
            testCase.verifyEqual(th, [0, 2*pi/3, 4*pi/3], 'AbsTol', 1e-9);
        end

        function knownAsymmetric(testCase)
            th = kinematicAngles([1 2 3], 0);
            testCase.verifyEqual(rad2deg(th), [0, 105.169006, 246.889811], 'AbsTol', 1e-4);
        end

        function smallRadii(testCase)
            th = kinematicAngles([0.02 0.03 0.04], 0);
            testCase.verifyEqual(rad2deg(th), [0, 109.941542, 242.951261], 'AbsTol', 1e-4);
        end

        function th1OffsetApplied(testCase)
            th = kinematicAngles([1 1 1], pi/4);
            testCase.verifyEqual(th, [pi/4, pi/4 + 2*pi/3, pi/4 + 4*pi/3], 'AbsTol', 1e-9);
        end

        function incenterAtOrigin(testCase)
            r = [0.02 0.03 0.04];
            th = kinematicAngles(r, 0);
            xb = r.*cos(th); yb = r.*sin(th);
            tri = kinematicTriangle(xb, yb);
            testCase.verifyLessThan(norm([tri.xci, tri.yci]), 1e-9);
        end

        function rejectsNonPositiveRadii(testCase)
            testCase.verifyError(@() kinematicAngles([1 0 1], 0), 'MATLAB:validators:mustBePositive');
        end
    end
end