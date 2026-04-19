
% Run logreader.m first
temp_voltage = cast(A01,"double") * 3.3 / 1024;
pressure_voltage = cast(A00,"double") * 3.3 / 1024;
visible_plus_ir = ch0;
infrared = ch1;

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


%% PLOTY PLOT PLOTSSSSS

figure;
plot(depth, T_C, 'o')
xlabel('Depth (m)')
ylabel('Temperature (°C)')
title('Temperature vs Depth')
legend('Legend')
%subplot(3,1,1)
grid on

figure;
plot(depth, light_vis, 'o')
xlabel('Depth (m)')
ylabel('Visible + IR')
title('Light vs Depth')
legend('Legend')
%subplot(3,1,2)
grid on

figure;
plot(depth, light_ir, 'o')
xlabel('Depth (m)')
ylabel('Infrared')
title('Infrared vs Depth')
legend('Legend')
%subplot(3,1,3)
grid on

figure
plot(T_C, 'o')
xlabel('Sample Number')
ylabel('Temperature (°C)')
title('Temperature')
grid on

figure
plot(light_vis, 'o')
xlabel('Sample Number')
ylabel('Visible + IR')
title('Light')
grid on

figure
plot(depth, 'o')
xlabel('Sample Number')
ylabel('Depth (m)')
title('Depth')
grid on
