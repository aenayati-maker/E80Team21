
% Run logreader.m first


% check what comes out of log reader just in case 
disp('Variables loaded:')


% VARIABLE NAMES (WE SHOULD CHANGE BASED ON ABOVE DONT FORGET)

Vtemp_out  = temp_voltage;        % thermistor circuit output voltage
Vpress_raw = pressure_voltage;    % pressure sensor voltage (pin 16)
light_vis  = visible_plus_ir;     % LTR CH0
light_ir   = infrared;            % LTR CH1

%% TEMPERATURE CALIBRATION

% Teensy voltage
VoutB = Vtemp_out;

% RESISTOR VALUES 
R3 = 47.2e3;
Rm = 9.9e3;

Rf1 = 20e3;
Rf2 = 20.13e3;
Rf = Rf1 + Rf2;

R1 = 28.58e3;
R2 = 18.82e3;

Vcc = 5.0;

% Convert Teensy voltage to VinA
Vref = Vcc * R2/(R1 + R2);
VinA = (Rm/Rf) .* (Vref*(1 + Rf/Rm) - VoutB);

% Convert that to thermistor resistance
R = R3 .* (Vcc./VinA - 1);

% Steinhart-Hart coefficients from the fit we ran Apr 1
a = -0.01675;
b = 0.005132;
c = -0.0004476;
d = 1.344e-05;

% Convert that to temperature
T_K = 1 ./ (a + b.*log(R) + c.*(log(R)).^2 + d.*(log(R)).^3);
T_C = T_K - 273.15;


%% PRESSURE CALIBRATION

% We need to do this calibration curve on site so remember to do this first
% for our data

x = [ ]; % Voltage (V)
y = [ ]; % Depth (m)


confLev = 0.95;
N = length(y);

xbar = mean(x);
ybar = mean(y);

Sxx = dot((x-xbar),(x-xbar));

% Best-fit slope
beta1 = dot((x-xbar),(y-ybar))/Sxx

% Best-fit intercept
beta0 = ybar - beta1*xbar

% Residuals
yfit = beta0 + beta1*x;
SSE = dot((y - yfit),(y - yfit))
Se = sqrt(SSE/(N-2))

% Errors
Sbeta0 = Se*sqrt(1/N + xbar^2/Sxx)
Sbeta1 = Se/sqrt(Sxx)

StdT = tinv((1-0.5*(1-confLev)),N-2)

lambdaBeta1 = StdT*Sbeta1
lambdaBeta0 = StdT*Sbeta0

% Plot calibration curve
range = max(x) - min(x);
xplot = min(x):range/30:max(x);
yplot = beta0 + beta1*xplot;

Syhat = Se*sqrt(1/N + (xplot - xbar).*(xplot - xbar)/Sxx);
lambdayhat = StdT*Syhat;

Sy = Se*sqrt(1+1/N + (xplot - xbar).*(xplot - xbar)/Sxx);
lambday = StdT*Sy;

figure;
plot(x,y,'o')
hold on
plot(xplot,yplot,'-')
plot(xplot,yplot+lambdayhat,'-.')
plot(xplot,yplot-lambdayhat,'-.')
plot(xplot,yplot+lambday,'--')
plot(xplot,yplot-lambday,'--')
xlabel('Voltage (V)')
ylabel('Depth (m)')
title('Depth vs Voltage Calibration Curve')

if beta1 > 0
   location = 'northwest';
else
   location = 'northeast';
end

legend('Data Points','Best Fit Line','Upper Func. Bound',...
   'Lower Func. Bound', 'Upper Obs. Bound', 'Lower Obs. Bound',...
   'Location', location)

grid on
hold off

%% Use the data from above to convert our log to depth to plot
depth_m = beta0 + beta1 .* Vpress_raw;

%% Should we find a way to clean the data? 

%% PLOTY PLOT PLOTSSSSS


figure;
plot(T_C, depth_m, 'o-')
xlabel('Temperature (°C)')
ylabel('Depth (m)')
title('Temperature vs Depth')
legend('Legend')
grid on

figure;
plot(light_vis, depth_m, 'o-')
xlabel('Visible + IR')
ylabel('Depth (m)')
title('Light vs Depth')
legend('Legend')
grid on

figure;
plot(light_ir, depth_m, 'o-')
xlabel('Infrared')
ylabel('Depth (m)')
title('Infrared vs Depth')
legend('Legend')
grid on