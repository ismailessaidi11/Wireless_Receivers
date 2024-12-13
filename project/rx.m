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
h = magnitude_of_peak*exp(1j*phase_of_peak);
corrected_rxsignal = conj(h)/norm(h)^2*filtered_rxsignal;

downsampled_rxsignal = corrected_rxsignal(1+idx : conf.os_factor : idx+conf.os_factor*conf.nsyms-1);

theta_hat = zeros(length(downsampled_rxsignal)+1, 1);
% Phase estimation
for k = 1 : length(downsampled_rxsignal)
    % Apply viterbi-viterbi algorithm
    deltaTheta = 1/4*angle(-downsampled_rxsignal(k)^4) + pi/2*(-1:4);
    
    % Unroll phase
    [~, ind] = min(abs(deltaTheta - theta_hat(k)));
    theta = deltaTheta(ind);
    theta_hat(k+1) = mod(0.01*theta + 0.99*theta_hat(k), 2*pi);     % Lowpass filter phase
    
    % Phase correction
    downsampled_rxsignal(k) = downsampled_rxsignal(k) * exp(-1j * theta_hat(k+1));

end

plot_constellation(downsampled_rxsignal,  'rx constellation');

% demapping
rxbits = QPSK_demapper(downsampled_rxsignal);

% dummy 
%rxbits = zeros(conf.nbits,1);