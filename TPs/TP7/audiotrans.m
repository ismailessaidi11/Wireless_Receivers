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
% Configuration Values
conf.audiosystem = 'bypass'; % Values: 'matlab','native','bypass'

conf.f_s     = 48000;   % sampling rate  
conf.f_sym   = 100;     % symbol rate
conf.nframes = 1;       % number of frames to transmit
conf.nbits   = 2000;    % number of bits 
conf.modulation_order = 2; % BPSK:1, QPSK:2
conf.f_c     = 4000;

conf.npreamble  = 100;
conf.bitsps     = 16;   % bits per audio sample
conf.offset     = 0;
conf.tx_filterlen = 20; % symbols
conf.rx_filterlen = 20; % symbols
conf.rolloff = 0.22;

conf.SNR_db = 50;
conf.SNR_lin = 10^(conf.SNR_db/10);

% Init Section
% all calculations that you only have to do once
conf.os_factor  = conf.f_s/conf.f_sym;
if mod(conf.os_factor,1) ~= 0
   disp('WARNING: Sampling rate must be a multiple of the symbol rate'); 
end
conf.nsyms      = ceil(conf.nbits/conf.modulation_order);

% Initialize result structure with zero
res.biterrors   = zeros(conf.nframes,1);
res.rxnbits     = zeros(conf.nframes,1);

% TODO: To speed up your simulation pregenerate data you can reuse
% beforehand.


% Results
% Results
freq_range = 100:100:100;
BER_list = zeros(size(freq_range));
for ii = 1:numel(freq_range)
    conf.f_sym = freq_range(ii);

    for k=1:conf.nframes
        
        % Generate random data
        txbits = randi([0 1],conf.nbits,1);
        
        % TODO: Implement tx() Transmit Function
        [txsignal conf] = tx(txbits,conf,k);
        
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
        
        % wavwrite(rawtxsignal,conf.f_s,16,'out.wav')   
        audiowrite('out.wav',rawtxsignal,conf.f_s)  
        
        % Platform native audio mode 
        if strcmp(conf.audiosystem,'native')
            
            % Windows WAV mode 
            if ispc()
                disp('Windows WAV');
                playobj = audioplayer(rawtxsignal, conf.f_s);
                recobj = audiorecorder(conf.f_s, conf.bitsps, 1); % 1 channel for mono recording
                
                % Start recording and playback
                record(recobj); % Start recording
                disp('Recording in Progress');
                playblocking(playobj); % Play the signal and block execution until done
                pause(0.5); % Optional pause to ensure recording captures entire signal
                stop(recobj); % Stop recording
                disp('Recording complete');
    
                % Retrieve recorded data
                rawrxsignal = getaudiodata(recobj, 'int16'); % Retrieve as 16-bit integers
                rxsignal = double(rawrxsignal) / double(intmax('int16')); % Normalize recorded signal
    
    
            % ALSA WAV mode 
            elseif isunix()
                disp('Linux ALSA');
                cmd = sprintf('arecord -c 2 -r %d -f s16_le  -d %d in.wav &',conf.f_s,ceil(txdur)+1);
                system(cmd); 
                disp('Recording in Progress');
                system('aplay  out.wav')
                pause(2);
                disp('Recording complete')
                rawrxsignal = audioread('in.wav');
                rxsignal    = rawrxsignal(1:end,1);
            end
            
        % MATLAB audio mode
        elseif strcmp(conf.audiosystem,'matlab')
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
            SNR = 5;
            SNR_lin = 10^(SNR/10);
            rxsignal    = rawrxsignal + sqrt(1/2/SNR_lin)*(randn(size(rawrxsignal))+1j*randn(size(rawrxsignal)));
            %rxsignal    = rawrxsignal;
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
        [rxbits conf]       = rx(rxsignal,conf);
        
        res.rxnbits(k)      = length(rxbits);  
        res.biterrors(k)    = sum(rxbits ~= txbits);
        
    end
    per = sum(res.biterrors > 0)/conf.nframes;
    ber = sum(res.biterrors)/sum(res.rxnbits);
    BER_list(ii) = ber;
end

figure;
semilogy(freq_range, BER_list, 'bx-' ,'LineWidth',3)

xlabel('Symbol rate')
ylabel('BER')
grid on
