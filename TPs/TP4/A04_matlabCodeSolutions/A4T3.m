
rng(32)
% Set parameters
os_factor = 4;
SNR  = 5;

load ber_pn_seq
load pn_sequence

data_length = length(ber_pn_seq)/2; % Number of QPSK data symbols

% convert SNR from dB to linear
SNRlin = 10^(SNR/10);

% add awgn channel
rx_signal = signal + sqrt(1/(2*SNRlin)) * (randn(size(signal)) + 1i*randn(size(signal)) );

% Matched filter
filtered_rx_signal = matched_filter(rx_signal, os_factor, 6);

% Frame synchronization
data_idx = frame_sync(filtered_rx_signal, os_factor); % Index of the first data symbol

data = zeros(1,data_length);
data2 = zeros(1,data_length);

cum_err = 0;
diff_err = zeros(1,data_length);
epsilon  = zeros(1,data_length);

frame_sync_length = 100;

% Use preamble symbols to improve timing offset estimation (Task 3)
for ii = -frame_sync_length:-1
    
    idx_start  = data_idx+ii*os_factor;
     
    idx_range  = idx_start:idx_start+os_factor-1;
    segment    = filtered_rx_signal(idx_range);
    
    % Estimate timing error epsilon
    pwr         = abs(segment).^2;
    diff_err = [1 -1j -1 1j]*pwr;
    cum_err     = cum_err + diff_err;
end

for ii=1:data_length
    
     idx_start  = data_idx+(ii-1)*os_factor;
     
     idx_range  = idx_start:idx_start+os_factor-1;
     segment    = filtered_rx_signal(idx_range);
    
     % Estimate timing error epsilon
     [epsilon_tmp, cum_err] = epsilon_estimation_solution(segment, cum_err);
     epsilon(ii) = epsilon_tmp;
     
     y_hat = linear_interpolation_solution(epsilon(ii), filtered_rx_signal, os_factor, idx_start);
     data(ii) = y_hat;   

end

BER_lin = mean(demapper(data) ~= ber_pn_seq)

% Plot epsilon
% figure;
plot( epsilon(1:500))

