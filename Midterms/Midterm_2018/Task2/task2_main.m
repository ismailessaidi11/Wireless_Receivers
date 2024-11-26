% Task 2: simulate with time-synch using the oversampling 

clear; clc;


% SNR range to simulate
SNRdB = 0:2:24;

% Load the bits 
load ber_pn_seq
len = 1000000;
% Oversampling factors for the receivers
L = [2 4 8];
% Filterlength
Ltx = 2;
rx_filterlen  = 6* Ltx;

% Load the three rx signals for the three different oversampling factors (The are already modulated to QPSK symbols, pulse shaped and mis-synchronized)
load rx_2x.mat rx1
load rx_4x.mat rx2
load rx_8x.mat rx3



% Roll-off factor
rolloff_factor1 = 0.11;
rolloff_factor2 = 0.9;

% Preamble      %  YOU WILL NEED IT FOR TASK 2.6
preamble_length = 100;
preamble = 1 - 2*lfsr_framesync(preamble_length);

% Initialize bit error rate
BER = zeros(length(SNRdB),length(L));

% String for plot legend
legendString = cell(length(L),1);

for kk = 1:length(L)
   
    if kk==1
        rx = rx1;
    elseif kk==2
        rx = rx2;
    elseif kk==3
        rx = rx3;
    end

    
    for ii = 1:length(SNRdB)
        
        % Calculate noise variance
        sigma_2 = 1/10^(SNRdB(ii)/10);
                      
        % Create noise
        w = sqrt(sigma_2/2)*(randn(size(rx)) + 1j*randn(size(rx)));
        
        % Transmit over AWGN channel
        y = rx + w;
        
        % Matched Filter
        pulse_rx1 = rrc(L(kk), rolloff_factor1, rx_filterlen);
        pulse_rx2 = rrc(L(kk), rolloff_factor2, rx_filterlen);

        rx_mf1 = conv(y, pulse_rx1.', "full");               % TO BE COMPLETED
        rx_mf2 = conv(y, pulse_rx2.', "full");               % TO BE COMPLETED

        % For Task 2.1 and Task 2.3 get the p0 value from the genie 
        % For Task 2.6 write your function that finds p0 using the preamble
        p0 = [0 1 1];                  % TO BE COMPLETED
        
        % Remove preamble and Decimate
        data = rx_mf1(1 + L(kk)*preamble_length+rx_filterlen + p0(kk) : L(kk) : end - rx_filterlen);                % TO BE COMPLETED
        data = rx_mf1(1 + L(kk)*preamble_length+rx_filterlen + p0(kk) : L(kk) : end - rx_filterlen);                % TO BE COMPLETED

        % Demap
        b_hat = demapper(data);               % TO BE COMPLETED
        
        % Calculate BER
        BER(ii,kk) = mean(b_hat(:)~=ber_pn_seq(:));          % TO BE COMPLETED
        
    end
    legendString{kk} = sprintf('L = %d', L(kk));
    
end

% Plot results
figure;
hold on;
semilogy(SNRdB, BER(:,1), '-o', 'LineWidth', 1.5);
semilogy(SNRdB, BER(:,2), '-s', 'LineWidth', 1.5);
semilogy(SNRdB, BER(:,3), '-d', 'LineWidth', 1.5);
set(gca, 'YScale', 'log');  % Ensure Y-axis is in logarithmic scale
grid on;
xlabel('SNR (dB)');
ylabel('Bit Error Rate (BER)');
title('BER vs SNR for Different Oversampling Factors');
legend(legendString, 'Location', 'SouthWest');

hold off;