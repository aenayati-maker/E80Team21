clear
clc
close all

%%%%%%%%%%%%%%%%%%%%%
%% PUT DATA IN HERE
% Teensy voltage = output of second op amp
VoutB = [0.002, 0.434, 1.67, 2.068, 2.46, 2.89, 2.88, 2.834];

% Measured temperatures in C
TC = [35.9, 22.2, 19.0, 16.3, 13.5, 12.1, 11.5, 9.8];

% Convert to Kelvin because old code uses TN in K
TN = TC + 273.15;

%%%%%%%%%%%%%%%%%%%%%
%%  RESISTOR VALUES (with true values from lab)
% Thermistor divider fixed resistor ("47k one")
R3 = 50.07e3;   % ohms

% Second op amp resistors
Rm = 10.03e3;   % ohms

%  "40k" is two resistors in series
Rf1 = 20e3;  % ohms
Rf2 = 20.13e3;  % ohms
Rf = Rf1 + Rf2; % true resistance

% Reference divider for VinB+
R1 = 24.84e3;      % from +5V to VinB+ (remeasure this)
R2 = 17.53e3;   % from VinB+ to ground (remeasure this)

Vcc = 5.0;      % supply voltage

%%%%%%%%%%%%%%%%%%%%%
%% CONVERT TEENSY VOLTAGE TO THERMISTOR RESISTANCE
% Second op amp:
% VoutB = Vref*(1 + Rf/Rm) - (Rf/Rm)*VinA
% VinA = (Rm/Rf)*(Vref*(1 + Rf/Rm) - VoutB)

Vref = Vcc * R2/(R1 + R2);
VinA = (Rm/Rf) .* (Vref*(1 + Rf/Rm) - VoutB);

% Divider:
% VinA = Vcc*R3/(RT + R3)
% RT = R3*(Vcc/VinA - 1)

R = R3 .* (Vcc./VinA - 1);

disp('Converted thermistor resistances (ohms):')
disp(R)

confLev = 0.95; % We set the confidence level for the data fits here.

% Since a plot of 1/T vs ln(R) should be close to linear, we will convert
% the data to the correct forms and do linear and polynomial fits with
% them.
ooTN = 1./TN;
lnR = log(R);

% The default for confidence level is 0.95. If we wanted the confidence
% intervals on the parameters for a value of confLev other than 0.95, we
% would uncomment the following lines:
% format short e
% ci1 = confint(f1,confLev)
% ci2 = confint(f2,confLev)
% ci3 = confint(f3,confLev)
% format

%% Nonlinear Fit
% To compare this transformed linear fit of a polynomial with non-linear, let's
% do a non-linear fit using the Steinhart-Hart equation (but we'll include
% the 2nd-order term.

range = max(R) - min(R); % Get range for our xplot data
xplot = min(R):range/30:max(R); % Generate x data for some of our plots.

% First we have to define the function we will fit.
% Things work better if we have starting points for a, b, c, and d.
fo = fitoptions('Method','NonlinearLeastSquares', ...
   'StartPoint',[-0.002894 0.001339 -9.963e-05 3.053e-06]);

ft = fittype('1/(a+b*log(R)+c*(log(R)^2)+d*(log(R)^3))', ...
   'independent','R','options',fo);

% Next, we have to get our data into the correct format for 'fit'.
[Xout,Yout] = prepareCurveData(R, TN);

% Now we'll do our fit.
[f4,stat4] = fit(Xout,Yout,ft)

p11 = predint(f4,xplot,confLev,'observation','off'); % Gen conf bounds
p21 = predint(f4,xplot,confLev,'functional','off'); % Gen conf bounds

figure(1)
plot(f4,Xout,Yout) % Notice that the fit doesn't need both x and y.
hold on
plot(xplot, p21, '-.b') % Upper and lower functional confidence limits
plot(xplot, p11, '--m') % Upper and lower observational confidence limits
xlabel('Resistance (\Omega)')
ylabel('Temperature (K)')
title('Steinhart-Hart Fit for Data Taken')
legend('Data Points','Best Fit Line','Upper Func. Bound', ...
   'Lower Func. Bound', 'Upper Obs. Bound', 'Lower Obs. Bound', ...
   'Location', 'northeast')
hold off

%% Nonlinear Residuals
figure(2)
plot(f4,Xout,Yout,'residuals')
xlabel('Resistance (\Omega)')
ylabel('Residuals (K)')
title('Steinhart-Hart Fit Residuals')

%%%%%%%%%%%%%%%%%%%%%
%% OPTIONAL: DIRECT CALIBRATION CURVE FOR TEENSY VOLTAGE -> TEMPERATURE
% This gives you a direct curve for the Teensy output voltage.

rangeV = max(VoutB) - min(VoutB);
xplotV = min(VoutB):rangeV/100:max(VoutB);

Tplot = f4(R3 .* (Vcc ./ ((Rm/Rf) .* (Vref*(1 + Rf/Rm) - xplotV)) - 1));

figure(3)
plot(VoutB,TN,'o')
hold on
plot(xplotV,Tplot,'LineWidth',1.5)
xlabel('Teensy Voltage (V)')
ylabel('Temperature (K)')
title('Temperature vs Teensy Voltage Calibration Curve')
legend('Data Points','Best Fit Curve','Location','northeast')
grid on
hold off
