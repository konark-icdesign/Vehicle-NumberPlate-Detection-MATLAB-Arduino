# Why the old project sometimes detected the car and sometimes did not

The exact original code is no longer available, so the old bug cannot be identified line-by-line. The symptoms I remember are consistent with the normal limitations of classical threshold-based computer vision.

## 1. Car colour / brightness changed the segmentation

A detector based on RGB thresholds, grayscale intensity, or simple frame differencing can work on one car and fail on another. A dark car on dark asphalt has weak contrast. A white or reflective car can merge with a bright background. The threshold that works for one video can therefore miss another vehicle.

This reconstruction reduces that dependence by using a foreground/background model for vehicle motion and by converting the plate search region to grayscale instead of testing for a specific car colour.

## 2. Lighting was changing between frames

Sunlight, indoor lighting, shadows, reflections and auto-exposure all change pixel intensity. A fixed threshold such as `gray > T` or `gray < T` can cross from "detected" to "not detected" even though the same car is present.

The plate stage now uses `adapthisteq` so the contrast adjustment is local rather than using one global brightness assumption.

## 3. Shadows became part of the vehicle blob

Background subtraction can treat a moving shadow as foreground. The bounding box then becomes too large or its shape changes, which can make later geometry filters reject it.

Morphological opening/closing and broad geometry limits reduce this, but they do not eliminate it.

## 4. The background model can absorb a slow/stationary vehicle

A foreground detector learns what is "background". If a vehicle is already present during the training frames, or stays still for a long time, the model can begin treating it as background. That produces the classic behaviour where detection is present for some frames and then disappears.

## 5. Plate was too small, blurred or tilted

The plate detector looks for a wide rectangular area with dense edges. At a distance, the plate may only be a few pixels tall. Motion blur, viewing angle, glare, or low resolution can remove the character edges and the candidate fails the score.

## 6. One hard threshold caused unstable results

Older student implementations often have several constants for blob area, aspect ratio, edge count and brightness. A candidate just above a threshold passes; one pixel or lighting change later it falls below the threshold.

The reconstruction still uses thresholds because it is intentionally a classical project, but candidate selection uses a weighted score and the important values are collected in `project_config.m` for tuning.

## What this project does not claim

It is not a production automatic-number-plate-recognition system. It works best with a mostly fixed camera, visible moving vehicles and readable plates. A trained detector would be the modern way to make it much more robust across vehicle colours, viewpoints and environments.
