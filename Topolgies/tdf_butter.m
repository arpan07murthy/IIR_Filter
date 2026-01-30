% Parameters
Fs = 1000;    % Sampling frequency in Hz
Fc = 100;     % Cutoff frequency in Hz
order = 4;    % Filter order (example 4th order for cascading 2 biquads)

% Design Butterworth filter (floating-point coefficients)
[b, a] = butter(order, Fc/(Fs/2));

% Convert overall filter to second-order sections (biquads)
[sos, g] = tf2sos(b, a);

disp('Second-order section coefficients (b0, b1, b2, a0=1, a1, a2):');
disp(sos);

% Fixed-point scaling factor for Q1.15 format
Q = 15;

% Convert each biquad's coefficients to fixed-point
for i = 1:size(sos,1)
    b0_fixed(i) = round(sos(i,1)*2^Q);
    b1_fixed(i) = round(sos(i,2)*2^Q);
    b2_fixed(i) = round(sos(i,3)*2^Q);
    a1_fixed(i) = round(sos(i,5)*2^Q);
    a2_fixed(i) = round(sos(i,6)*2^Q);
end

% Display fixed-point coefficients ready for Verilog input
disp('Fixed-point coefficients (Q1.15) for each biquad stage:');
for i = 1:size(sos,1)
    fprintf('Stage %d: b0 = %d, b1 = %d, b2 = %d, a1 = %d, a2 = %d\n', ...
        i, b0_fixed(i), b1_fixed(i), b2_fixed(i), a1_fixed(i), a2_fixed(i));
end

% Generate test input: 50 Hz sine wave, scaled to -1 to 1 range
t = (0:99)/Fs; % 100 samples
x = 0.5*sin(2*pi*50*t);

% Filter test input in MATLAB (floating-point, reference output)
y = filter(b, a, x);

% Plot input and output
figure;
subplot(2,1,1);
plot(t, x);
title('MATLAB Input Signal (Floating Point)');
xlabel('Time (s)');
ylabel('Amplitude');

subplot(2,1,2);
plot(t, y);
title('MATLAB Butterworth Filter Output (Floating Point)');
xlabel('Time (s)');
ylabel('Amplitude');
