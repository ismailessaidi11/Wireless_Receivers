function conf = config(f_s, f_spacing, nbits, f_c, N, nframes)

% config mode 
conf.audiosystem = 'matlab'; % Values: 'matlab','native','bypass'
conf.noise = 'awgn';
conf.image = ''; % 3 options:       ''          '/image_256.jpg'           '/image_64.jpg'

% Transmission config
conf.f_s     = f_s;                                         % sampling rate  
conf.f_spacing   = f_spacing;                               % 5Hz of spacing
conf.nframes = nframes;                                     % number of frames to transmit
conf.nbits   = nbits;                                       % number of bits 
conf.modulation_order = 2;                                  % BPSK:1, QPSK:2
conf.nsyms      = ceil(conf.nbits/conf.modulation_order);   % number of symbols
conf.f_c     = f_c;                                         % carrier frequency
conf.npreamble  = 200;                                      % length of preamble
conf.bitsps     = 16;                                       % bits per audio sample
conf.offset     = 0;
conf.N = N;                                                 % number of subcarriers
conf.T = 1/conf.f_spacing;                                  % length of a subcarrier
conf.cp_coef = 0.5;                                         % coefficient of the CP in terms of 1 OFDM symbol
conf.CP = conf.cp_coef * conf.N;                            % length of CP 
conf.BW_bb = ceil(0.5*(conf.N+1))*conf.f_spacing;           % Bandwidth of the baseband OFDM signal
conf.f_cutoff = 2*conf.BW_bb;                               % cutoff frequency at the receiver
conf.os_factor  = conf.f_s/(conf.f_spacing*conf.N);         % Over Sampling factor of the signal 
conf.os_factor_preamble = 50;                               % Over Sampling factor of the preamble 
if mod(conf.os_factor,1) ~= 0
   disp('WARNING: Sampling rate must be a multiple of the symbol rate'); 
end
conf.tx_filterlen = conf.os_factor * 20;                    % length of TX filter   
conf.rx_filterlen = conf.os_factor * 20;                    % length of RX filter
conf.rolloff = 0.22;                                        % Rolloff of the Root Raised Cosine filter.
conf.SNR_db = 100;                                          % SNR in dB
conf.SNR_lin = 10^(conf.SNR_db/10);                         % SNR linear

% Config directories and paths for plots
conf.image_folder_path = 'images';
conf.plot_path = 'plots/';  
conf.ber_path = 'plots/BER/';
conf.spectral_eff_path  = 'plots/spectral_efficiency/';
conf.channel_path  = 'plots/channel/';
conf.pdp_path  = 'plots/pdp/';
if ~exist(conf.plot_path, 'dir')
    mkdir(conf.plot_path); 
    mkdir(conf.ber_path);
    mkdir(conf.spectral_eff_path);
    mkdir(conf.channel_path);
    mkdir(conf.pdp_path);

end

end

