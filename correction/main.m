%% main
% This script, given some parameters, creates a correction filter useful to
% compensate errors made during a tape digitization process, by applying a
% different equalization standard.
% It is possible to optionally enable graphs plots or audio file savings.
% 
% The filter impulse response will be saved in the following folder:
%   audio/impulse_response
% 
% It then optionally accepts an input file to correct with the desired
% filter.
% 
% The corrected output file will be saved in the following folder:
%   audio/corrected

close all;
clear variables;

% If launched in Octave, load its packages.
if exist('OCTAVE_VERSION', 'builtin')
    pkg load control;
    pkg load signal;
end

%% Parameters

% Equalization standard used to record the tape.
% Accepted values: ("NAB", "CCIR")
standardW = "CCIR";

% Recording tape speed [ips].
% Accepted values: (3.75, 7.5, 15, 30)
speedW = 7.5;

% Equalization standard used to read the tape.
% Accepted values: ("NAB", "CCIR")
standardR = "NAB";

% Reading tape speed [ips].
% Accepted values: (3.75, 7.5, 15, 30)
speedR = 7.5;

% Sampling frequency to be used for filters and impulse response [Hz].
% Accepted values: (44100, 48000, 96000)
% NOTE: Overwritten with input file one, if any.
fs = 96000;

% Bits per sample to be used when saving the filter impulse response audio file.
% Accepted values: (8, 16, 24, 32)
% NOTE_1: Low values (8, 16) may introduce obscillations when exporting the 
% filter impulse response in .wav format.
% NOTE_2: Overwritten with input file one, if any.
b = 24;

%% Input file - OPTIONAL

% Path to input file directory
path = "";

% Input file name (without file extension, that must be .wav).
% To launch the program without correcting a file, just comment the 
% following line:
% input = "W7C_R15C_";

%% Settings

% Enable graphs plot function after the filter creation.
% 0: disabled - 1: enabled
graphs = 1;

% Enable audio files saving.
% 0: disabled - 1: enabled
% NOTE: It will be automatically enabled if an input file is used.
save = 0;

% Enable "resample" function usage. This setting is considered only when an
% input file is given.
%
% This function can be called whenever the recording and reading speeds are
% different: it resamples the input file while keeping the same sampling
% frequency. Depending on the case, it discards samples or it uses a filter
% to interpolate samples. Consequently, its usage could alter results when
% comparing the output file with Web Audio APIs. However, it can be useful
% when the sampling frequency of the output file would be too high.
%
% 0: change output file sampling frequency - 1: use "resample" function,
% i.e. use the input sampling frequency for the output file.
useResample = 0;

%% Input file loading

if exist('input', 'var')
    % Display information in Command Window.
    disp(strcat("Input file given: ", input, ".wav"));
    % Input file full name.
    in_str = strcat(path, input, ".wav");
    % Read input file.
    disp("Reading input file...");
    y = audioread(in_str);
    % Obtain input file additional info.
    info = audioinfo(in_str);
    % Set the sampling frequency as the input file one.
    fs = info.SampleRate;
    % Set the bitrate as the input file one.
    b = info.BitsPerSample;
    % Enable file saving.
    save = 1;
else
    disp("No input file given.");
end
disp(" ");

%% Display parameters in Command Window

disp(strcat("Recording standard: ", standardW));
disp(strcat("Recording standard speed: ", num2str(speedW), " ips"));
disp(strcat("Reading standard: ", standardR));
disp(strcat("Reading standard speed: ", num2str(speedR), " ips"));
disp(strcat("Sampling frequency: ", num2str(fs), " Hz"));
disp(strcat("Bits per sample: ", num2str(b)));
if graphs == 1
    disp("Plots: ON");
    % Add to path the Plot_functions folder.
    addpath(genpath("plot_functions"));
else
    disp("Plots: OFF");
end
if save == 1
    disp("Audio file saving: ON");
else
    disp("Audio file saving: OFF");
end
if exist('input', 'var')
    if useResample == 1
        disp("Using 'resample' function.");
    else
        disp("Changing output file sampling frequency.");
    end
end
disp(" ");

%% Main function

% If an input file is given...
if exist('input', 'var') && exist('y', 'var')
    % ..., create filter and correct the audio file...
    correction(fs, b, standardW, speedW, standardR, speedR, graphs, save, useResample, y, input);
% ..., otherwise...
else
    % ... just create the filter.
    correction(fs, b, standardW, speedW, standardR, speedR, graphs, save, useResample);
end

disp(" ");
disp("Done.");
disp(" ");