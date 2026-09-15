# Build walkthrough: start to finish

## 1. Input

A prerecorded vehicle/traffic video is placed in `sample/`. If the default demo is missing, `main.m` generates a synthetic clip locally.

## 2. Read the video

`VideoReader` reads one frame at a time. Processing frames individually keeps the workflow easy to understand and debug.

## 3. Convert each frame to grayscale

The vehicle stage does not require a particular red/blue/white car colour. Grayscale reduces the image to intensity before foreground modelling.

## 4. Learn the background and find moving foreground

`vision.ForegroundDetector` maintains a Gaussian-mixture background model. Pixels that no longer fit the learned background are marked as foreground.

A deliberately low learning rate is used so a moving vehicle is not absorbed into the background too quickly.

## 5. Clean the binary foreground mask

Small speckles and holes are not useful. Morphological opening removes isolated noise, closing joins nearby vehicle fragments, and hole filling produces more useful blobs.

## 6. Extract vehicle candidates

`regionprops` measures each foreground component. Very small blobs, extreme shapes and implausible areas are rejected. Surviving bounding boxes are vehicle candidates.

## 7. Crop the vehicle and search for the plate

The plate is expected mainly in the middle/lower part of the vehicle. That search region is converted to grayscale, locally contrast-enhanced and smoothed.

## 8. Detect plate edges

Canny edge detection finds strong intensity transitions. Characters and the plate border create many edges. Morphology joins nearby strokes into larger rectangular candidates.

## 9. Score number-plate candidates

Each connected candidate is scored using:

- width/height aspect ratio
- extent (how much of its box is occupied)
- solidity
- edge density

The best candidate above the configured score is treated as the plate region.

## 10. Optional OCR

If OCR is enabled, the plate crop is enlarged and binarized. MATLAB `ocr` is constrained to uppercase English letters and digits. OCR is secondary; plate localization remains the main project task.

## 11. Annotate and save the result

Vehicle boxes are drawn in green and plate candidates in yellow. Every processed frame is written to `results/annotated_output.avi`. A CSV log stores per-frame detection state.

## 12. Optional Arduino UNO indication

When the detection state changes, MATLAB sends one byte over USB serial:

- `V`: vehicle
- `P`: number plate
- `N`: none

The Arduino sketch turns LEDs/buzzer on or off. This preserves the electronics component without pretending the UNO itself processes video.
