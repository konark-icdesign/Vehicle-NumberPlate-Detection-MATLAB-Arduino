# Synthetic reference validation

These tests were created while reconstructing the project. They are not measurements from the lost original college code.

Three generated videos use the same scene and vehicle motion but change the body colour: blue, white and dark. This was done specifically to reproduce the remembered failure mode where colour/brightness affected detection.

A small reference implementation of the same classical pipeline was exercised against the generated frames before the repository was prepared. The environment used for reconstruction did not contain a licensed MATLAB runtime, so these numbers are reference checks rather than MATLAB benchmark claims.

| Synthetic case | Vehicle hit rate | Plate hit rate | Naive fixed-brightness vehicle threshold |
|---|---:|---:|---:|
| Blue car | 100% | 86.9% | 100% |
| White car | 100% | 100% | 0% |
| Dark car | 96.0% | 49.5% | 100% |

What the test demonstrates:

- one fixed intensity threshold can completely fail when the vehicle colour changes
- motion/background modelling is much less dependent on body colour
- dark/low-contrast footage can still reduce the quality of the vehicle ROI and therefore hurt plate localization
- classical detection remains sensitive to lighting, contrast, motion and parameter tuning

The actual MATLAB implementation should be rerun locally before presenting any MATLAB-specific accuracy or performance numbers.
