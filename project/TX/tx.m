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


txbits = reshape(txbits, length(txbits)/conf.modulation_order, conf.modulation_order);

% Mapping QPSK
QPSK_Map = (1/sqrt(2)) * [(-1-1j) (-1+1j) ( 1-1j) ( 1+1j)];
symbols_nopreamble = QPSK_Map(bi2de(txbits, 'left-msb')+1).';

% Add preamble to signal 
preamble = preamble_generate(conf.npreamble);
symbols = [preamble ; symbols_nopreamble];

% upsampling 
symbol_up = upsample(symbols, conf.os_factor);

% pulse shaping
pulse = rrc(conf.os_factor, conf.rolloff, conf.tx_filterlen);
tx_baseband = conv(symbol_up,pulse,'same');
tx_baseband_norm = normalize(tx_baseband); % normalize

% upconverting
Ts = 1/conf.f_s;
t = 0:Ts:(length(tx_baseband_norm)-1)*Ts;
txsignal =  real(tx_baseband_norm.* exp(2i*pi*conf.f_c*t.'));


figure(3);
subplot(2,1,1);
plot(txsignal);
xline(length(preamble)*conf.os_factor, 'g', 'LineWidth', 3);
title('Transmitted Signal');
xlabel('Sample Index');
ylabel('Amplitude');
legend('Signal', 'End of Preamble')

% dummy 400Hz sinus generation
%time = 1:1/conf.f_s:4;
%txsignal = 0.3*sin(2*pi*400 * time.');