%---------------------------------------

%size of teensy unit

%assume teensy_output(2) is at reading at peak
	%vin is reading on oscilloscope that matches same point on teensy (aka the peak)


disp(teensy_output(339,1))

one_teensy_unit = 0.9/(teensy_output(339,1))



%explanation: we know that at the peak the actual voltage is 0.9V (0.5V with 0.4V offset), so whatever the teensy reads 
%is teensy per 0.9 volts so conversion is volts/teensy units which can be multiplied by teensy to 

%one_teensy_unit = (0.4V+Vin)/(teensy_output(2)) %checked



%sample rate 
time_one_period = 1/175; %(200 is frequency in hz)
sample_length_one_period = 1924-746; %input from plot
sample_rate = sample_length_one_period/time_one_period 
