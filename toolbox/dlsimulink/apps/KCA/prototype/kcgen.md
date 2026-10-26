# kcgen.m — Kinematic Coupling Analysis Prototype

## Purpose

Computes contact forces, Hertzian contact stresses, ellipse geometry, ball-centroid deflections, and error motion for a 3-groove kinematic coupling under preload + disturbance loads.

## Inputs (hardcoded constants — change to UI fields)

| Section | Key variables | Type |
|---|---|---|
| Configuration | `symmetric` (1/0) | toggle |
| Material selection | `Matgrv` (groove index), `Matbal` (ball index) | dropdown from 5 materials |
| Material tables | `Matball(5×3)`, `Matgroove(5×3)` — `[Hertz_limit, E, Poisson]` | reference data |
| Disturbance loads | `FLx..FLz`, `MLx..MLz`, `XL..ZL`, `Xerr..Zerr` | numeric inputs (N, N-m, m) |
| Coupling geometry | `r`, `th`, `thg`, `Dball`, `Rbminor`, `Rbmajor`, `Rgrv` (3-vectors) | per-coupling numeric inputs |
| Preload | `Fpx`, `Fpy`, `Fpz`, `rp_pre`, `thp_pre` (3-vectors) | per-coupling numeric inputs |

## Execution Flow

1. **Symmetric override** — if `symmetric==1`, copies coupling-1 geometry/preload to couplings 2&3 with 120° angular offsets.
2. **Contact geometry** — computes 6 contact-point coordinates (`Xb,Yb,Zb`) and direction cosines (`Ab,Bb,Gb`).
3. **Preload points** — `xp_pre, yp_pre, zp_pre` for moment-arm calculations.
4. **Ellipse parameters** — per-coupling `Re, alpha, beta, lambda, theta_c` from Hertz theory (geometry-dependent).
5. **Force equilibrium** — builds 6×6 `A` matrix, solves `A\Bwithloads` and `A\Bnoloads`.
6. **Hertzian deflections** — per-contact `del`, `rmaj`, `rmin`, `sig`.
7. **Ball centres** — original and loaded positions `xbO,ybO,zbO`, `xbN,ybN,zbN` (per-ball 3-vectors).
8. **Error motion** — inter-ball distances, centroid, homogeneous transform → `DeltaX/Y/Z/RMS`.

## Key Arrays

| Array | Size | Meaning |
|---|---|---|
| `Xb,Yb,Zb` | 1×6 | Contact-point coordinates (a,b,c,d,e,f) |
| `Ab,Bb,Gb` | 1×6 | Direction cosines for each contact |
| `Re` | 1×3 | Equivalent radius of curvature per coupling |
| `alpha,beta,lambda` | 1×3 | Hertz ellipse shape parameters per coupling |
| `Fbn, Fb` | 6×1 | Contact forces — with loads, preload-only |
| `del` | 1×6 | Ball deflection at each contact |
| `rmaj, rmin` | 1×6 | Contact ellipse semi-axes |
| `sig` | 1×6 | Contact pressure (Hertz) |
| `xbO,ybO,zbO` / `xbN,ybN,zbN` | 1×3 | Ball centre positions |

## Outputs

6 contact stresses (Pa), 6 stress ratios `(0.3*sig)/(0.5*S)`, 3 Hertz validity ratios, position error at POI (m & µm).

## Notes for Interactive Port

- All inputs are currently hardcoded in `%% Coupling Geometry Data` / `%% Disturbance Loads`. Each section maps to a logical UI panel.
- The solver section (`%% Interface Force-Deflection Calculations`) is the computational core — no UI changes needed.
- The error motion chain (`%% Error Motion Analysis`) is downstream of the solver and produces the final position/orientation metrics.
- Disturbance loads (`FLx..MLz`) are all zero in the prototype; `Fpz` has a non-zero preload.
- Material tables support 5 materials; the current selection is `Matgrv=3` (RC62 Steel), `Matbal=1` (Carbide).