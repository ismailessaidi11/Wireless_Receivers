function [txsignal conf] = tx_ofdm(txbits,conf,k)
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

% - no more pulse shaping to the sympbols
% - pulse shaping for bpsk preamble
% - osifft instead of upsampling
% -
%

txbits = reshape(txbits, length(txbits)/conf.modulation_order, conf.modulation_order);

% Mapping QPSK
QPSK_Map = (1/sqrt(2)) * [(-1-1j) (-1+1j) ( 1-1j) ( 1+1j)];
QPSK_symbols = QPSK_Map(bi2de(txbits, 'left-msb')+1).';

% S/P 
Ns = length(QPSK_symbols);
remainder = mod(Ns, conf.N);    % Add Padding if necessary
if remainder ~= 0
    padding_len = conf.N - remainder;        
    padding_bits = randi([0 1],padding_len,1); % Random bits for padding
    padding_symbols = QPSK_Map(bi2de(padding_bits, 'left-msb')+1).';
    QPSK_symbols(end+1:end+padding_len) = padding_symbols; 
end
conf.num_ofdm_symbols = length(QPSK_symbols)/conf.N;
p_QPSK_symbols = reshape(QPSK_symbols, conf.N, length(QPSK_symbols)/conf.N);

% osifft
for i = 1:conf.num_ofdm_symbols
    ofdm_symbol = osifft(p_QPSK_symbols(:,i), conf.os_factor);
    cp = ofdm_symbol(end-round(conf.CP*conf.os_factor)+1 : end);    % Add CP
    p_ofdm_symbols(:,i) = [cp ; ofdm_symbol];
end
conf.len_ofdm_cp = length(cp);
conf.len_ofdm_symbol = length(ofdm_symbol);

% P/S conversion: concatenate columns into a single serial stream
s_ofdm_symbols = p_ofdm_symbols(:);
s_ofdm_symbols = normalize(s_ofdm_symbols); % normalize

% Add preamble to signal 
preamble = preamble_generate(conf.npreamble);
preamble = upsample(preamble, conf.os_factor_preamble);
pulse = rrc(conf.os_factor_preamble, conf.rolloff, conf.tx_filterlen);
preamble = conv(preamble,pulse,'same');
preamble = normalize(preamble); % normalize

conf.len_os_preamble = length(preamble); % save length of preamble

% Add training symbols
train_bits =  randi([0 1],conf.N,1); % length N: equivalent to 1 ofdm symbol
conf.train_symbols = 2*train_bits - 1; % convert to BPSK
train_ofdm_symbols = osifft(conf.train_symbols, conf.os_factor);
train_cp = train_ofdm_symbols(end-round(conf.CP*conf.os_factor)+1 : end); % Add CP
train_ofdm_symbols = [train_cp  ; train_ofdm_symbols];
train_ofdm_symbols = normalize(train_ofdm_symbols); %normalize

conf.len_train_data = length(train_ofdm_symbols); % save length of train odfm symbol
conf.len_cp_train = length(train_cp);

% Assemble frame
frame = [preamble ; train_ofdm_symbols ; s_ofdm_symbols];

%frame = normalize(frame); % normalize

% upconverting
Ts = 1/conf.f_s;
t = 0:Ts:(length(frame)-1)*Ts;
if strcmp(conf.audiosystem,'matlab')
    %txsignal = real(frame.* exp(2i*pi*(conf.f_c/conf.f_s)*t.')); % divide by f_s due to DAC of the Speaker
    txsignal = real(frame.* exp(2i*pi*(conf.f_c)*t.')); % WE SHHOULDN't divide by f_s

elseif strcmp(conf.audiosystem,'bypass')
    txsignal = real(frame.* exp(2i*pi*(conf.f_c)*t.'));
end


figure(3);
subplot(2,1,1);
plot(txsignal);
xline(length(preamble), 'g', 'LineWidth', 3);
xline(length(preamble) + length(train_ofdm_symbols), 'b', 'LineWidth', 3);
title('Transmitted Signal');
xlabel('Sample Index');
ylabel('Amplitude');
legend('Signal','End of Preamble', 'End of training')


% dummy 400Hz sinus generation
%time = 1:1/conf.f_s:4;
%txsignal = 0.3*sin(2*pi*400 * time.');