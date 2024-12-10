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
t = (0:length(rxsignal)-1) / conf.f_s;
rx_downconverted = rxsignal .* exp(-2i*pi*conf.f_c*t');

% Phase correction because we noticed rotation !!!!!!!!
%phase_offset = mean(angle(rx_downconverted));
%rx_downconverted = rx_downconverted .* exp(-1i * phase_offset);


% Low-pass Filter
rx_baseband = 2*lowpass(rx_downconverted,conf);

% Matched filter
matched_filter = rrc(conf.os_factor, conf.rolloff, conf.rx_filterlen); % change to os_factor if needed instead of 1
filtered_rxsignal = conv(rx_baseband,matched_filter.','full');

% frame synch and remove padding due to filtering
idx = frame_sync(filtered_rxsignal, conf);
downsampled_rxsignal = filtered_rxsignal(1+idx+conf.tx_filterlen+conf.rx_filterlen : conf.os_factor : idx+conf.os_factor*conf.nsyms);

%downsampled_rxsignal = rx_baseband(1+conf.tx_filterlen+conf.rx_filterlen : end-conf.rx_filterlen-conf.tx_filterlen);
plot_constellation(downsampled_rxsignal,  'rx constellation');

% demapping
rxbits = QPSK_demapper(downsampled_rxsignal);


% dummy 
%rxbits = zeros(conf.nbits,1);