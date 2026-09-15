function [plateText, confidence] = recognize_plate_text(plateImage)
%RECOGNIZE_PLATE_TEXT Optional OCR stage for a localized number plate.
%
% Returns empty text if OCR is unavailable or confidence is weak.

    plateText = "";
    confidence = 0;

    if isempty(plateImage) || exist('ocr', 'file') ~= 2
        return;
    end

    try
        gray = im2gray(plateImage);
        gray = imresize(gray, 3.0, 'bicubic');
        gray = adapthisteq(gray);

        % Convert to a high-contrast dark-text/light-background image.
        bw = imbinarize(gray, 'adaptive', 'ForegroundPolarity', 'dark');
        bw = bwareaopen(bw, 15);
        ocrInput = uint8(~bw) * 255;

        result = ocr(ocrInput, ...
            'LayoutAnalysis', 'line', ...
            'CharacterSet', 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789');

        cleaned = upper(regexprep(strtrim(result.Text), '[^A-Z0-9]', ''));
        if isempty(cleaned)
            return;
        end

        wordConf = result.WordConfidences;
        if ~isempty(wordConf)
            confidence = mean(double(wordConf));
        end

        % Keep OCR conservative. Detection itself does not depend on OCR.
        if strlength(cleaned) >= 4 && confidence >= 0.25
            plateText = string(cleaned);
        end
    catch
        plateText = "";
        confidence = 0;
    end
end
