% EE-442 Wireless Receivers : algorithms and architectures
% Final Project : OFDM Audio Transmission System
% Authors : Palmisano Fabio, Riber Rafael

function [rxbits conf] = rx(rxsignal,conf,k, training_symbols, preamble_bits)
% Digital Receiver
%
%   [rxbits conf] = rx(rxsignal,conf,k, training_symbols, preamble_bits)
%
%   rxsignal    : received signal
%   conf        : configuration structure
%   k           : frame index
%   training_symbols : 
%   preamble_bits: 
%
%   Outputs
%
%   rxbits      : received bits
%   conf        : configuration structure
%
number_of_bits = conf.N * conf.os_factor + conf.CP;
%% Downconversion
t = 0:1/conf.f_s:(length(rxsignal)-1)/conf.f_s;
rx_downconverted = rxsignal .* (cos(2*pi*conf.f_c*t') - 1i*sin(2*pi*conf.f_c*t'));

%% Low-pass Filter
f_cut_off = 2.5.*ceil((conf.N+1)/2).*conf.Fspacing;
rx_baseband = ofdmlowpass(rx_downconverted, conf, f_cut_off);

%% Frame Sync
rrc_filter = rrc(conf.os_factor,conf.RollOff, conf.filter_len);
preamble_filt = conv(rx_baseband, rrc_filter.', 'same');
idx = frame_sync(preamble_filt, conf.os_factor, preamble_bits, conf);
disp("index of beginning "+idx);
rx_no_preamble = rx_baseband(idx:idx + ((conf.nb_symbols+1)*number_of_bits)-1);

figure(3);
subplot(2,1,2); 
plot(rxsignal);
title('Received Signal');
xlabel('Sample Index');
ylabel('Amplitude');
xline(idx,'g', 'LineWidth', 3);
legend('Signal', 'End of preamble')

%% Channel Estimation and decoding

training_signal = rx_no_preamble(1:number_of_bits);                % Get training signal
training_signal_no_cp = training_signal(conf.CP+1:end, :);         % Remove CP
training_symbols_rx = osfft(training_signal_no_cp,conf.os_factor); % Perform OSFFT

rx_symbols = zeros([conf.N*conf.nb_symbols 1]);
filtered_rx_signal = rx_no_preamble(number_of_bits+1:end);

%Block Estimation
if strcmp(conf.estimation,'block')
    h = training_symbols_rx ./ training_symbols; % Compute channel transfer function
    theta_hat    = mod(angle(h), 2*pi);

    figure(4);
    subplot(2,1,1);
    plot(abs(h))
    xlabel("Subcarrier index")
    ylabel("Magnitude")
    title("Magnitude of H")
    figure(4);
    subplot(2,1,2);
    plot(theta_hat)
    ylabel("Subcarrier angle [rad]")
    xlabel("Subcarrier index")
    title("Phase of H")


    cir = ifft(h);
    cir_mag = abs(cir);
    
    cir_thresh = conf.CIR_Threshold;
    cir_length = length(find(cir_mag > cir_thresh));
    disp(['Length of the Channel Impulse Response: ', num2str(cir_length), ' taps']);

    cir_dB = 20*log10(abs(ifftshift(cir)));
    threshold_dB = 20*log10(cir_thresh);
    significant_taps_indices = find(cir_dB > threshold_dB);

    figure;
    plot(cir_dB, '.', 'Color', [0.5 0.5 0.5]); % Grey color for all taps
    hold on;
    plot(significant_taps_indices, cir_dB(significant_taps_indices), 'r.');
    yline(threshold_dB, 'b--', 'LineWidth', 1.5);
    xlabel("Taps");
    ylabel("Amplitude [dB]");
    title("IFFT of CIR with Significant Taps and Threshold");
    legend('All Taps', 'Significant Taps', 'Threshold');

    for ll = 1:conf.nb_symbols
        filtered_rx = filtered_rx_signal((ll-1)*number_of_bits+1:(ll)*number_of_bits);
        rx_signal_no_cp = filtered_rx(conf.CP+1:end, :);
        rx = osfft(rx_signal_no_cp,conf.os_factor);
        rx_symbols((ll-1)*conf.N+1:ll*conf.N) = rx ./ abs(h); % Amplitude correction
        rx_symbols((ll-1)*conf.N+1:ll*conf.N) = rx_symbols((ll-1)*conf.N+1:ll*conf.N) .* exp(-1i*theta_hat); % Phase correction
    end

%Viterbi Estimation
elseif strcmp(conf.estimation,'viterbi')
    h = training_symbols_rx ./ training_symbols; % Compute channel transfer function
    filtered_rx_signal = rx_no_preamble(number_of_bits+1:end);
    rx_symbols = zeros([conf.N*conf.nb_symbols 1]);
    theta_hat = angle(h);

    figure(4);
    subplot(2,1,1);
    plot(abs(h))
    xlabel("Subcarrier index")
    ylabel("Magnitude")
    title("Magnitude of H")
    figure(4);
    subplot(2,1,2);
    plot(theta_hat)
    ylabel("Subcarrier angle [rad]")
    xlabel("Subcarrier index")
    title("Phase of H")

    cir = ifft(h);
    cir_mag = abs(cir);
    cir_thresh = conf.CIR_Threshold;
    cir_length = length(find(cir_mag > cir_thresh));
    disp(['Length of the Channel Impulse Response: ', num2str(cir_length), ' taps']);

    cir_dB = 20*log10(abs(ifftshift(cir)));
    threshold_dB = 20*log10(cir_thresh);
    significant_taps_indices = find(cir_dB > threshold_dB);

    figure;
    plot(cir_dB, '.', 'Color', [0.5 0.5 0.5]); % Grey color for all taps
    hold on;
    plot(significant_taps_indices, cir_dB(significant_taps_indices), 'r.');
    yline(threshold_dB, 'b--', 'LineWidth', 1.5);
    xlabel("Taps");
    ylabel("Amplitude [dB]");
    title("Channel Impulse Response with Significant Taps and Threshold");
    legend('All Taps', 'Significant Taps', 'Threshold');


    for ll = 1:conf.nb_symbols
        % Extract the current symbol
        filtered_rx = filtered_rx_signal((ll-1)*number_of_bits+1:(ll)*number_of_bits);
        rx_signal_no_cp = filtered_rx(conf.CP+1:end, :);
        rx = osfft(rx_signal_no_cp, conf.os_factor);

        % % Calculate the phase difference
        % if ll > 1
            deltaTheta = (1/4)*angle(-rx.^4) + pi/2*(-1:4);
            [~, ind] = min(abs(deltaTheta - theta_hat), [], 2);
            indvec = (0:conf.N-1).*6 + ind';
            deltaTheta = deltaTheta';
            theta = deltaTheta(indvec);
            a = 0.01;
            b = 0.99;
            theta_hat = mod(a*theta' + b*theta_hat, 2*pi);
        %end

        % Apply channel correction
        rx_symbols((ll-1)*conf.N+1:ll*conf.N) = rx ./ abs(h); 
        rx_symbols((ll-1)*conf.N+1:ll*conf.N) = rx_symbols((ll-1)*conf.N+1:ll*conf.N) .* exp(-1i*theta_hat); % Phase correction
    end
end

%% Demapping Symbols to Bits
rxbits = [real(rx_symbols) >= 0, imag(rx_symbols) >= 0];
rxbits = reshape(rxbits.', [numel(rxbits), 1]);
rxbits = double(rxbits);

if conf.scramble == 1
    rxbits = wlanScramble(rxbits,conf.scramInit);
end
% Plot the constellation
figure(2);
subplot(1,2,2);
plot(real(rx_symbols), imag(rx_symbols), 'o');
axis square;
xlabel('Re');
ylabel('Im');
title('Final Constellation');

end