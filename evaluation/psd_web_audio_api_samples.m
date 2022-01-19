clear variables;
close all;

%% Parameters

% Window length.
N = 1024;
% Number of overlapping samples.
noverlap = N/4;

% Vector of frequencies at which PSD will be computed.
f = 20:4:20000;

%% Input files - API: Convolution VS IIRFilterNode

ref_arr = ["W3_R7C/sample1_W3_R3",  "W7N_R15C/sample2_W7N_R7N",  "W7N_R15C/sample3_W7N_R7N",  "W3_R7C/sample4_W3_R3",  "W3_R7C/sample5_W3_R3",  "W7N_R15C/sample6_W7N_R7N",  "", "W3_R7C/sample8_W3_R3",  "W3_R7C/sample9_W3_R3",  "W7N_R15C/sample10_W7N_R7N",  "", "W7N_R15C/sample12_W7N_R7N",  "", "", "W3_R15C/sample15_W3_R3",   "W3_R15C/sample16_W3_R3",   "W3_R15C/sample17_W3_R3",   "W3_R15C/sample18_W3_R3",   "", "", "", "W3_R15C/sample22_W3_R3"  ];
inc_arr = ["W3_R7C/sample1_W3_R7C", "W7N_R15C/sample2_W7N_R15C", "W7N_R15C/sample3_W7N_R15C", "W3_R7C/sample4_W3_R7C", "W3_R7C/sample5_W3_R7C", "W7N_R15C/sample6_W7N_R15C", "", "W3_R7C/sample8_W3_R7C", "W3_R7C/sample9_W3_R7C", "W7N_R15C/sample10_W7N_R15C", "", "W7N_R15C/sample12_W7N_R15C", "", "", "W3_R15C/sample15_W3_R15C", "W3_R15C/sample16_W3_R15C", "W3_R15C/sample17_W3_R15C", "W3_R15C/sample18_W3_R15C", "", "", "", "W3_R15C/sample22_W3_R15C"];
iir_arr = ["sample1_W3_R7C",        "sample2_W7N_R15C",          "sample3_W7N_R15C",          "sample4_W3_R7C",        "sample5_W3_R7C",        "sample6_W7N_R15C",          "", "sample8_W3_R7C",        "sample9_W3_R7C",        "sample10_W7N_R15C",          "", "sample12_W7N_R15C",          "", "", "sample15_W3_R15C",         "sample16_W3_R15C",         "sample17_W3_R15C",         "sample18_W3_R15C",         "", "", "", "sample22_W3_R15C"        ];

RMSE_api_arr = zeros(15,1);
RMSE_iir_arr = zeros(15,1);
i = 1;

for sample = [1, 2, 3, 4, 5, 6, 8, 9, 10, 12, 15, 16, 17, 18, 22]
    
    disp("Sample " + sample)
    
    % Import REFERENCE signal.
    [ref, fs_ref] = audioread(strcat("/Users/csc1csc2/Documents/Pubblicazione Tesi/CloudDEI/", ref_arr(sample), "_REFERENCE.wav"));
    % Import INCORRECT signal.
    [inc, fs_inc] = audioread(strcat("/Users/csc1csc2/Documents/Pubblicazione Tesi/CloudDEI/", inc_arr(sample), "_INCORRECT.wav"));
    % Import Web Audio API repaired signal (with convolution).
    [api, fs_api] = audioread(strcat("/Users/csc1csc2/Documents/Pubblicazione Tesi/CloudDEI/", inc_arr(sample), "_API.wav"));
    % Import Web Audio API repaired signal (with IIRFilterNode).
    [iir, fs_iir] = audioread(strcat("Audio/", iir_arr(sample), "_INCORRECT_NAB_CCIR_Correction.wav"));

    % To compare the PSDs we have to consider the speed change.
    fs_ratio = fs_inc/fs_ref;

    %% Power Spectral Density

    % Compute PSDs.
    psd_ref = pwelch(ref, hamming(N), noverlap, f, fs_ref);
    psd_inc = pwelch(inc, hamming(N*fs_ratio), noverlap*fs_ratio, f, fs_inc);
    psd_api = pwelch(api, hamming(N), noverlap, f, fs_api);
    psd_iir = pwelch(iir, hamming(N), noverlap, f, fs_iir);

    % Sum PSDs on the two channels.
    psd_ref = psd_ref(:,1) + psd_ref(:,2);
    psd_inc = psd_inc(:,1) + psd_inc(:,2);
    psd_api = psd_api(:,1) + psd_api(:,2);
    psd_iir = psd_iir(:,1) + psd_iir(:,2);

    % Compute the absolute value.
    abs_ref = 10*log10(abs(psd_ref));
    abs_inc = 10*log10(abs(psd_inc));
    abs_api = 10*log10(abs(psd_api));
    abs_iir = 10*log10(abs(psd_iir));
    
    % Compute difference |Reference-API|-|Reference-IIRFilterNode|.
    diff = abs(abs_ref - abs_api) - abs(abs_ref - abs_iir);
    % Informative: Compute mean of the difference, weighted on the
    % frequencies (20 Hz has most importance with unit gain, it then
    % linearly decreases moving up in frequency to a gain of 0.001 for
    % 20000 Hz).
    diff_mean = 20*mean(diff./transpose(f));

    % Compute RMSEs.
    RMSE_api = sqrt(mean((abs_ref - abs_api).^2));
    disp("RMSE ConvolutionNode: " + RMSE_api);
    RMSE_api_arr(i) = RMSE_api;
    RMSE_iir = sqrt(mean((abs_ref - abs_iir).^2));
    disp("RMSE IIRFilterNode: " + RMSE_iir);
    RMSE_iir_arr(i) = RMSE_iir;
    i = i+1;

    %% Plots

    % Plot the PSD of all signals
    figure('Name', strcat('PSD - Sample ', num2str(sample)));
    semilogx(f, abs_ref, 'LineWidth', 1);
    grid on;
    title(strcat('PSD - Sample ', num2str(sample)));
    xlim([20, 20000]);
    xlabel("Frequency [Hz]");
    ylabel("PSD [dB/Hz]");
    hold on;
    semilogx(f, abs_inc, 'LineWidth', 1);
    semilogx(f, abs_api, 'LineWidth', 1);
    semilogx(f, abs_iir, 'LineWidth', 1);
    hold off;
    legend('Reference', 'Incorrect', 'ConvolverNode', 'IIRFilterNode');
    
    saveas(gcf, strcat('Figure/PSD/sample', num2str(sample), '_PSD.png'));

    % Plot |Reference-API|-|Reference-IIRFilterNode|
    % If the difference is positive, the IIRFilterNode signal is nearer to the
    % Reference than the API one.
    figure('Name', strcat('PSD absolute difference - Sample ', num2str(sample)));
    semilogx(f, diff, 'LineWidth', 1);
    grid on;
    title(strcat('PSD absolute difference - Sample ', num2str(sample)));
    subtitle(strcat('Mean:', {' '}, num2str(diff_mean), {' '}, 'dB'));
    xlim([20, 20000]);
    xlabel("Frequency [Hz]");
    ylabel("PSD absolute difference [dB/Hz]");
    legend("|P_R-P_{CN}|-|P_R-P_{IFN}|");
    
    saveas(gcf, strcat('Figure/PSD/sample', num2str(sample), '_PSD_diff.png'));

end

m_RMSE_api = mean(RMSE_api_arr);
m_RMSE_iir = mean(RMSE_iir_arr);

disp("Mean RMSE ConvolverNode: " + m_RMSE_api);
disp("Mean RMSE IIRFilterNode: " + m_RMSE_iir);
