% % % % %
% Wireless Receivers: algorithms and architectures
% Audio Transmission Framework 
%
%
%   3 operating modes:
%   - 'matlab' : generic MATLAB audio routines (unreliable under Linux)
%   - 'native' : OS native audio system
%       - ALSA audio tools, most Linux distrubtions
%       - builtin WAV tools on Windows 
%   - 'bypass' : no audio transmission, takes txsignal as received signal
clear;
clc;
addpath('RX/');
addpath('TX/');
addpath('common/');


f_s         = 48000;  % sampling frequency  
f_spacing   = 5;      % freqeuncy pacing between subcarriers
nbits       = 4096;   % Num of bits
f_c         = 2000;   % Carrier Frequency
N           = 256;    % Number of subcarriers

conf = config(f_s, f_spacing, nbits, f_c, N);

% Initialize result structure with zero
res.biterrors   = zeros(conf.nframes,1);
res.rxnbits     = zeros(conf.nframes,1);

% TODO: To speed up your simulation pregenerate data you can reuse
% beforehand.



% Results
conf.plot_path = 'plots/';  
conf.ber_path = 'plots/BER/';
conf.spectral_eff_path  = 'plots/spectral_efficiency/';
conf.channel_path  = 'plots/channel/';


if ~exist(conf.plot_path, 'dir')
    mkdir(conf.plot_path); 
    mkdir('plots/BER/');
    mkdir('plots/spectral_efficiency/');
    mkdir('plots/channel/');

end

nbits = 4096; 
simulation.param_values = nbits;
simulation.param_name = "nbits";
simulation.channel_condition = "good channel";
BER_list = zeros(size(simulation.param_values));
eta_list = zeros(size(simulation.param_values));
for ii = 1:numel(simulation.param_values)
    conf.(simulation.param_name) = simulation.param_values(ii);
    disp(simulation.param_values(ii));
    for k=1:conf.nframes
        
        if(strcmp(conf.image, 'yes'))
            % Read Image and converts it to bit stream
            filename = '/tx_image_256.jpg';
            [txbits, conf] = conv_image_to_bits(filename, conf);
        else
            % Generate random data
            txbits = randi([0 1],conf.nbits,1);
        end
        
        % TODO: Implement tx() Transmit Function
        [txsignal conf] = tx_ofdm(txbits,conf,k);
        
        % % % % % % % % % % % %
        % Begin
        % Audio Transmission
        %
        
        % normalize values
        peakvalue       = max(abs(txsignal));
        normtxsignal    = txsignal / (peakvalue + 0.3);
        
        % create vector for transmission
        rawtxsignal = [ zeros(conf.f_s,1) ; normtxsignal ;  zeros(conf.f_s,1) ]; % add padding before and after the signal
        rawtxsignal = [  rawtxsignal  zeros(size(rawtxsignal)) ]; % add second channel: no signal
        txdur       = length(rawtxsignal)/conf.f_s; % calculate length of transmitted signal
        disp(['TX signal duration: ', num2str(txdur)]);
        % wavwrite(rawtxsignal,conf.f_s,16,'out.wav')   
        audiowrite('out.wav',rawtxsignal,conf.f_s)  
        
        % MATLAB audio mode
        if strcmp(conf.audiosystem,'matlab')
            disp('MATLAB generic');
            playobj = audioplayer(rawtxsignal,conf.f_s,conf.bitsps);
            recobj  = audiorecorder(conf.f_s,conf.bitsps,1);
            record(recobj);
            disp('Recording in Progress');
            playblocking(playobj)
            pause(0.5);
            stop(recobj);
            disp('Recording complete')
            rawrxsignal  = getaudiodata(recobj,'int16');
            rxdur       = length(rawrxsignal)/conf.f_s;
            rxsignal     = double(rawrxsignal(1:end))/double(intmax('int16')) ;
            
        elseif strcmp(conf.audiosystem,'bypass')
            rawrxsignal = rawtxsignal(:,1);
            if strcmp(conf.noise, 'awgn')
                rxsignal = rawrxsignal +  sqrt(1/(2*conf.SNR_lin)) * (randn(size(rawrxsignal)) + 1i*randn(size(rawrxsignal))); 
            else 
                rxsignal    = rawrxsignal;
            end
        end
        
        % Plot received signal for debugging
        %figure;
        %plot(rxsignal);
        %title('Received Signal')
        
        %
        % End
        % Audio Transmission   
        % % % % % % % % % % % %
        
        % TODO: Implement rx() Receive Function
        [rxbits conf]       = rx_ofdm(rxsignal,conf);
        
        res.rxnbits(k)      = length(rxbits);  
        
        res.biterrors(k)    = sum(rxbits ~= txbits);
        
    end
    eta_list(ii)  = spectral_efficiency(conf);

    per = sum(res.biterrors > 0)/conf.nframes;
    ber = sum(res.biterrors)/sum(res.rxnbits);
    disp(ber);
    BER_list(ii) = ber + 10^-9;
end

% Plot Spectral efficiency
figure;
semilogy(simulation.param_values, eta_list, 'bx-', 'LineWidth', 3);
xlabel(simulation.param_name);
ylabel('Spectral Efficiency');
grid on;
title(sprintf('Spectral Efficiency in terms of %s (%s)', simulation.param_name, simulation.channel_condition));
fileName = sprintf('%s.png', simulation.param_name);         
saveas(gcf, fullfile(conf.spectral_eff_path, fileName));

% Plot the BER
figure;
semilogy(simulation.param_values, BER_list, 'bx-', 'LineWidth', 3);
xlabel(simulation.param_name);
ylabel('BER');
grid on;
title(sprintf('BER in terms of %s (%s)', simulation.param_name, simulation.channel_condition));
fileName = sprintf('%s.png', simulation.param_name);       
saveas(gcf, fullfile(conf.ber_path, fileName)); 