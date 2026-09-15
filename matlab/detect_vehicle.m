function [vehicleBoxes, cleanMask] = detect_vehicle(frame, foregroundDetector, cfg)
%DETECT_VEHICLE Detect moving vehicle-sized foreground objects.
%
% Intended for prerecorded video from a mostly stationary camera.
% The algorithm is deliberately classical and undergraduate-level:
%   1) grayscale conversion
%   2) Gaussian-mixture background subtraction
%   3) morphology to clean the foreground mask
%   4) connected-component filtering by size and shape

    gray = im2gray(frame);
    foregroundMask = foregroundDetector(gray, cfg.foregroundLearningRate);

    % Remove isolated pixels, connect fragmented vehicle regions, fill holes.
    cleanMask = imopen(foregroundMask, strel('rectangle', [3 3]));
    cleanMask = imclose(cleanMask, strel('rectangle', [7 15]));
    cleanMask = imfill(cleanMask, 'holes');
    cleanMask = bwareaopen(cleanMask, 250);

    stats = regionprops(cleanMask, 'Area', 'BoundingBox', 'Solidity');
    frameArea = size(frame,1) * size(frame,2);

    vehicleBoxes = zeros(0,4);

    for i = 1:numel(stats)
        bb = stats(i).BoundingBox;
        w = bb(3);
        h = bb(4);
        aspect = w / max(h, 1);
        areaFraction = stats(i).Area / frameArea;

        looksLikeVehicle = ...
            w >= cfg.minVehicleWidth && ...
            h >= cfg.minVehicleHeight && ...
            aspect >= cfg.minVehicleAspect && ...
            aspect <= cfg.maxVehicleAspect && ...
            areaFraction >= cfg.minVehicleAreaFraction && ...
            areaFraction <= cfg.maxVehicleAreaFraction && ...
            stats(i).Solidity >= 0.35;

        if looksLikeVehicle
            vehicleBoxes(end+1,:) = bb; %#ok<AGROW>
        end
    end
end
