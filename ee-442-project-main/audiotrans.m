% % % % %
% Wireless Receivers: algorithms and architectures
% Acoustic OFDM Project - Main file (adapted from course)
% Fabio Palmisano
% Rafael Riber
%
%   3 operating modes:
%   - 'matlab' : generic MATLAB audio routines (unreliable under Linux)
%   - 'native' : OS native audio system
%       - ALSA audio tools, most Linux distrubtions
%       - builtin WAV tools on Windows 
%   - 'bypass' : no audio transmission, takes txsignal as received signal
%   - 'awgn' : Simulates AWGN channel

close all; clear; clc;

% Configuration Values
conf.audiosystem = 'matlab'; % Values: 'matlab','native','bypass','awgn
conf.estimation = 'viterbi'; % Possible options: 'block', 'viterbi'

conf.f_s     = 48000;   % sampling rate  
conf.f_sym   = 500;     % symbol rate
conf.nframes = 1;       % number of frames to transmit
conf.modulation_order = 2; % BPSK:1, QPSK:2
conf.f_c     = 800;    % Carrier Frequency
conf.N = 256;           %Number of subcarriers
conf.Fspacing = 5;
conf.os_factor  = conf.f_s/conf.f_sym;
conf.filter_len = 10*conf.os_factor;        
conf.CP = conf.N / 2;                     % Cyclic Prefix length (half of the OFDM symbol length)
conf.nbits   = 4096; % number of bits 
conf.nb_symbols = conf.nbits/(2*conf.N); % nb of time domain OFDM symbols
conf.BWBB = ceil(conf.N / 2) * conf.Fspacing; % Baseband bandwidth
conf.ntraining = 256;
conf.RollOff = 0.22;
conf.npreamble  = 100;
conf.detection_threshold = 5;
conf.bitsps     = 16;   % bits per audio sample
conf.CIR_Threshold = 10^(-5/20);
% IMAGE OR NOT ?
conf.sendimage = 0; %1 to send image, 0 to send random bits
% SCRAMBLE OR NOT ?
conf.scramble = 1;
conf.scramInit = 93;

% Init Section
% all calculations that you only have to do once
if mod(conf.os_factor,1) ~= 0
   disp('WARNING: Sampling rate must be a multiple of the symbol rate'); 
end

if conf.nb_symbols < 1
   disp('WARNING: Not enough data !'); 
end

% Initialize result structure with zero
res.biterrors   = zeros(conf.nframes,1);
res.rxnbits     = zeros(conf.nframes,1);

% Generate training data
training_bits = randi([0 1], conf.ntraining, 1); % Training bits
training_symbols = 2*training_bits - 1;

preamble_bits = preamble_generate(conf.npreamble); % Preamble bits

if conf.sendimage == 1
    conf.image_padding = 512;
    %load image and convert to BW
    img = imread("parrot.png");
    image_black_white = im2bw(img,0.45);
    figure(1);
    subplot(1,2,1);
    imshow(image_black_white);
    title('Sent Image'); % Place title here
    conf.imageheight = size(image_black_white,1);
    conf.imagelength = size(image_black_white,2);
    image_black_white= double(image_black_white(:));
    imlengthvector = length(image_black_white);
    padded = mod(imlengthvector,conf.image_padding);
    conf.padlength = conf.image_padding-padded;
    pad = zeros(conf.padlength,1);
    image_black_white = [image_black_white; pad];
    txbits = image_black_white;
    conf.nbits = length(txbits);
    conf.nb_symbols = conf.nbits/(2*conf.N);
else
    % Data
    txbits = randi([0 1], conf.nbits, 1);
end

for k=1:conf.nframes

    disp(['CP: ', num2str(conf.CP)]);
    disp(['Eff: ', num2str(512/(512+conf.CP))]);
    
    % TODO: Implement tx() Transmit Function
    [txsignal conf] = tx(txbits,conf,k,training_symbols, preamble_bits);
    
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
    
%     wavwrite(rawtxsignal,conf.f_s,16,'out.wav')   
    audiowrite('out.wav',rawtxsignal,conf.f_s)  
    
    % Platform native audio mode 
    if strcmp(conf.audiosystem,'native')
        
        % Windows WAV mode 
        if ispc()
            disp('Windows WAV');
            wavplay(rawtxsignal,conf.f_s,'async');
            disp('Recording in Progress');
            rawrxsignal = wavrecord((txdur+1)*conf.f_s,conf.f_s);
            disp('Recording complete')
            rxsignal = rawrxsignal(1:end,1);
        % ALSA WAV mode 
        elseif isunix() && ~ismac()
            disp('Linux ALSA');
            cmd = sprintf('arecord -c 2 -r %d -f s16_le  -d %d in.wav &',conf.f_s,ceil(txdur)+1);
            system(cmd); 
            disp('Recording in Progress');
            system('aplay  out.wav')
            pause(2);
            disp('Recording complete')
            rawrxsignal = audioread('in.wav');
            rxsignal    = rawrxsignal(1:end,1);
        elseif ismac()
            disp('macOS Core Audio using sox');
            % Play audio using afplay
            afplay_cmd = sprintf('afplay out.wav &');
            system(afplay_cmd);
            disp('Playback in Progress');

            % Record audio using sox
            record_cmd = sprintf('sox -d -c 2 -r %d -b 16 in.wav trim 0 %d &', conf.f_s, ceil(txdur)+1);
            system(record_cmd);
            disp('Recording in Progress');
            pause(txdur + 2);
            disp('Recording complete');

            rawrxsignal = audioread('in.wav');
            rxsignal = rawrxsignal(1:end,1);
            figure;
            plot(rxsignal);
            title('Received Signal')
            xlabel('Sample')
            ylabel('Amplitude reveived by the mic')
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
        rxsignal     = double(rawrxsignal(1:end))/double(intmax('int16')) ;
        figure;
        plot(rxsignal);
        title('Received Signal')
        xlabel('Sample')
        ylabel('Amplitude reveived by the mic')
        
    elseif strcmp(conf.audiosystem,'bypass')
        rawrxsignal = rawtxsignal(:,1);
        rxsignal    = rawrxsignal;
    elseif strcmp(conf.audiosystem, 'awgn')
        SNR = 20;
        SNRlin = 10^(SNR/10);
        rawrxsignal = rawtxsignal(:,1);
        rawrxsignal = rawrxsignal + sqrt(1/(2*SNRlin)) * (randn(size(rawrxsignal)) + 1i*randn(size(rawrxsignal)));
        rxsignal    = rawrxsignal;
    end

    %
    % End
    % Audio Transmission   
    % % % % % % % % % % % %
    
    [rxbits conf]       = rx(rxsignal,conf,k,training_symbols, preamble_bits);
    
    res.rxnbits(k)      = length(rxbits);  
    res.biterrors(k)    = sum(rxbits ~= txbits);

end

if conf.sendimage == 1
    received_image = rxbits(1:end-conf.padlength);
    total_elements = numel(received_image);
    if mod(total_elements, conf.imageheight) == 0
        conf.imagelength = total_elements / conf.imageheight;
        received_image = reshape(received_image, [conf.imageheight, conf.imagelength]);
        received_image = logical(received_image);
        figure(1);
        subplot(1,2,2);
        imshow(received_image);
        title('Received Image');
    else
        error('Mismatch in image dimensions.');
    end
end

per = sum(res.biterrors > 0)/conf.nframes
ber = sum(res.biterrors)/sum(res.rxnbits)