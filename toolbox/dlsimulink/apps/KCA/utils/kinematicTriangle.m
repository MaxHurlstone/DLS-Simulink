function tri = kinematicTriangle(xb, yb)
%KINEMATICTRIANGLE Compute incenter and groove angles for three ball positions.
%   In a kinematic coupling, the groove at each ball position bisects the
%   internal angle of the coupling triangle at that vertex.  The coupling
%   centroid is therefore the incenter (angle bisector intersection), not
%   the centroid (arithmetic mean of vertices).
%
%   Inputs:
%   xb - ball center X coordinates, 1x3 (m)
%   yb - ball center Y coordinates, 1x3 (m)
%
%   Outputs:
%   tri.xci,yci  - incenter coordinates (m)
%   tri.sides    - 3-element side lengths opposite vertex j (m)
%   tri.bisectorX, tri.bisectorY - inward-pointing angle bisectors (3)
%   tri.normalX, tri.normalY     - CCW perpendicular to each bisector (3)
%
%   See also KINEMATICANGLES, KINEMATICCOUPLING
%
%   DLSimulink Toolbox

    arguments (Input)
        xb (1,3) {mustBeReal, mustBeFinite}
        yb (1,3) {mustBeReal, mustBeFinite}
    end
    arguments (Output)
        tri (1,1) struct
    end

% Side vectors between adjacent ball positions
vx12 = xb(2) - xb(1);  vy12 = yb(2) - yb(1);
vx23 = xb(3) - xb(2);  vy23 = yb(3) - yb(2);
vx31 = xb(1) - xb(3);  vy31 = yb(1) - yb(3);

% Side lengths
L12 = sqrt(vx12^2 + vy12^2);
L23 = sqrt(vx23^2 + vy23^2);
L31 = sqrt(vx31^2 + vy31^2);

% Side lengths keyed to opposite vertex:
%   sides(1) = L23 (opposite P1),  sides(2) = L31 (opposite P2),  sides(3) = L12 (opposite P3)
sides = [L23, L31, L12];
sumL = sum(sides);

% Incenter = weighted average of vertices by opposite side lengths
xci = (sides(1)*xb(1) + sides(2)*xb(2) + sides(3)*xb(3)) / sumL;
yci = (sides(1)*yb(1) + sides(2)*yb(2) + sides(3)*yb(3)) / sumL;

% Unit vectors along the two edges that meet at each vertex
% Vertex 1: edges 1->2 and 1->3
u12 = [vx12/L12, vy12/L12];
u13 = [-vx31/L31, -vy31/L31];
% Vertex 2: edges 2->3 and 2->1
u23 = [vx23/L23, vy23/L23];
u21 = [-vx12/L12, -vy12/L12];
% Vertex 3: edges 3->1 and 3->2
u31 = [vx31/L31, vy31/L31];
u32 = [-vx23/L23, -vy23/L23];

% Angle bisectors = normalized sum of the two edge unit vectors
b1 = u12 + u13;  b1 = b1 / norm(b1);
b2 = u23 + u21;  b2 = b2 / norm(b2);
b3 = u31 + u32;  b3 = b3 / norm(b3);

% Perpendicular to each bisector (CCW 90-degree rotation)
n1 = [-b1(2), b1(1)];
n2 = [-b2(2), b2(1)];
n3 = [-b3(2), b3(1)];

% Package output
tri.xci = xci;
tri.yci = yci;
tri.sides = sides;
tri.bisectorX = [b1(1), b2(1), b3(1)];
tri.bisectorY = [b1(2), b2(2), b3(2)];
tri.normalX = [n1(1), n2(1), n3(1)];
tri.normalY = [n1(2), n2(2), n3(2)];
end