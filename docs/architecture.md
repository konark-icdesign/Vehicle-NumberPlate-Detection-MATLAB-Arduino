# Architecture

```text
prerecorded vehicle video
          |
          v
     MATLAB VideoReader
          |
          v
GMM foreground segmentation
          |
          v
 morphology + regionprops
          |
          v
  vehicle bounding box
          |
          v
lower vehicle ROI -> grayscale -> adaptive contrast -> Canny edges
          |
          v
morphology + geometric scoring
          |
          v
 number-plate candidate
          |
     +----+----------------+
     |                     |
     v                     v
optional OCR          serial byte
                           |
                           v
                       Arduino UNO
                           |
                    LED / buzzer demo
```

The Arduino does not process the video. The laptop performs computer vision in MATLAB and the UNO is only an output/indicator layer.
