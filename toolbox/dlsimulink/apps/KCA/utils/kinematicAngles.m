function th = kinematicAngles(r, th1)
% KINEMATICANGLES  Compute coupling-point angles from radii.
%   th = kinematicAngles(r, th1) returns 3-element angle array such that
%   the triangle with vertices (r(i), th(i)) has its incenter at the
%   origin.  θ(1) = th1; θ(2), θ(3) are locked by the incenter-at-origin
%   constraint (bisector rule for kinematic couplings).
%
%   Algorithm: find ρ ∈ (0, min(r)] solving
%     acos(ρ/r1) + acos(ρ/r2) + acos(ρ/r3) = π
%   via bisection; then
%     Δ_i = 2·acos(ρ/r_i)
%     th(1) = th1
%     th(2) = th1 + (Δ1 + Δ2)/2
%     th(3) = th1 + Δ2/2 + π

    arguments
        r   (1,3) {mustBeReal, mustBePositive, mustBeFinite}
        th1 (1,1) {mustBeReal, mustBeFinite} = 0
    end

    % Bisection for ρ (inradius)
    rMin = min(r);
    lo = 0.0;
    hi = rMin;
    fhi = sum(acos(hi ./ r)) - pi;  % always < 0 for distinct radii, = 0 if all equal

    % f(hi) may be exactly 0 when all radii equal (ρ = r/2 is the exact root)
    if abs(fhi) < 1e-15
        rho = hi;
    else
        for iter = 1:80
            mid = 0.5*(lo + hi);
            fmid = sum(acos(mid ./ r)) - pi;
            if fmid > 0
                lo = mid;
            else
                hi = mid;
            end
            if hi - lo < 1e-12 * (0.5*(lo + hi) + 1) % relative tolerance
                break;
            end
        end
        rho = 0.5*(lo + hi);
    end

    % Δ_i
    Delta = 2 * acos(rho ./ r);   % 3-element

    % Output angles
    th = zeros(1, 3);
    th(1) = th1;
    th(2) = th1 + 0.5*(Delta(1) + Delta(2));
    th(3) = th1 + 0.5*Delta(2) + pi;
end