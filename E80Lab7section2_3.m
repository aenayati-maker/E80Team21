% E80 Lab 7 
% Section 2.3
% IMU Position Estimation




% Extract acceleration columns MAKE SURE THESE ARE THE RIGHT COLLUMN NAMES
ax_mg = accelX;   % acceleration in X (mg)
ay_mg = accelY;   % acceleration in Y (mg)

% Constants
dt = 0.099; % sample time (seconds) from E80 lab
g = 9.81; % gravity (m/s^2)

% Convert Units (mg -> m/s^2)
ax = ax_mg * g / 1000;
ay = ay_mg * g / 1000;

% Remove Bias i think im doing this right?
% Assume first 2ish seconds is stationary
N_bias = round(2 / dt);

ax_bias = mean(ax(1:N_bias));
ay_bias = mean(ay(1:N_bias));

% Subtract bias
ax = ax - ax_bias;
ay = ay - ay_bias;

% Integrate: Acceleration -> Velocity
vx = cumtrapz(ax) * dt; %cumtrapz computes the approximate cumulative integral of Y via the trapezoidal method with unit spacing.
vy = cumtrapz(ay) * dt;

% Integrate: Velocity -> Position
x = cumtrapz(vx) * dt;
y = cumtrapz(vy) * dt;

% Time vector
t = (0:length(x)-1) * dt;

% Ideal Path (0 -> 0.5 m -> 0)
% Straight line forward and back
x_ideal = [0 0.5 0];
y_ideal = [0 0   0];


% Plot 1: X-Y Path
figure;
plot(x, y, 'b', 'LineWidth', 2);
hold on;
plot(x_ideal, y_ideal, 'r--', 'LineWidth', 2);

xlabel('X Position (m)');
ylabel('Y Position (m)');
title('IMU Estimated Path vs Ideal Path');
legend('Measured Path', 'Ideal Path');
grid on;


sigma_a = 0.02 * g;  % m/s^2
confLev = 0.95; % The confidence level for bounds
preie = sqrt(2)*erfinv(confLev)*sigma_a*sqrt(dt); % the prefix to the sqrt(t)
preiie = 2/3*preie; % The prefix to t^3/2a = 1 + sin( pi*t - pi/2);
plusie=preie*t.^0.5; % The positive noise bound for one integration
plusiie = preiie*t.^1.5; % The positive noise bound for double integration

rnp = y + plusiie'; % Position plus confidence bound
rnm = y - plusiie'; % Position minus confidence bound

% Uncertainty Calculation
% We assume accelerometer noise (approx value)

% Uncertainty grows with double integration
sigma_y = sigma_a * (t.^2) / 2;

% Plot 2: Y vs Time with Bounds
figure;
plot(t, y, 'b', 'LineWidth', 2); hold on;
plot(t, rnp, 'r--');
plot(t, rnm, 'r--');

xlabel('Time (s)');
ylabel('Y Position (m)');
title('Y Position vs Time with Uncertainty Bounds');
legend('Estimated y', '+ Uncertainty', '- Uncertainty');
grid on;


% Printting useful numbers
fprintf('File: %s\n', filename);
fprintf('Number of samples: %d\n', N);
fprintf('dt = %.3f s\n', dt);
fprintf('Estimated x-bias = %.6f m/s^2\n', ax_bias);
fprintf('Estimated y-bias = %.6f m/s^2\n', ay_bias);
fprintf('Estimated sigma_ax = %.6f m/s^2\n', sigma_ax);
fprintf('Estimated sigma_ay = %.6f m/s^2\n', sigma_ay);
fprintf('Final estimated x = %.4f m\n', x(end));
fprintf('Final estimated y = %.4f m\n', y(end));
fprintf('Final %s half-width = %.4f m\n', boundLabel, y_upper(end));