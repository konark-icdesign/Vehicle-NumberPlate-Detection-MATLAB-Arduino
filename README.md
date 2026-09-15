# Vehicle and Number Plate Detection using MATLAB + Arduino UNO

A reconstruction of a second-year ECE college project I originally built around prerecorded vehicle footage, MATLAB image processing and an Arduino UNO hardware indicator.

The old source files were not preserved, so this repository rebuilds the same idea from scratch instead of pretending that the exact original code survived.

## What the project does

The laptop loads a prerecorded traffic/parking video and MATLAB processes it frame by frame.

1. Detect moving vehicle-sized regions.
2. Draw a bounding box around each vehicle candidate.
3. Search inside the detected vehicle for a number-plate-like region.
4. Draw a second bounding box around the plate candidate.
5. Optionally try OCR on the localized plate.
6. Optionally send a detection state to an Arduino UNO over USB serial.

```text
prerecorded video
      |
      v
 MATLAB VideoReader
      |
      v
background / foreground separation
      |
      v
vehicle bounding box
      |
      v
plate-region image processing
      |
      +----------> optional OCR
      |
      +----------> Arduino UNO -> LEDs / buzzer
```

The Arduino does **not** process camera data. MATLAB performs the computer vision; the UNO is only a simple electronics output layer.

## Why this version is useful

The original project had a problem I remember clearly: detection was not stable. A vehicle could be detected in some frames and missed in others, and changing the car colour/brightness could change the result.

That is a normal weakness of classical threshold-based vision. A fixed brightness/RGB threshold can work on a dark or blue car and completely fail on a white car, or vice versa. Lighting, shadows, reflections, motion blur and the plate size also change the pixels being tested.

This reconstruction reduces direct colour dependence by using:

- grayscale foreground/background modelling for vehicle motion
- morphology and connected-component geometry instead of one colour rule
- local contrast enhancement before plate detection
- edge and shape scoring for the number-plate candidate

It is still intentionally a simple classical computer-vision project, not a modern deep-learning ANPR system.

## Repository structure

```text
Vehicle-NumberPlate-Detection-MATLAB-Arduino/
|
|-- matlab/
|   |-- main.m
|   |-- project_config.m
|   |-- detect_vehicle.m
|   |-- detect_plate.m
|   |-- recognize_plate_text.m
|   |-- generate_synthetic_video.m
|   |-- run_all_demo_cases.m
|   `-- setup_check.m
|
|-- arduino/
|   `-- detection_indicator/
|       `-- detection_indicator.ino
|
|-- sample/
|   |-- synthetic_traffic_demo.mp4
|   |-- reference_blue_car.mp4
|   |-- reference_white_car.mp4
|   |-- reference_dark_car.mp4
|   `-- README.md
|
|-- results/
|   |-- reference_blue_detection.png
|   |-- reference_white_detection.png
|   |-- reference_dark_detection.png
|   |-- reference_validation.csv
|   |-- reference_validation.md
|   `-- README.md
|
`-- docs/
    |-- architecture.md
    |-- failure_analysis.md
    |-- project_notes.md
    `-- build_walkthrough.md
```

## MATLAB requirements

Recommended:

- MATLAB
- Image Processing Toolbox
- Computer Vision Toolbox

The code uses functions/system objects such as `VideoReader`, `vision.ForegroundDetector`, `regionprops`, `adapthisteq`, `edge`, `insertShape`, and `insertText`.

OCR is optional and is disabled by default.

## Run it

Open MATLAB and make `matlab/` the current folder. You can first run:

```matlab
setup_check
```

Then run:

```matlab
main
```

The default configuration uses the included generated video:

```matlab
cfg.videoPath = "../sample/synthetic_traffic_demo.mp4";
```

After processing, the program writes:

```text
results/annotated_output.avi
results/detection_log.csv
```

To use your own old/college-style footage, copy the video into `sample/` and change `cfg.videoPath` in `matlab/project_config.m`.

## Detection pipeline

### Vehicle detection

The vehicle stage uses a Gaussian-mixture foreground detector. The resulting foreground mask is cleaned using morphological opening, closing and hole filling. `regionprops` then supplies connected-component bounding boxes and areas.

Candidates are filtered by:

- minimum width and height
- object area relative to the frame
- bounding-box aspect ratio
- region solidity

This is most suitable for footage where the camera is fixed or nearly fixed and the vehicle moves through the scene.

### Number-plate detection

For each vehicle box, the code searches mainly in the middle/lower section of the vehicle.

```text
vehicle ROI
   -> grayscale
   -> adaptive histogram equalization
   -> Gaussian smoothing
   -> Canny edges
   -> morphological closing/dilation
   -> connected regions
   -> plate-like geometry score
```

The candidate score considers aspect ratio, extent, solidity and edge density. This is more stable than accepting/rejecting a region using one hard image threshold.

### Optional OCR

Set this in `project_config.m`:

```matlab
cfg.enableOCR = true;
```

The detected plate is enlarged and preprocessed before MATLAB OCR is attempted. OCR is kept optional because **locating the number plate** is the main reconstructed task and readable OCR needs much cleaner plate images.

## Arduino UNO layer

Upload:

```text
arduino/detection_indicator/detection_indicator.ino
```

Default pins:

- pin 8: vehicle LED
- pin 9: plate LED
- pin 10: optional buzzer

MATLAB sends:

```text
V = vehicle detected
P = plate candidate detected
N = nothing detected
```

Then enable it in `project_config.m`:

```matlab
cfg.enableArduino = true;
cfg.serialPort = "COM3";
```

Change the COM port to the one assigned to the UNO.

## The detection problem I faced in the old project

The original code is gone, so I cannot identify the exact old line that failed. The remembered symptoms match several common problems:

- **car colour / road contrast:** a fixed intensity threshold can lose the whole vehicle
- **changing illumination:** sunlight, reflections and camera auto-exposure move pixel values across a threshold
- **moving shadows:** shadows can join the foreground blob and change the bounding box
- **background learning:** a slow or stopped car can gradually be treated as background
- **small plate size:** at distance, only a few plate pixels remain
- **motion blur / angle:** character and rectangular edges disappear
- **hard threshold tuning:** settings that work for one video fail on another

See [`docs/failure_analysis.md`](docs/failure_analysis.md) for the full breakdown and the simple reference colour-threshold experiment.

## Reference validation included in this repo

Because the original college video was not preserved, the repository includes generated reference clips for a blue, white and dark car. They are there to make the project reproducible and to demonstrate the colour problem without pretending they are original experimental footage.

The simple fixed-brightness reference experiment shows the expected failure mode:

- blue car: detected
- dark car: detected
- white car: missed by the dark-pixel threshold

The reconstructed vehicle stage therefore avoids using that colour rule as its primary detector.

See [`results/reference_validation.md`](results/reference_validation.md) and the images in `results/`.

## Status / honesty note

This repository is a **reconstruction**, not the untouched 2nd-year source tree.

The MATLAB code has been written as a complete runnable implementation, but this environment does not contain a MATLAB runtime, so I have not labelled the repository with a fake "tested on MATLAB R20xx" claim. `setup_check.m` is included so the actual MATLAB installation can be checked before running.

The generated reference media and independent validation artifacts are included to document the intended behaviour and the old colour-sensitivity failure mode.

## Possible next improvements

This is intentionally kept close to the scope of an early undergraduate project. Natural extensions would be:

- tracking vehicles between frames
- replacing geometric plate localization with a trained detector
- more reliable OCR
- automatic parking-entry logging
- live webcam input
- servo-controlled gate prototype
- ESP32/Wi-Fi logging if the project were extended into a real IoT system
