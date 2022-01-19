function plot_methods(ht_a, ft_a, ht_mpz, ft_mpz, ht_foh, ft_foh, ht_bil, ft_bil, case_n, fs)
% PLOT_METHODS plots the frequency response graph of a filter, together with
% its several analog-to-digital transformations obtained by using different
% methods.
%
% Input parameters:
%   ht_a :      Analog filter frequency response vector
%   ft_a :      Corresponding analog filter physical frequency vector
%   ht_mpz :    Filter MPZ frequency response vector
%   ft_mpz :    Corresponding filter MPZ physical frequency vector
%   ht_foh :    Filter FOH frequency response vector
%   ft_foh :    Corresponding filter FOH physical frequency vector
%   ht_bil :    Filter bilinear frequency response vector
%   ft_bil :    Corresponding filter bilinear physical frequency vector
%   case_n :    Reference case number (used in title)
%   fs :        Sampling frequency [Hz]

% Line width.
line_width = 2;

% Compute analogue filter phase.
phase_a = angle(ht_a)*180/pi;

% Compute filter MPZ phase.
phase_mpz = angle(ht_mpz)*180/pi;

% Compute filter FOH phase.
phase_foh = angle(ht_foh)*180/pi;

% Compute filter bilinear phase.
phase_bil = angle(ht_bil)*180/pi;

% Figure title
figure('Name', strcat('Method comparison - Case ', num2str(case_n)));

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
% MATLAB default red color

subplot(2, 1, 1);
semilogx(ft_mpz, 20*log10(abs(ht_mpz)), '--', 'color', [0.6350, 0.0780, 0.1840], 'LineWidth', line_width);
hold on;

subplot(2, 1, 2);
semilogx(ft_mpz, phase_mpz, '--', 'color', [0.6350, 0.0780, 0.1840], 'LineWidth', line_width);
hold on;

% Display the digitized Filter FOH.
% MATLAB default yellow color

subplot(2, 1, 1);
semilogx(ft_foh, 20*log10(abs(ht_foh)), '--', 'LineWidth', line_width);
hold on;

subplot(2, 1, 2);
semilogx(ft_foh, phase_foh, '--', 'LineWidth', line_width);
hold on;

% Display the digitized Filter bilinear.
% MATLAB default purple color

subplot(2, 1, 1);
semilogx(ft_bil, 20*log10(abs(ht_bil)), '--', 'LineWidth', line_width);
hold on;
legend('Analog', 'MPZ', 'FOH', 'Bilinear');

subplot(2, 1, 2);
semilogx(ft_bil, phase_bil, '--', 'LineWidth', line_width);
hold on;
legend('Analog', 'MPZ', 'FOH', 'Bilinear');

% saveas(fig, strcat('Img/Plots/Method_Comparison-Case', num2str(case_n), '.png'));

end

