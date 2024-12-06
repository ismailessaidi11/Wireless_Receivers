function [txsignal conf] = tx(txbits,conf,k)
% Digital Transmitter
%
%   [txsignal conf] = tx(txbits,conf,k) implements a complete transmitter
%   consisting of:
%       - modulator
%       - pulse shaping filter
%       - up converter
%   in digital domain.
%
%   txbits  : Information bits
%   conf    : Universal configuration structure
%   k       : Frame index
%

txbits = reshape(txbits, [], 2);
QPSK_Map = 1/sqrt(2) * [(-1-1j) (-1+1j) ( 1-1j) ( 1+1j)];
symbols = QPSK_Map(bi2de(txbits, 'left-msb')+1).';

% pulse shaping
pulse = rrc(1, conf.rolloff, conf.tx_filterlen); % change to os_factor if needed instead of 1
tx_baseband = conv(symbols,pulse.','full');


% upconverting
t = (0:length(tx_baseband)-1) / conf.f_s;
%t = 0:1/conf.f_s:(size(tx_baseband)-1)/conf.f_s;
txsignal = cos(2*pi*conf.f_c*t').*real(tx_baseband)-sin(2*pi*conf.f_c*t').*imag(tx_baseband);

% dummy 400Hz sinus generation
%time = 1:1/conf.f_s:4;
%txsignal = 0.3*sin(2*pi*400 * time.');