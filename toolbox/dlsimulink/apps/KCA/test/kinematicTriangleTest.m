classdef kinematicTriangleTest < matlab.unittest.TestCase
    %KINEMATICTRIANGLETEST Unit tests for triangle geometry utility.
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
        function symmetricCase(testCase)
            r = 1;
            th = [0, 2*pi/3, 4*pi/3];
            xb = r*cos(th);
            yb = r*sin(th);
            tri = kinematicTriangle(xb, yb);
            testCase.verifyEqual([tri.xci, tri.yci], [0, 0], 'AbsTol', 1e-10);
            testCase.verifyEqual(tri.sides(1), tri.sides(2), 'AbsTol', 1e-10);
            testCase.verifyEqual(tri.sides(2), tri.sides(3), 'AbsTol', 1e-10);
        end

        function nonEquilateralTriangle(testCase)
            xb = [-1.0, 2.0, -1.0];
            yb = [0.0, 0.0, 3.0];
            tri = kinematicTriangle(xb, yb);
            % Incenter of this triangle must be inside it
            testCase.verifyGreaterThan(tri.xci, -1);
            testCase.verifyLessThan(tri.xci, 2);
            testCase.verifyGreaterThan(tri.yci, 0);
            testCase.verifyLessThan(tri.yci, 3);
            % Side opposite P1 = L23 (vertex (-1,0) to (2,0) ... actually P2=(2,0), P3=(-1,3))
            % No wait, the vertices are: P1=(-1,0), P2=(2,0), P3=(-1,3)
            % L12 = 3, L23 = sqrt(9+9) = sqrt(18), L31 = 3
            testCase.verifyEqual(tri.sides(1), sqrt(18), 'AbsTol', 1e-10);
            testCase.verifyEqual(tri.sides(2), 3, 'AbsTol', 1e-10);
            testCase.verifyEqual(tri.sides(3), 3, 'AbsTol', 1e-10);
        end

        function incenterAtOriginInvariant(testCase)
            r = [0.02, 0.03, 0.04];
            th = kinematicAngles(r, 0);
            xb = r.*cos(th);
            yb = r.*sin(th);
            tri = kinematicTriangle(xb, yb);
            testCase.verifyLessThan(norm([tri.xci, tri.yci]), 1e-9);
        end

        function bisectorPerpendiculars(testCase)
            th = [0, 2*pi/3, 4*pi/3];
            xb = cos(th);
            yb = sin(th);
            tri = kinematicTriangle(xb, yb);
            for j = 1:3
                b = [tri.bisectorX(j), tri.bisectorY(j)];
                n = [tri.normalX(j), tri.normalY(j)];
                testCase.verifyEqual(norm(n), 1, 'AbsTol', 1e-10);
                testCase.verifyLessThan(abs(dot(b, n)), 1e-10);
            end
        end

        function rightTriangle(testCase)
            xb = [0, 3, 0];
            yb = [0, 0, 4];
            tri = kinematicTriangle(xb, yb);
            testCase.verifyEqual([tri.xci, tri.yci], [1, 1], 'AbsTol', 1e-10);
            testCase.verifyEqual(tri.sides, [5, 4, 3], 'AbsTol', 1e-10);
        end
    end
end