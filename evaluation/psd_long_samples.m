clear variables;
close all;

%% Parameters

% Window length.
N = 4096;
% Number of overlapping samples.
noverlap = N/4;

% Vector of frequencies at which PSD will be computed.
f = 20:4:20000;

%% Input files - Studer Long Samples corrected in Matab

ref_arr = ["W3N_R3N",                              "W3N_R3N",                             "W3N_R3N",                              "W3N_R3N",                             "W7C_R7C",                               "W7C_R7C",                             "W7C_R7C",                              "W7C_R7C",                             "W7N_R7N",                              "W7N_R7N",                             "W7N_R7N",                             "W7N_R7N",                            "W15C_R15C",                             "W15C_R15C",                             "W15C_R15C",                            "W15C_R15C",                           "W15N_R15N",                            "W15N_R15N",                            "W15N_R15N",                           "W15N_R15N"                          ];
inc_arr = ["W3N_R7C",                              "W3N_R7N",                             "W3N_R15C",                             "W3N_R15N",                            "W7C_R3N",                               "W7C_R7N",                             "W7C_R15C",                             "W7C_R15N",                            "W7N_R3N",                              "W7N_R7C",                             "W7N_R15C",                            "W7N_R15N",                           "W15C_R3N",                              "W15C_R7C",                              "W15C_R7N",                             "W15C_R15N",                           "W15N_R3N",                             "W15N_R7C",                             "W15N_R7N",                            "W15N_R15C"                          ];
mat_arr = ["W3N_R7C__NABw3.75_CCIRr7.5_48000Hz24", "W3N_R7N__NABw3.75_NABr7.5_48000Hz24", "W3N_R15C__NABw3.75_CCIRr15_24000Hz24", "W3N_R15N__NABw3.75_NABr15_24000Hz24", "W7C_R3N__CCIRw7.5_NABr3.75_192000Hz24", "W7C_R7N__CCIRw7.5_NABr7.5_96000Hz24", "W7C_R15C__CCIRw7.5_CCIRr15_48000Hz24", "W7C_R15N__CCIRw7.5_NABr15_48000Hz24", "W7N_R3N__NABw7.5_NABr3.75_192000Hz24", "W7N_R7C__NABw7.5_CCIRr7.5_96000Hz24", "W7N_R15C__NABw7.5_CCIRr15_48000Hz24", "W7N_R15N__NABw7.5_NABr15_48000Hz24", "W15C_R3N__CCIRw15_NABr3.75_384000Hz24", "W15C_R7C__CCIRw15_CCIRr7.5_192000Hz24", "W15C_R7N__CCIRw15_NABr7.5_192000Hz24", "W15C_R15N__CCIRw15_NABr15_96000Hz24", "W15N_R3N__NABw15_NABr3.75_384000Hz24", "W15N_R7C__NABw15_CCIRr7.5_192000Hz24", "W15N_R7N__NABw15_NABr7.5_192000Hz24", "W15N_R15C__NABw15_CCIRr15_96000Hz24"];

for sample = 1 : length(ref_arr)
    
    disp("Sample " + sample);
    
    % Time measurement.
    c = fix(clock);
    disp(c(4) + ":" + c(5) + ":" + c(6) + " - Reading files...");
    % Import REFERENCE signal.
    [ref, fs_ref] = audioread(strcat("/Users/csc1csc2/Documents/Pubblicazione Tesi/MULTIPLE SPEED + EQ TEST/", ref_arr(sample), ".wav"));
    % Import INCORRECT signal.
    [inc, fs_inc] = audioread(strcat("/Users/csc1csc2/Documents/Pubblicazione Tesi/MULTIPLE SPEED + EQ TEST/", inc_arr(sample), "_.wav"));
    % Import MATLAB signal.
    [mat, fs_mat] = audioread(strcat("/Users/csc1csc2/Documents/Pubblicazione Tesi/digital_equalizations/Audio/Output/", mat_arr(sample), "_newTimeConstants.wav")); % MODIFICA: aggiunto _newTimeConstants
    
    % To compare the PSDs...
    fs_ratio = fs_mat/fs_ref;
    % ...we have to consider the speed_change
    % -> Reinterpreting the sampling frequency of INCORRECT signal.
    fs_inc = fs_inc*fs_ratio;

    %% Power Spectral Density

    % Compute PSDs.
    c = fix(clock);
    disp(c(4) + ":" + c(5) + ":" + c(6) + " - Computing reference PSD...");
    psd_ref = pwelch(ref, hamming(N), noverlap, f, fs_ref);
    c = fix(clock);
    disp(c(4) + ":" + c(5) + ":" + c(6) + " - Computing incorrect PSD...");
    psd_inc = pwelch(inc, hamming(N*fs_ratio), noverlap*fs_ratio, f, fs_inc);
    c = fix(clock);
    disp(c(4) + ":" + c(5) + ":" + c(6) + " - Computing corrected PSD...");
    psd_mat = pwelch(mat, hamming(N*fs_ratio), noverlap*fs_ratio, f, fs_mat);
    
    % Sum PSDs on the two channels.
    c = fix(clock);
    disp(c(4) + ":" + c(5) + ":" + c(6) + " - Summing PSDs...");
    psd_ref = psd_ref(:,1) + psd_ref(:,2);
    psd_inc = psd_inc(:,1) + psd_inc(:,2);
    psd_mat = psd_mat(:,1) + psd_mat(:,2);

    % Compute the absolute value.
    c = fix(clock);
    disp(c(4) + ":" + c(5) + ":" + c(6) + " - Computing absolute value...");
    abs_ref = 10*log10(abs(psd_ref));
    abs_inc = 10*log10(abs(psd_inc));
    abs_mat = 10*log10(abs(psd_mat));

    %% Plots

    % Plot the PSD of all signals.
    c = fix(clock);
    disp(c(4) + ":" + c(5) + ":" + c(6) + " - Generating figure...");
    figure('Name', strcat('PSD -', {' '}, inc_arr(sample)));
    semilogx(f, abs_ref, 'LineWidth', 1);
    grid on;
    title(strcat('PSD -', {' '}, inc_arr(sample)), 'Interpreter', 'none');
    xlim([20, 20000]);
    xlabel("Frequency [Hz]");
    ylabel("PSD [dB/Hz]");
    hold on;
    semilogx(f, abs_inc, 'LineWidth', 1);
    semilogx(f, abs_mat, 'LineWidth', 1);
    hold off;
    legend('Reference', 'Incorrect', 'Corrected');
    
    c = fix(clock);
    disp(c(4) + ":" + c(5) + ":" + c(6) + " - Saving figure...");
    saveas(gcf, strcat('Figure/PSD/', inc_arr(sample), '_PSD.png'));
    
    disp(" ");

end