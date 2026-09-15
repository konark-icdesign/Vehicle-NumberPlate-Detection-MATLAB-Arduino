%% Generate several synthetic car-color cases for threshold testing
% Run this once if you want local test clips made entirely in MATLAB.

clear; clc;

generate_synthetic_video('../sample/demo_blue_car.avi',  [40 70 165]);
generate_synthetic_video('../sample/demo_white_car.avi', [205 205 205]);
generate_synthetic_video('../sample/demo_dark_car.avi',  [35 35 42]);

disp('Created blue, white and dark car test videos.');
