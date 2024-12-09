% EE-442 Wireless Receivers : algorithms and architectures
% Final Project : OFDM Audio Transmission System
% Authors : Palmisano Fabio, Riber Rafael

function [txsignal conf] = tx(txbits,conf,k, training_symbols, preamble_bits)
% Digital  for OFDM
%
%   [txsignal conf] = tx(txbits,conf,k, training_symbols, preamble_bits)
%
%   txbits  : Information bits
%   conf    : Universal configuration structure
%   k       : Frame index
%   training_symbols : bits for training sequence
%   preamble_bits : bits for preamble generation

%% Generate the signal (as usual)
source = txbits;

if conf.scramble == 1
    %source = wlanScramble(txbits,conf.scramInit);
end

%% Add Data Symbols
mappedQPSK = reshape(source, 2, []).'; % Group bits into pairs
dec_symbol = bi2de(mappedQPSK, 'left-msb'); % Convert binary to decimal

%Mapping 
for j = 1:numel(dec_symbol)
       if dec_symbol(j) ==  0
           dec_symbol(j) = (-1 - 1i)/(sqrt(2));
       elseif dec_symbol(j)  == 1
           dec_symbol(j) = (-1 + 1i)/(sqrt(2));
       elseif dec_symbol(j) == 2 
           dec_symbol(j) = (1 - 1i)/(sqrt(2));
       else 
           dec_symbol(j) = (1 + 1i)/(sqrt(2));
       end
end 

qpsk_symbol = dec_symbol;

qpsk = reshape(qpsk_symbol, [conf.N, conf.nb_symbols]);

figure(2);
subplot(1,2,1);
plot(real(qpsk), imag(qpsk), 'o');
axis square;
title('Transmitted Constellation');
xlabel('Re');
ylabel('Im');

data = [];
for ii = 1:size(qpsk,2)
    OFDM_QPSK_symbol = osifft(qpsk(:,ii), conf.os_factor);
    OFDM_QPSK_symbol_cp = [OFDM_QPSK_symbol(end - conf.CP + 1:end); OFDM_QPSK_symbol];
    data = [data ; OFDM_QPSK_symbol_cp];
end
txsignal_data = data / rms(data);


%% Add Preamble
preamble_symbols = 1 - 2*preamble_bits; 
up_preamble = upsample(preamble_symbols,conf.os_factor); 
rrc_filter = rrc(conf.os_factor,conf.RollOff, conf.filter_len);

%% Convolving the upsampled sequence with the pulse shape filter
preamble = conv(up_preamble, rrc_filter.','same');
preamble = preamble / rms(preamble);


%% Add Training Symbols
training_ofdm_symbol = osifft(training_symbols, conf.os_factor); 
training_cp = [training_ofdm_symbol(end-conf.CP+1:end); training_ofdm_symbol];

txsignal_train = training_cp / rms(training_cp);
txsignal = [preamble ; txsignal_train ; txsignal_data];

%% Upconversion
t = 0:1/conf.f_s:(size(txsignal)-1)/conf.f_s;
tx_upconverted = cos(2*pi*conf.f_c*t').*real(txsignal)-sin(2*pi*conf.f_c*t').*imag(txsignal);

figure(3);
subplot(2,1,1);
plot(tx_upconverted);
xline(length(preamble), 'g', 'LineWidth', 3);
xline(length(preamble) + length(txsignal_train), 'b', 'LineWidth', 3);
title('Transmitted Signal');
xlabel('Sample Index');
ylabel('Amplitude');
legend('Signal','End of Preamble', 'End of Training')

txsignal = tx_upconverted;

