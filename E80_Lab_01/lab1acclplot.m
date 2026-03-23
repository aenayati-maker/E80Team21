%lab1acclplot.m
%Alexander Bilello abilell@hmc.edu
%Amy Enayati aenayati@g.edu
%Ellen Yu ellyu@hmc.edu
%Kate Risse krisse@hmc.edu
%Willa Switzer wswitzer@hmc.edu
% 1/28/2026



%% assuming accelX, accelY, accelZ (from logreader.m)
%% assuming acess to some accelZ0 (from different run of logreader.m at 90degree rot)

accelZ0 = [9.2590332e+02;9.5837402e+02;1.0092773e+03;1.1268921e+03;1.0185547e+03;9.7509766e+02;9.9871826e+02;9.9353027e+02;1.0825806e+03;1.0275879e+03;1.1840820e+03;1.1318970e+03;1.0102539e+03;9.5117188e+02;9.8791504e+02;9.7442627e+02;1.0807495e+03;1.0410156e+03;1.3017578e+03;1.2033691e+03;1.0964355e+03;9.4445801e+02;9.8986816e+02;1.1280518e+03;9.7888184e+02;9.6398926e+02;1.0063477e+03;1.1234741e+03;1.0952759e+03;9.6282959e+02;1.1453857e+03;9.6520996e+02;8.9147949e+02;1.0332642e+03;1.2455444e+03;1.0301514e+03;1.0864258e+03;9.5336914e+02;8.4295654e+02;9.6575928e+02;1.0476074e+03;1.0098267e+03;1.1873779e+03;1.0009766e+03;9.0795898e+02;9.9212646e+02;9.8211670e+02;1.0115967e+03;1.0157471e+03;1.0070190e+03;1.0473633e+03;1.0383301e+03;9.8071289e+02;9.3463135e+02;9.9523926e+02;1.0062256e+03;1.1137085e+03;1.0308838e+03;1.0300903e+03;9.8077393e+02;9.7863770e+02;9.6929932e+02;9.5812988e+02];

%%  acelleration plots (x0,y0,z,z0)

figure

%plot x accel 
plot(accelX,"-squarer")
title('Zero Acceleration x Data')
xlabel('Sample Number')
ylabel('Accelerometer Reading (mg)')
%xlim([0 10])
%ylim([-0.4 0.8])

figure

%plot y accel
plot(accelY,"-ob")
title('Zero Acceleration y Data')
xlabel('Sample Number')
ylabel('Accelerometer Reading (mg)')
%xlim([0 10])
%ylim([-0.4 0.8])

figure
%plot(accelZ)
plot(accelZ,"-vg")
title('Gravity Acceleration z Data')
xlabel('Sample Number')
ylabel('Accelerometer Reading (mg)')
%xlim([0 10])
%ylim([-0.4 0.8])

figure
%plot(accelZ0 0)
plot(accelZ0,"-^g")
title('Zero Acceleration z Data')
xlabel('Sample Number')
ylabel('Accelerometer Reading (mg)')
%xlim([0 10])
%ylim([-0.4 0.8])

%% all stats info
confLev = 0.95;

%% x0 accl stats
disp('x accl');
xbar = mean(accelX); % Arithmetic mean
S = std(accelX); % Standard Deviation
N = length(accelX); % Count
ESE = S/sqrt(N); % Estimated Standard Error
% tinv is for 1-tailed, for 2-tailed we need to halve the range
StdT = tinv((1-0.5*(1-confLev)),N-1); % The Student t value
lambda = StdT*ESE; % 1/2 of the confidence interval ąlambda
output = [num2str(xbar), ' +/- ', num2str(lambda), ' (', num2str(confLev), ')'];
disp(output)

%% y0 accl stats
disp('y accl');
xbar = mean(accelY); % Arithmetic mean
S = std(accelY); % Standard Deviation
N = length(accelY); % Count
ESE = S/sqrt(N); % Estimated Standard Error
% tinv is for 1-tailed, for 2-tailed we need to halve the range
StdT = tinv((1-0.5*(1-confLev)),N-1); % The Student t value
lambda = StdT*ESE; % 1/2 of the confidence interval ąlambda
output = [num2str(xbar), ' +/- ', num2str(lambda), ' (', num2str(confLev), ')'];
disp(output)

