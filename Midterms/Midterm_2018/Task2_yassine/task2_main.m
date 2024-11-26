% Task 2.3: simulate with time-synch using the oversampling and a different roll-off factor

clear; clc;

% SNR range to simulate
SNRdB = 0:2:24;


% Load the bits 
load ber_pn_seq
len = 1000000;

% Load the three rx signals for the three different oversampling factors
load rx_2x.mat rx1
load rx_4x.mat rx2
load rx_8x.mat rx3

% Oversampling factors for the receivers
L = [2 4 8];

% Filter length based on maximum oversampling factor
rx_filterlen = 6 * max(L);

% Initialize BER for both roll-off factors
BER_011 = zeros(length(SNRdB), length(L));
BER_090 = zeros(length(SNRdB), length(L));

% Preamble (for Task 2.6 if needed later)
preamble_length = 100;
preamble = 1 - 2 * lfsr_framesync(preamble_length);

% String for plot legend
legendString = cell(length(L) * 2, 1);

% Define both roll-off factors
rolloff_factors = [0.11, 0.9];

% Loop over roll-off factors
for rf_idx = 1:length(rolloff_factors)
    rolloff_factor = rolloff_factors(rf_idx);
    
    % Loop over oversampling factors
    for kk = 1:length(L)
        if kk == 1
            rx = rx1;
            %p0 = 0;
        elseif kk == 2
            rx = rx2;
            %p0 = 1;
        elseif kk == 3
            rx = rx3;
            %p0 = 1;
        end
        
        % Loop over SNR values
        for ii = 1:length(SNRdB)
            
            % Calculate noise variance
            sigma_2 = 1 / 10^(SNRdB(ii) / 10);
            
            % Create noise
            w = sqrt(sigma_2 / 2) * (randn(size(rx)) + 1j * randn(size(rx)));
            
            % Transmit over AWGN channel
            y = rx + w;
            
            % Matched Filter
            pulse_rx = rrc(L(kk), rolloff_factor, rx_filterlen);
            rx_mf = conv(y, pulse_rx.', 'same');

            p0=estimate_p0(rx_mf, L(kk), preamble)
            fprintf('Estimated p0 for L = %d is %d\n', L(kk), p0);
            % Remove preamble and decimate
            data = rx_mf(p0 + length(preamble) * L(kk) + 1 : L(kk) : end);
            
            % Demap
            b_hat = demapper(data); 
            
            % Calculate BER
            if rf_idx == 1
                BER_011(ii, kk) = mean(b_hat(1:length(ber_pn_seq)) ~= ber_pn_seq);
            else
                BER_090(ii, kk) = mean(b_hat(1:length(ber_pn_seq)) ~= ber_pn_seq);
            end
            
        end
        
        % Set legend strings for plot
        if rf_idx == 1
            legendString{kk} = sprintf('L = %d, Roll-off = 0.11', L(kk));
        else
            legendString{kk + length(L)} = sprintf('L = %d, Roll-off = 0.9', L(kk));
        end
        
    end
end

% Plot the BER results for comparison
figure;
hold on;
% Plot for roll-off factor 0.11
for kk = 1:length(L)
    semilogy(SNRdB, BER_011(:, kk), '-o', 'DisplayName', legendString{kk});
end

% Plot for roll-off factor 0.9
for kk = 1:length(L)
    semilogy(SNRdB, BER_090(:, kk), '--x', 'DisplayName', legendString{kk + length(L)});
end
hold off;

xlabel('SNR (dB)');
ylabel('BER');
title('BER vs SNR for Different Oversampling Factors and Roll-off Factors');
legend show;
grid on;




