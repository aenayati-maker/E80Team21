% matlablogging

% reads from Teensy data stream
function teensyanalog=matlablogging2(length)
   length = 5000;  % 5000 is hardcoded buffer size on Teensy
   s = serial('COM3','BaudRate',115200);
   set(s,'InputBufferSize',2*length)
   fopen(s);
   fprintf(s,'%d',2*length)         % Send length to Teensy
   dat = fread(s,2*length,'uint8');     
   fclose(s);
   teensyanalog = uint8(dat);
   teensyanalog = typecast(teensyanalog,'uint16');
end

%read vector
teensy_output = double(matlablogging2(5000))

sample_nums = 1:length(teensy_output);

%---------------------------------------
%str = fscanf(s);
%teensyanalog = str2num(str);
%[teensyanalog, count] = fscanf(s,['%d']);
%---------------------------------------

%---------------------------------------

%plot teensy data
plot(sample_nums,teensy_output)
title('Teensy Data')
xlabel('Sample Number')
ylabel('Teensy Output (TU)')

%---------------------------------------
