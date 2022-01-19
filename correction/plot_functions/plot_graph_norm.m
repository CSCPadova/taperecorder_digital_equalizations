function plot_graph_norm(ht_a, ft_a, ht_mpz, ft_mpz, ht_mpz_norm, ft_mpz_norm, case_n, fs, WAV)
% PLOT_GRAPH_NORM plots the frequency response graph of a filter, together 
% with its MPZ digitisation, and the normalized MPZ digitisation.
%
% Input parameters:
%   ht_a :          Analog filter frequency response vector
%   ft_a :          Corresponding analog filter physical frequency vector
%   ht_mpz :        Filter MPZ frequency response vector
%   ft_mpz :        Corresponding filter MPZ angular frequency vector
%   ht_mpz_norm :   Normalized filter MPZ frequency response vector
%   ft_mpz_norm :   Corresponding normalized filter MPZ angular frequency vector
%   case_n :        Reference case number (used in title)
%   fs :            Sampling frequency [Hz]
%   WAV :           Optional: FFT of produced wav file

% Line width.
line_width = 2;

% Compute analogue filter phase.
phase_a = angle(ht_a)*180/pi;

% Compute filter MPZ phase.
phase_mpz = angle(ht_mpz)*180/pi;

% Compute normalized filter MPZ phase.
phase_mpz_norm = angle(ht_mpz_norm)*180/pi;

if exist('WAV', 'var')
    % Compute WAV phase.
    phase_wav = angle(WAV)*180/pi;
    f = linspace(0, fs, length(WAV));
end

% Figure title.
figure('Name', strcat('Frequency response - Case ', num2str(case_n)));

% Display analogue function.
% Black color

subplot(2, 1, 1);
semilogx(ft_a, 20*log10(abs(ht_a)), 'k', 'LineWidth', line_width);
hold on;
xlabel('Frequency [Hz]'), ylabel('Amplitude [dB]');
set(gca, 'FontSize', 14); 
xlim([1, fs/2]);
grid on;

subplot(2, 1, 2);
semilogx(ft_a, phase_a, 'k', 'LineWidth', line_width);
hold on;
xlabel('Frequency [Hz]'), ylabel('Phase [deg]');
set(gca, 'FontSize', 14); 
xlim([1, fs/2]);
grid on;

% Display the digitized Filter MPZ.
% MATLAB default red colour

subplot(2, 1, 1);
semilogx(ft_mpz, 20*log10(abs(ht_mpz)), '--', 'color', [0.6350, 0.0780, 0.1840], 'LineWidth', line_width);
hold on;

subplot(2, 1, 2);
semilogx(ft_mpz, phase_mpz, '--', 'color', [0.6350, 0.0780, 0.1840], 'LineWidth', line_width);
hold on;

% Display the digitized Filter MPZ with ratio 8:1.
% MATLAB default orange colour

subplot(2, 1, 1);
semilogx(ft_mpz_norm, 20*log10(abs(ht_mpz_norm)), '--', 'color', [0.8500, 0.3250, 0.0980], 'LineWidth', line_width);
hold on;
legend('Analog', 'MPZ', 'MPZ - 8:1');

subplot(2, 1, 2);
semilogx(ft_mpz_norm, phase_mpz_norm, '--', 'color', [0.8500, 0.3250, 0.0980], 'LineWidth', line_width);
hold on;
legend('Analog', 'MPZ', 'MPZ - 8:1');

if exist('WAV', 'var')
    % Display the frequency response of the produced wav file.
    % MATLAB default green color

    subplot(2, 1, 1);
    semilogx(f, 20*log10(abs(WAV)), '-.', 'color', [0.4660, 0.6740, 0.1880], 'LineWidth', line_width);
    hold on;
    legend('Analog', 'MPZ', 'MPZ - 8:1', 'WAV');

    subplot(2, 1, 2);
    semilogx(f, phase_wav, '-.', 'color', [0.4660, 0.6740, 0.1880], 'LineWidth', line_width);
    hold on;
    legend('Analog',  'MPZ', 'MPZ - 8:1', 'WAV');
end

% saveas(fig, strcat('Img/Plots/Case', num2str(case_n), '.png'));

end