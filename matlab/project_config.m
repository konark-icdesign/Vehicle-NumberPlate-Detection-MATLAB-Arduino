function cfg = project_config()
%PROJECT_CONFIG Central settings for the reconstructed vehicle/plate project.

cfg.videoPath = "../sample/synthetic_traffic_demo.avi";
cfg.outputVideoPath = "../results/annotated_output.avi";
cfg.outputLogPath = "../results/detection_log.csv";

% Vehicle detection: fixed-camera background subtraction.
cfg.numTrainingFrames = 20;
cfg.minimumBackgroundRatio = 0.70;
cfg.numGaussians = 3;
cfg.foregroundLearningRate = 0.005; % low value: avoids absorbing a moving car too quickly
cfg.minVehicleAreaFraction = 0.004;
cfg.maxVehicleAreaFraction = 0.50;
cfg.minVehicleWidth = 55;
cfg.minVehicleHeight = 30;
cfg.minVehicleAspect = 0.9;
cfg.maxVehicleAspect = 5.5;

% Number-plate candidate detection.
cfg.plateSearchTopFraction = 0.30;
cfg.minPlateAspect = 2.0;
cfg.maxPlateAspect = 7.5;
cfg.minPlateAreaFraction = 0.002;
cfg.maxPlateAreaFraction = 0.15;
cfg.minPlateWidth = 24;
cfg.minPlateHeight = 7;
cfg.minPlateScore = 0.36;

% Optional OCR. Plate localization is the primary task.
cfg.enableOCR = false;

% Optional Arduino indicator layer.
cfg.enableArduino = false;
cfg.serialPort = "COM3";
cfg.baudRate = 9600;

% Set true to display the foreground mask beside the annotated frame.
cfg.showDebugMask = false;
end
