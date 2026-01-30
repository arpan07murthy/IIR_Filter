% Load and parse Verilog console output file (e.g., 'verilog_log.txt')
% The file should contain lines like:
% Input           0:      0, Output:      0
% Input           1:   5062, Output:      0
% ...

filename = 'verilog_log.txt';  % change filename as needed
fileID = fopen(filename, 'r');

verilog_outputs_fixed = [];
line = fgetl(fileID);

while ischar(line)
    % Extract the Output integer using regexp
    tokens = regexp(line, 'Output:\s*(-?\d+)', 'tokens');
    if ~isempty(tokens)
        val = str2double(tokens{1}{1});
        verilog_outputs_fixed(end+1) = val; %#ok<AGROW>
    end
    line = fgetl(fileID);
end

fclose(fileID);

% Convert fixed-point to floating-point (Q1.15 assumed)
verilog_outputs_float = verilog_outputs_fixed / 2^15;
Fs = 1000;
t = (0:99)/Fs;
x = 0.5*sin(2*pi*50*t);

b = [0.06745527 0.13491055 0.06745527];
a = [1 -1.1429805 0.4128016];

y_stage1 = filter(b, a, x);
y_out = filter(b, a, y_stage1);

plot(t, x, 'b', t, y_out, 'r');
legend('Input', 'Filtered Output');
title('MATLAB IIR Filter Output');

% Load and parse Verilog console output file (e.g., 'verilog_log.txt')
% The file should contain lines like:
% Input           0:      0, Output:      0
% Input           1:   5062, Output:      0
% ...

filename = 'verilog_log.txt';  % change filename as needed
fileID = fopen(filename, 'r');

verilog_outputs_fixed = [];
line = fgetl(fileID);

while ischar(line)
    % Extract the Output integer using regexp
    tokens = regexp(line, 'Output:\s*(-?\d+)', 'tokens');
    if ~isempty(tokens)
        val = str2double(tokens{1}{1});
        verilog_outputs_fixed(end+1) = val; %#ok<AGROW>
    end
    line = fgetl(fileID);
end

fclose(fileID);

% Convert fixed-point to floating-point (Q1.15 assumed)
verilog_outputs_float = verilog_outputs_fixed / 2^15;

% Now plot and compare with MATLAB y_out
% Assume y_out is already loaded in workspace (from filter output)
Fs = 1000; % sampling frequency
t1 = (0:length(verilog_outputs_float)-1)/Fs;

plot(t1, y_out, 'b-', t1, verilog_outputs_float, 'r--');
legend('MATLAB Output', 'Verilog Output');
title('Filter Output Comparison');
xlabel('Time (s)');
ylabel('Amplitude');

% Compute error metrics
error = y_out(1:length(verilog_outputs_float)) - verilog_outputs_float';
max_error = max(abs(error));
fprintf('Maximum absolute error between MATLAB and Verilog outputs: %g\n', max_error);
