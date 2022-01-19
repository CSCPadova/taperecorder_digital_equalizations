function plot_ir(stabfiltimp, T, case_n)
% PLOT_IR plots the impulse response of a filter.
%
% Input parameters:
%   sabfiltimp: Filter impulse response
%   T :         Sample times on which the impulse response is computed
%   case_n :    Reference case number (used in title)

% Figure title
figure('Name', strcat('Impulse response - Case ', num2str(case_n)));

plot(T, stabfiltimp, '.');
grid on;

end