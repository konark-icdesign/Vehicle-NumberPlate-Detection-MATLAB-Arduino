# Project reconstruction notes

This repository rebuilds an early second-year ECE project whose original source files were not preserved.

What is remembered about the original project:

- a prerecorded vehicle video was opened on the laptop
- MATLAB processed the video frame by frame
- cars/vehicles were detected
- the number-plate region was also detected
- detection was inconsistent in some footage
- car colour / lighting affected the result
- Arduino UNO was part of the project hardware

The reconstructed code keeps the project at that same technical level. It deliberately avoids claiming deep learning, high ANPR accuracy or hardware video processing that was not part of the original work.

## Main techniques used here

### Vehicle stage

`VideoReader` -> grayscale -> `vision.ForegroundDetector` -> morphology -> `regionprops` -> vehicle-sized blobs.

### Plate stage

Vehicle ROI -> grayscale -> adaptive histogram equalization -> Canny edges -> morphology -> rectangular connected components -> weighted candidate score.

### Optional OCR

OCR is not required to call a plate region detected. If enabled, the localized plate is enlarged, contrast-normalized and passed to MATLAB `ocr` using an alphanumeric character set.

### Arduino UNO

MATLAB sends a single serial character after each state change. Arduino drives LEDs and an optional buzzer. It is an indication/output layer, not the image-processing device.
