function [plateBox, plateImage, bestScore, debug] = detect_plate(frame, vehicleBox, cfg)
%DETECT_PLATE Locate a number-plate-like rectangle inside a vehicle ROI.
%
% This does not rely on car body color. It searches the lower portion of a
% vehicle using local contrast, edges, morphology, and rectangle geometry.

    plateBox = [];
    plateImage = [];
    bestScore = 0;
    debug = struct('candidateCount',0,'searchROI',[],'binaryMask',[]);

    % Clip the vehicle bounding box to image limits.
    x1 = max(1, floor(vehicleBox(1)));
    y1 = max(1, floor(vehicleBox(2)));
    x2 = min(size(frame,2), ceil(vehicleBox(1) + vehicleBox(3) - 1));
    y2 = min(size(frame,1), ceil(vehicleBox(2) + vehicleBox(4) - 1));

    if x2 <= x1 || y2 <= y1
        return;
    end

    vehicleROI = frame(y1:y2, x1:x2, :);

    % Most visible plates appear around the central/lower portion of a car.
    roiH = size(vehicleROI,1);
    searchTop = max(1, round(cfg.plateSearchTopFraction * roiH));
    searchROI = vehicleROI(searchTop:end, :, :);
    debug.searchROI = searchROI;

    gray = im2gray(searchROI);

    % Adaptive contrast helps when car/road illumination changes.
    gray = adapthisteq(gray, 'ClipLimit', 0.02);
    gray = imgaussfilt(gray, 0.7);

    edges = edge(gray, 'Canny');

    % Join nearby character strokes and rectangular plate borders.
    candidateMask = imclose(edges, strel('rectangle', [3 13]));
    candidateMask = imdilate(candidateMask, strel('rectangle', [2 5]));
    candidateMask = imfill(candidateMask, 'holes');
    candidateMask = bwareaopen(candidateMask, 60);
    debug.binaryMask = candidateMask;

    stats = regionprops(candidateMask, gray, ...
        'BoundingBox', 'Area', 'Extent', 'Solidity', 'MeanIntensity');
    debug.candidateCount = numel(stats);

    searchArea = size(gray,1) * size(gray,2);

    for i = 1:numel(stats)
        bb = stats(i).BoundingBox;
        w = bb(3);
        h = bb(4);

        if w < cfg.minPlateWidth || h < cfg.minPlateHeight
            continue;
        end

        aspect = w / max(h,1);
        areaFraction = stats(i).Area / searchArea;

        if aspect < cfg.minPlateAspect || aspect > cfg.maxPlateAspect
            continue;
        end
        if areaFraction < cfg.minPlateAreaFraction || ...
                areaFraction > cfg.maxPlateAreaFraction
            continue;
        end

        % Measure how much edge structure exists inside the candidate.
        cx1 = max(1, floor(bb(1)));
        cy1 = max(1, floor(bb(2)));
        cx2 = min(size(edges,2), ceil(bb(1) + bb(3) - 1));
        cy2 = min(size(edges,1), ceil(bb(2) + bb(4) - 1));

        if cx2 <= cx1 || cy2 <= cy1
            continue;
        end

        candidateEdges = edges(cy1:cy2, cx1:cx2);
        edgeDensity = nnz(candidateEdges) / numel(candidateEdges);

        % A soft score is easier to tune than one hard threshold.
        aspectScore = max(0, 1 - abs(aspect - 4.0) / 4.0);
        extentScore = min(stats(i).Extent / 0.80, 1);
        solidityScore = min(stats(i).Solidity / 0.90, 1);
        edgeScore = min(edgeDensity / 0.22, 1);

        score = 0.35 * aspectScore + ...
                0.20 * extentScore + ...
                0.15 * solidityScore + ...
                0.30 * edgeScore;

        if score > bestScore && score >= cfg.minPlateScore
            bestScore = score;

            % Convert the ROI coordinates back to full-frame coordinates.
            globalX = x1 + bb(1) - 1;
            globalY = y1 + searchTop + bb(2) - 2;
            plateBox = [globalX, globalY, bb(3), bb(4)];

            px1 = max(1, floor(globalX));
            py1 = max(1, floor(globalY));
            px2 = min(size(frame,2), ceil(globalX + bb(3) - 1));
            py2 = min(size(frame,1), ceil(globalY + bb(4) - 1));
            plateImage = frame(py1:py2, px1:px2, :);
        end
    end
end
