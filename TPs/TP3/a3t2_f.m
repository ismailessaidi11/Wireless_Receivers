function [symbol_up, filtered_tx_signal, filtered_rx_signal, sampled_signal, demapped_bits, BER] = a3t2_f(rx_filterlen)
    SNR = 8; % dB
    tx_filterlen = 20; % tx_filterlen > rx_filterlen
    os_factor           = 4;
    
    len  = 1e6;
    % Generate random bitstream
    bitstream = randi([0 1],1,len);
    
    % Convert to QPSK symbols
    bits = 2 * (bitstream - 0.5);
    bits2 = reshape(bits, 2, []);
    
    real_p = ((bits2(1,:) > 0)-0.5)*sqrt(2);
    imag_p = ((bits2(2,:) > 0)-0.5)*sqrt(2);

    symbol = real_p + 1i*imag_p;
    
    % up-sample symbol to signal
    symbol_up = ...
    
    % base-band pulse shaping
    rolloff = 0.22;
    pulse = ...

    % Shape the symbol diracs with pulse
    filtered_tx_signal = ...
    
    % convert SNR from dB to linear
    SNRlin = 10^(SNR/10);
    
    % add AWGN
    rx_signal = filtered_tx_signal + sqrt(1/(2*SNRlin)) * (randn(size(filtered_tx_signal)) + 1i*randn(size(filtered_tx_signal))); 
    
    % base-band pulse shaping
    rolloff = 0.22;
    pulse = ...
    
    % filtering
    filtered_rx_signal = ...
    
    % downsampling
    sampled_signal = ...
    
    % decode bits
    demapped_bits = demapper(sampled_signal);
    
    % calculate BER
    BER = sum(bitstream ~= demapped_bits.')/len;
end