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

figure(1);
subplot(2,1,1);
plot(rxsignal);
title('Received Signal');
xlabel('Sample Index');
ylabel('Amplitude');
legend('Signal')

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
[idx, ~, ~] = frame_sync(filtered_rxsignal, conf); %check if it gives the right idx (NOT SUUUUURE)

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

% plot the Channel 
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
    % Extract symbol by symbol (no CP)
    ofdm_symbol = ofdm_data(1+conf.len_ofdm_cp+(i-1)*(conf.len_ofdm_symbol+conf.len_ofdm_cp):i*(conf.len_ofdm_symbol+conf.len_ofdm_cp));
    symbol_stream = osfft(ofdm_symbol, conf.os_factor);

    % Phase estimation 
    theta_hat = viterbi(symbol_stream, theta_hat); 
    
    %channel correction (amplitude and phase)
    symbol_stream = symbol_stream ./ abs(h);
    symbol_stream = symbol_stream .* exp(-1j * theta_hat);

    % fill up rx_symbols
    rx_symbols(1+(i-1)*length(symbol_stream):i*length(symbol_stream)) = symbol_stream;
end

plot_constellation(rx_symbols,  'rx constellation');

% demapping
rxbits = QPSK_demapper(rx_symbols);
rxbits = rxbits(1:conf.nbits);

% Show Image and Save it to images folder
if (strcmp(conf.image, 'yes'))
    % Convert bit stream back to pixel values
    pixels = uint8(bin2dec(reshape(char(rxbits + '0'), 8, []).')); % Convert binary to decimal
        
    % Reshape into grayscale format
    rx_image = reshape(pixels, conf.image_w, conf.image_h);
    
    % Display the image
    figure;
    imshow(rx_image);
    title('Reassembled Image');
    
    filename = '/rx_image_256.jpg';
    output_path = fullfile(conf.image_folder_path, filename); % Create the full file path
    % Save the image
    imwrite(rx_image, output_path);
end
% dummy 
%rxbits = zeros(conf.nbits,1);