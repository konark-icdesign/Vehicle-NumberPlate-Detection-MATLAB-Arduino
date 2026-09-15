# Sample video

Large demo videos are not stored in the Git repository. `matlab/main.m` automatically calls `generate_synthetic_video.m` when the default sample file is missing.

The default generated file is:

```text
synthetic_traffic_demo.avi
```

You can also run `matlab/run_all_demo_cases.m` to create blue, white and dark-car clips locally.

For a real test, put a prerecorded traffic or parking video in this folder and edit `cfg.videoPath` in `matlab/project_config.m`.

Best conditions for this classical method:

- camera mostly stationary
- vehicle moves through the frame
- vehicle occupies a useful portion of the image
- plate is visible and not heavily blurred
