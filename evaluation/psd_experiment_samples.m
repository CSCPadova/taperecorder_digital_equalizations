clear variables;
close all;

%% Parameters

% Window length.
N = 1024;
% Number of overlapping samples.
noverlap = N/4;
% Signal length.
L = length(ref);

% Vector of frequencies at which PSD will be computed.
f = 20:4:20000;

%% Input files - Experiment: Web Audio API Convolution VS Matlab filtering

ref_arr = ["W3_R7C/sample1_W3_R3",  "W7N_R15C/sample2_W7N_R7N",  "W7N_R15C/sample3_W7N_R7N",  "W3_R7C/sample4_W3_R3",  "W3_R7C/sample5_W3_R3",  "W7N_R15C/sample6_W7N_R7N",  "", "W3_R7C/sample8_W3_R3",  "W3_R7C/sample9_W3_R3",  "W7N_R15C/sample10_W7N_R7N",  "", "W7N_R15C/sample12_W7N_R7N",  "", "", "W3_R15C/sample15_W3_R3",   "W3_R15C/sample16_W3_R3",   "W3_R15C/sample17_W3_R3",   "W3_R15C/sample18_W3_R3",   "", "", "", "W3_R15C/sample22_W3_R3"  ];
inc_arr = ["W3_R7C/sample1_W3_R7C", "W7N_R15C/sample2_W7N_R15C", "W7N_R15C/sample3_W7N_R15C", "W3_R7C/sample4_W3_R7C", "W3_R7C/sample5_W3_R7C", "W7N_R15C/sample6_W7N_R15C", "", "W3_R7C/sample8_W3_R7C", "W3_R7C/sample9_W3_R7C", "W7N_R15C/sample10_W7N_R15C", "", "W7N_R15C/sample12_W7N_R15C", "", "", "W3_R15C/sample15_W3_R15C", "W3_R15C/sample16_W3_R15C", "W3_R15C/sample17_W3_R15C", "W3_R15C/sample18_W3_R15C", "", "", "", "W3_R15C/sample22_W3_R15C"];

for sample = [1, 2, 3, 4, 5, 6, 8, 9, 10, 12, 15, 16, 17, 18, 22]
    
    % Import REFERENCE signal.
    [ref, fs_ref] = audioread(strcat("/Users/nadir/Documents/Pubblicazione Tesi/CloudDEI/", ref_arr(sample), "_REFERENCE.wav"));
    % Import INCORRECT signal.
    [inc, fs_inc] = audioread(strcat("/Users/nadir/Documents/Pubblicazione Tesi/CloudDEI/", inc_arr(sample), "_INCORRECT.wav"));
    % Import Web Audio API signal (with convolution).
    [api, fs_api] = audioread(strcat("/Users/nadir/Documents/Pubblicazione Tesi/CloudDEI/", inc_arr(sample), "_API.wav"));
    % Import MATLAB signal.
    [mat, fs_mat] = audioread(strcat("/Users/nadir/Documents/Pubblicazione Tesi/CloudDEI/", inc_arr(sample), "_MATLAB.wav"));

    % To compare the PSDs we have to consider the speed change.
    fs_ratio = fs_inc/fs_ref;

    %% Power Spectral Density

    % Compute PSDs.
    psd_ref = pwelch(ref, hamming(N), noverlap, f, fs_ref);
    psd_inc = pwelch(inc, hamming(N*fs_ratio), noverlap*fs_ratio, f, fs_inc);
    psd_api = pwelch(api, hamming(N), noverlap, f, fs_api);
    psd_mat = pwelch(mat, hamming(N*fs_ratio), noverlap*fs_ratio, f, fs_mat);

    % Sum PSDs on the two channels.
    psd_ref = psd_ref(:,1) + psd_ref(:,2);
    psd_inc = psd_inc(:,1) + psd_inc(:,2);
    psd_api = psd_api(:,1) + psd_api(:,2);
    psd_mat = psd_mat(:,1) + psd_mat(:,2);

    % Compute the absolute value.
    abs_ref = 10*log10(abs(psd_ref));
    abs_inc = 10*log10(abs(psd_inc));
    abs_api = 10*log10(abs(psd_api));
    abs_mat = 10*log10(abs(psd_mat));

    %% Plots

    % Plot the PSD of all signals.
    figure('Name', strcat('PSD - Sample ', num2str(sample)));
    semilogx(f, abs_ref, 'LineWidth', 1);
    grid on;
    xlim([20, 20000]);
    xlabel("Frequency [Hz]");
    ylabel("PSD [dB/Hz]");
    hold on;
    semilogx(f, abs_inc, 'LineWidth', 1);
    semilogx(f, abs_api, 'LineWidth', 1);
    semilogx(f, abs_mat, 'LineWidth', 1);
    hold off;
    legend('Reference', 'Incorrect', 'Web Audio API', 'Matlab');

    saveas(gcf, strcat('Figure/PSD/sample', num2str(sample), '_PSD_Exp.png'));
    
    % Plot |Reference-API|-|Reference-Matlab|.
    % If the difference is positive, the Matlab signal is nearer to the
    % Reference than the API one.
    figure('Name', strcat('PSD absolute difference - Sample ', num2str(sample)));
    semilogx(f, abs(abs_ref - abs_api) - abs(abs_ref - abs_mat), 'LineWidth', 1);
    grid on;
    xlim([20, 20000]);
    xlabel("Frequency [Hz]");
    ylabel("PSD absolute difference [dB/Hz]");
    legend("|P_R-P_{API}|-|P_R-P_{Matlab}|");
    
    saveas(gcf, strcat('Figure/PSD/sample', num2str(sample), '_PSD_diff_Exp.png'));
    
end