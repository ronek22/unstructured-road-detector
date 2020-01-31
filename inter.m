% Demo to illustrate how to use the polyfit routine to fit data to a polynomial
% and to use polyval() to get estimated (fitted) data from the coefficients that polyfit() returns.
% Demo first uses a linear fit, then uses a cubic fit.

% Initialization steps.
clc;    % Clear the command window.
close all;  % Close all figures (except those of imtool.)
clear;  % Erase all existing variables. Or clearvars if you want.
workspace;  % Make sure the workspace panel is showing.
format long g;
format compact;
fontSize = 20;

%============= LINEAR FIT ===================================
x = linspace(-10, 10, 20); % Make 20 samples along the x axis
% Create a sample training set, a linear relation, with noise
slope = 1.5;
intercept = -1;
noiseAmplitude = 15;
y = slope .* x + intercept + noiseAmplitude * rand(1, length(x));

% Plot the training set of data.
subplot(2, 1, 1);
plot(x, y, 'ro', 'MarkerSize', 8, 'LineWidth', 2);
grid on;
xlabel('X', 'FontSize', fontSize);
ylabel('Y', 'FontSize', fontSize);
title('Linear Fit', 'FontSize', fontSize);

% Enlarge figure to full screen.
set(gcf, 'Units', 'Normalized', 'OuterPosition', [0 0 1 1]);
% Give a name to the title bar.
set(gcf, 'Name', 'Demo by ImageAnalyst', 'NumberTitle', 'Off') 

% Do the regression with polyfit
linearCoefficients = polyfit(x, y, 1);
% The x coefficient, slope, is coefficients(1).
% The constant, the intercept, is coefficients(2).
% Make fit.  It does NOT need to have the same
% number of elements as your training set, 
% or the same range, though it could if you want.
% Make 50 fitted samples going from -15 to +20.
xFit = linspace(-15, 20, 50);
% Get the estimated values with polyval()
yFit = polyval(linearCoefficients, xFit);
% Plot the fit
hold on;
plot(xFit, yFit, 'b.-', 'MarkerSize', 15, 'LineWidth', 1);
legend('Training Set', 'Fit', 'Location', 'Northwest');

%============= CUBIC FIT ===================================
x = linspace(-10, 10, 20); % Make 20 samples along the x axis
% Create a sample training set, a cubic relation, with noise
c1 = 1;
c2 = 2;
c3 = -10;
c4 = 4;
noiseAmplitude = 500;
y = c1 .* x .^3 + c2 .* x .^2 + c3 .* x + c4 + noiseAmplitude * rand(1, length(x));

% Plot the training set of data.
subplot(2, 1, 2);
plot(x, y, 'ro', 'MarkerSize', 8, 'LineWidth', 2);
grid on;
xlabel('X', 'FontSize', fontSize);
ylabel('Y', 'FontSize', fontSize);
title('Cubic Fit', 'FontSize', fontSize);

% Do the regression with polyfit
cubicCefficients = polyfit(x, y, 3)
% The x coefficient, slope, is coefficients(1).
% The constant, the intercept, is coefficients(2).
% Make fit.  It does NOT need to have the same
% number of elements as your training set, 
% or the same range, though it could if you want.
% Make 500 fitted samples going from -13 to +12.
xFit = linspace(-13, 12, 500);
% Get the estimated values with polyval()
yFit = polyval(cubicCefficients, xFit);
% Plot the fit
hold on;
plot(xFit, yFit, 'b-', 'LineWidth', 2);
grid on;
legend('Training Set', 'Fit', 'Location', 'Northwest');

