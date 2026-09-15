function generate_synthetic_video(outputPath, carColor)
%GENERATE_SYNTHETIC_VIDEO Create a small fixed-camera test video.
%
% Example:
%   generate_synthetic_video('../sample/test_blue_car.avi', [35 80 170]);
%
% This is only a test source so the project can be run without downloading
% traffic footage. It is not intended to look photorealistic.

    if nargin < 1
        outputPath = "../sample/synthetic_traffic_demo.avi";
    end
    if nargin < 2
        carColor = [45 70 155];
    end

    W = 640;
    H = 360;
    fps = 25;
    numFrames = 150;

    writer = VideoWriter(outputPath, 'Motion JPEG AVI');
    writer.FrameRate = fps;
    open(writer);

    for n = 1:numFrames
        % Background / road.
        frame = uint8(zeros(H,W,3));
        frame(:,:,1) = 105;
        frame(:,:,2) = 105;
        frame(:,:,3) = 105;

        % Road markings.
        frame(285:292, 1:W, :) = 220;
        frame(330:335, 1:W, :) = 65;

        % Moving vehicle.
        carW = 180;
        carH = 85;
        x = round(-carW + (W + 2*carW) * (n-1)/(numFrames-1));
        y = 175;

        x1 = max(1,x);
        x2 = min(W,x+carW-1);
        y1 = y;
        y2 = y+carH-1;

        if x2 > x1
            frame(y1:y2,x1:x2,1) = carColor(1);
            frame(y1:y2,x1:x2,2) = carColor(2);
            frame(y1:y2,x1:x2,3) = carColor(3);

            % Windows.
            wx1 = max(1,x+35); wx2 = min(W,x+145);
            if wx2 > wx1
                frame(y+10:y+35,wx1:wx2,:) = 35;
            end

            % Bright plate with simple dark character strokes.
            px1 = max(1,x+58); px2 = min(W,x+125);
            py1 = y+58; py2 = y+75;
            if px2 > px1
                frame(py1:py2,px1:px2,:) = 235;
                for c = px1+6:10:px2-4
                    frame(py1+3:py2-3,c:min(c+2,px2),:) = 20;
                end
            end
        end

        % Mild brightness variation to imitate changing illumination.
        gain = 0.93 + 0.10*sin(2*pi*n/70);
        frame = uint8(min(double(frame)*gain,255));

        writeVideo(writer, frame);
    end

    close(writer);
    fprintf("Synthetic test video written to %s\n", outputPath);
end
