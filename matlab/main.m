%% Vehicle and number-plate detection from prerecorded video
% Reconstructed undergraduate ECE project.
%
% MATLAB performs video/image processing. Arduino UNO is optional and is
% used only as a hardware indication layer after MATLAB detects something.

clear;
clc;
close all;

cfg = project_config();

if ~isfile(cfg.videoPath)
    fprintf("Input video not found. Generating a synthetic demo: %s\n", cfg.videoPath);
    generate_synthetic_video(cfg.videoPath, [45 70 155]);
end

reader = VideoReader(cfg.videoPath);

% GMM background model: suitable for a fixed or mostly fixed camera.
foregroundDetector = vision.ForegroundDetector( ...
    'NumGaussians', cfg.numGaussians, ...
    'NumTrainingFrames', cfg.numTrainingFrames, ...
    'MinimumBackgroundRatio', cfg.minimumBackgroundRatio);

% Optional serial connection to Arduino UNO.
arduinoSerial = [];
if cfg.enableArduino
    try
        arduinoSerial = serialport(cfg.serialPort, cfg.baudRate);
        pause(2);
        flush(arduinoSerial);
        fprintf("Arduino connected on %s\n", cfg.serialPort);
    catch ME
        warning("Arduino connection failed: %s", ME.message);
        cfg.enableArduino = false;
    end
end

% Output video. Motion JPEG AVI is broadly supported by MATLAB VideoWriter.
writer = VideoWriter(cfg.outputVideoPath, 'Motion JPEG AVI');
writer.FrameRate = reader.FrameRate;
open(writer);

% Detection log.
frameLog = table('Size',[0 6], ...
    'VariableTypes', {'double','double','double','logical','double','string'}, ...
    'VariableNames', {'Frame','Time_s','VehicleCount','PlateDetected','PlateScore','OCRText'});
frameNumber = 0;
lastCommand = 'N';

fig = figure('Name','Vehicle + Number Plate Detection','NumberTitle','off');

while hasFrame(reader)
    frame = readFrame(reader);
    frameNumber = frameNumber + 1;

    [vehicleBoxes, foregroundMask] = detect_vehicle(frame, foregroundDetector, cfg);

    outputFrame = frame;
    plateFoundThisFrame = false;
    bestFramePlateScore = 0;
    bestText = "";

    for k = 1:size(vehicleBoxes,1)
        vehicleBox = vehicleBoxes(k,:);

        outputFrame = insertShape(outputFrame, 'Rectangle', vehicleBox, ...
            'LineWidth', 3, 'Color', 'green');
        outputFrame = insertText(outputFrame, vehicleBox(1:2), 'Vehicle', ...
            'BoxOpacity', 0.55, 'FontSize', 15);

        [plateBox, plateImage, plateScore] = detect_plate(frame, vehicleBox, cfg);

        if ~isempty(plateBox)
            plateFoundThisFrame = true;
            bestFramePlateScore = max(bestFramePlateScore, plateScore);

            label = sprintf('Plate candidate %.2f', plateScore);

            if cfg.enableOCR
                [plateText, ocrConfidence] = recognize_plate_text(plateImage);
                if strlength(plateText) > 0
                    bestText = plateText;
                    label = sprintf('%s  OCR %.2f', plateText, ocrConfidence);
                end
            end

            outputFrame = insertShape(outputFrame, 'Rectangle', plateBox, ...
                'LineWidth', 3, 'Color', 'yellow');
            outputFrame = insertText(outputFrame, plateBox(1:2), label, ...
                'BoxOpacity', 0.55, 'FontSize', 13);
        end
    end

    % Arduino indicator command.
    if plateFoundThisFrame
        command = 'P';
    elseif ~isempty(vehicleBoxes)
        command = 'V';
    else
        command = 'N';
    end

    if cfg.enableArduino && command ~= lastCommand
        write(arduinoSerial, uint8(command), 'uint8');
        lastCommand = command;
    end

    % Log every processed frame.
    frameLog(end+1,:) = {frameNumber, reader.CurrentTime, ...
        size(vehicleBoxes,1), plateFoundThisFrame, bestFramePlateScore, bestText}; %#ok<SAGROW>

    if isvalid(fig)
        if cfg.showDebugMask
            subplot(1,2,1);
            imshow(outputFrame);
            title(sprintf('Frame %d | vehicles %d | plate %d', ...
                frameNumber, size(vehicleBoxes,1), plateFoundThisFrame));
            subplot(1,2,2);
            imshow(foregroundMask);
            title('Foreground mask');
        else
            imshow(outputFrame);
            title(sprintf('Frame %d | vehicles %d | plate %d', ...
                frameNumber, size(vehicleBoxes,1), plateFoundThisFrame));
        end
        drawnow limitrate;
    end

    writeVideo(writer, outputFrame);
end

close(writer);
writetable(frameLog, cfg.outputLogPath);

if cfg.enableArduino
    write(arduinoSerial, uint8('N'), 'uint8');
    clear arduinoSerial;
end

fprintf("Finished. Annotated video: %s\n", cfg.outputVideoPath);
fprintf("Detection log: %s\n", cfg.outputLogPath);
