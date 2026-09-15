%% Check whether the MATLAB installation has the required pieces
clear; clc;

requiredFunctions = [ ...
    "VideoReader"; ...
    "vision.ForegroundDetector"; ...
    "regionprops"; ...
    "adapthisteq"; ...
    "edge"; ...
    "insertShape"; ...
    "insertText" ...
];

fprintf('Vehicle + plate project setup check\n');
fprintf('-----------------------------------\n');

allGood = true;
for i = 1:numel(requiredFunctions)
    name = requiredFunctions(i);
    available = exist(char(name), 'file') ~= 0 || exist(char(name), 'class') ~= 0;
    fprintf('%-28s : %s\n', name, string(available));
    allGood = allGood && available;
end

fprintf('\nOptional OCR available          : %s\n', string(exist('ocr','file') ~= 0));

if allGood
    fprintf('\nCore functions found. Run main.m next.\n');
else
    fprintf('\nOne or more core functions are missing. Check Image Processing Toolbox and Computer Vision Toolbox.\n');
end
