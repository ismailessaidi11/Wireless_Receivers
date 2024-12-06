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
if strcmp(conf.audiosystem,'bypass') % remove the 0 padding at start and end
    rxsignal = rxsignal(1+length(zeros(conf.f_s,1)):end - length(zeros(conf.f_s,1)));
end
% Downconversion
%t = 0:1/conf.f_s:(size(rxsignal)-1)/conf.f_s;
t = (0:length(rxsignal)-1) / conf.f_s;

rx_downconverted = rxsignal .* (cos(2*pi*conf.f_c*t') - 1i*sin(2*pi*conf.f_c*t'));

% Low-pass Filter
rx_baseband = lowpass(rx_downconverted,conf);

% Matched filter
pulse = rrc(1, conf.rolloff, conf.rx_filterlen); % change to os_factor if needed instead of 1
filtered_rxsignal = conv(rx_baseband,pulse.','full');

% remove padding due to filtering
downsampled_rxsignal = filtered_rxsignal(1+conf.tx_filterlen+conf.rx_filterlen:end-conf.tx_filterlen-conf.rx_filterlen);

% demapping
rxbits = QPSK_demapper(downsampled_rxsignal);


% dummy 
%rxbits = zeros(conf.nbits,1);