%% z accl stats
disp('z accl');
xbar = mean(accelZ); % Arithmetic mean
S = std(accelZ); % Standard Deviation
N = length(accelZ); % Count
ESE = S/sqrt(N); % Estimated Standard Error
% tinv is for 1-tailed, for 2-tailed we need to halve the range
StdT = tinv((1-0.5*(1-confLev)),N-1); % The Student t value
lambda = StdT*ESE; % 1/2 of the confidence interval ąlambda
output = ['mean=', num2str(xbar), ', Standard Deviation=', num2str(S), ', Estimated Standard Error=', num2str(ESE), ', final= ', num2str(xbar), ' +/- ', num2str(lambda), ' (', num2str(confLev), ')'];
disp(output)

%% z0 accl stats
disp('z0 accl');
xbar = mean(accelZ0); % Arithmetic mean
S = std(accelZ0); % Standard Deviation
N = length(accelZ0); % Count
ESE = S/sqrt(N); % Estimated Standard Error
% tinv is for 1-tailed, for 2-tailed we need to halve the range
StdT = tinv((1-0.5*(1-confLev)),N-1); % The Student t value
lambda = StdT*ESE; % 1/2 of the confidence interval ąlambda
output = [num2str(xbar), ' +/- ', num2str(lambda), ' (', num2str(confLev), ')'];
disp(output)

%------------------------------------------------------------------

%x-y
disp('x-y');
xydif  = accelX-accelY;
xbar = mean(xydif); % Arithmetic mean
S = std(xydif); % Standard Deviation
N = length(xydif); % Count
ESE = S/sqrt(N); % Estimated Standard Error
% tinv is for 1-tailed, for 2-tailed we need to halve the range
StdT = tinv((1-0.5*(1-confLev)),N-1); % The Student t value
lambda = StdT*ESE; % 1/2 of the confidence interval ąlambda
output = [num2str(xbar), ' +/- ', num2str(lambda), ' (', num2str(confLev), ')'];
disp(output)


%y-z0
disp('y-z');
yzdif  = accelY-accelZ0;
xbar = mean(yzdif); % Arithmetic mean
S = std(yzdif); % Standard Deviation
N = length(yzdif); % Count
ESE = S/sqrt(N); % Estimated Standard Error
% tinv is for 1-tailed, for 2-tailed we need to halve the range
StdT = tinv((1-0.5*(1-confLev)),N-1); % The Student t value
lambda = StdT*ESE; % 1/2 of the confidence interval ąlambda
output = [num2str(xbar), ' +/- ', num2str(lambda), ' (', num2str(confLev), ')'];
disp(output)

%x-z0
disp('x-z');
xzdif  = accelX-accelZ0;
xbar = mean(xzdif); % Arithmetic mean
S = std(xzdif); % Standard Deviation
N = length(xzdif); % Count
ESE = S/sqrt(N); % Estimated Standard Error
% tinv is for 1-tailed, for 2-tailed we need to halve the range
StdT = tinv((1-0.5*(1-confLev)),N-1); % The Student t value
lambda = StdT*ESE; % 1/2 of the confidence interval ąlambda
output = [num2str(xbar), ' +/- ', num2str(lambda), ' (', num2str(confLev), ')'];
disp(output)


% final tank room plot

%conversion

conversion = (mean(accelZ)-mean(accelZ0))/(1000*9.8);

figure
plot(accelX*conversion, '-squarer')
hold on
plot(accelY*conversion,"-ob")
plot(accelZ*conversion, "-^g")


title('Tank Room Acceleration Data')
xlabel('Sample Number')
ylabel('Accelerometer Reading (m/s^2)')
hold off
%xlim([0 10])
%ylim([-0.4 0.8])