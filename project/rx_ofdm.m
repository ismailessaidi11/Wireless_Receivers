function [rxbits conf] = rx_ofdm(rxsignal,conf,k)
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
rx_downconverted = rxsignal .* exp(-2i*pi*(conf.f_c)*t.');

% Low-pass Filter
rx_baseband = 2*ofdmlowpass(rx_downconverted,conf); % NOT SURE ABOUT THE 2*

% Matched filter
matched_filter = rrc(conf.os_factor_preamble, conf.rolloff, conf.rx_filterlen); 
filtered_rxsignal = conv(rx_baseband,matched_filter,'same');

% frame synch 
[idx, phase_of_peak, magnitude_of_peak] = frame_sync(filtered_rxsignal, conf); %check if it gives the right idx (NOT SUUUUURE)

% channel estimation and correction
%h = magnitude_of_peak*exp(1j*phase_of_peak);
%corrected_rxsignal = conj(h)/norm(h)^2*filtered_rxsignal;

% 1) extract ofdm symbols (rx_baseband = train_cp + train + cp + ofdm symbols)
% 2) use train to estimate channel 
% 3) fft the data


% extract ofdm data
len_ofdm_symbols = conf.num_ofdm_symbols*(conf.len_ofdm_symbol+conf.len_ofdm_cp);
ofdm_data = rx_baseband(idx+conf.len_train_data+1 : idx+conf.len_train_data+len_ofdm_symbols);
% extract train data
ofdm_train = rx_baseband(1+idx+conf.len_cp_train : idx+conf.len_train_data); % no CP 

% channel estimation
train_symbols = osfft(ofdm_train, conf.os_factor);
h = train_symbols ./ conf.train_symbols;
theta_hat = mod(angle(h), 2*pi);

rx_symbols = zeros([conf.N*conf.num_ofdm_symbols 1]);

figure(4);
subplot(2,1,1);
plot(abs(h))
xlabel("Subcarrier index")
ylabel("Magnitude")
title("Magnitude of H")
figure(4);
subplot(2,1,2);
plot(theta_hat)
ylabel("Subcarrier angle [rad]")
xlabel("Subcarrier index")
title("Phase of H")

for i = 1 : conf.num_ofdm_symbols
    %extract symbol by symbol (no CP)
    ofdm_symbol = ofdm_data(1+conf.len_ofdm_cp+(i-1)*(conf.len_ofdm_symbol+conf.len_ofdm_cp):i*(conf.len_ofdm_symbol+conf.len_ofdm_cp));
    symbol_stream = osfft(ofdm_symbol, conf.os_factor);
    %plot_constellation(symbol_stream,  'FFT');

    % Phase estimation 
    theta_hat = viterbi(symbol_stream, theta_hat); 
    
    %channel correction (amplitude and phase)
    symbol_stream = symbol_stream ./ abs(h);
    symbol_stream = symbol_stream .* exp(-1j * theta_hat);
    symbol_stream = normalize(symbol_stream);

    % fill up rx_symbols
    rx_symbols(1+(i-1)*length(symbol_stream):i*length(symbol_stream)) = symbol_stream;
end

%%
%theta_hat = zeros(length(downsampled_rxsignal)+1, 1);
% Phase estimation
%for k = 1 : length(downsampled_rxsignal)
    % Apply viterbi-viterbi algorithm
%    deltaTheta = 1/4*angle(-downsampled_rxsignal(k)^4) + pi/2*(-1:4);
    
    % Unroll phase
%    [~, ind] = min(abs(deltaTheta - theta_hat(k)));
%    theta = deltaTheta(ind);
    % Lowpass filter phase
%    theta_hat(k+1) = mod(0.01*theta + 0.99*theta_hat(k), 2*pi);
    
    % Phase correction
%    downsampled_rxsignal(k) = downsampled_rxsignal(k) * exp(-1j * theta_hat(k+1));

%end

plot_constellation(rx_symbols,  'rx constellation');

% demapping
rxbits = QPSK_demapper(rx_symbols);

% dummy 
%rxbits = zeros(conf.nbits,1);