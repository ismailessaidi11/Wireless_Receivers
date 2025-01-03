load('image.mat');
SNR = 5;
[bit_out, noisy_signal] = awgn_channel(signal, image_size, SNR);

% Plot received signals 
figure
plot(noisy_signal, '.');