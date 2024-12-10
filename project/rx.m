function [rxbits conf] = rx(rxsignal,conf,k)
% Digital Receiver
%
%   [txsignal conf] = tx(txbits,conf,k) implements a complete causal
%   receiver in digital domain.
%
%   rxsignal    : received signal
%   conf        : configuration structure
%   k           : frame index
%
%   Outputs
%
%   rxbits      : received bits
%   conf        : configuration structure
%


% Downconversion
Ts = 1/conf.f_s;
t = 0:Ts:(length(rxsignal)-1)*Ts;
rx_downconverted = rxsignal .* exp(-2i*pi*conf.f_c*t.');

% Low-pass Filter
rx_baseband = 2*lowpass(rx_downconverted,conf);

% Matched filter
matched_filter = rrc(conf.os_factor, conf.rolloff, conf.rx_filterlen); 
filtered_rxsignal = conv(rx_baseband,matched_filter,'same');

% frame synch 
[idx, phase_of_peak, magnitude_of_peak] = frame_sync(filtered_rxsignal, conf);

% channel estimation and correction
corrected_rxsignal = channel_correction(filtered_rxsignal, phase_of_peak, magnitude_of_peak);

% downsampling
downsampled_rxsignal = corrected_rxsignal(1+idx : conf.os_factor : idx+conf.os_factor*conf.nsyms-1);

% phase correction
phase_corrected_rxsignal = viterbi_viterbi(downsampled_rxsignal);

% plot_constellation(downsampled_rxsignal,  'rx constellation');

% demapping
rxbits = QPSK_demapper(phase_corrected_rxsignal);

% dummy 
%rxbits = zeros(conf.nbits,1);