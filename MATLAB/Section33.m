%% Section 3.3 

clear;
close all;
clc;

data = readmatrix( 'teensy_data.csv');
% replace with our file name
sample_nums = data( : ,1);
uV = data(:,2);
depth = data(:,3)
depth_des = data(:,4)

% time = [0 99 2*99 3*99 4*99 5*99]
mult = 0;
time = [];
for i = 1:length(sample_nums)
	time(i) = 99*mult;
mult = mult+1;
end

figure ; hold on; grid on;
plot(time, depth, '-bo', 'DisplayName','depth');
plot(time, depth_des, '--bx', 'DisplayName','depth desired');
xlabel('time (t)');
ylabel('depth and depth desired');
title('time vs depth and depth desired');
legend('Location','best');

figure ; hold on; grid on;
plot(time, uV, '--gx', 'DisplayName','uV')
xlabel('time (t)');
ylabel('uV');
title('time vs uV');
legend('Location','best');

