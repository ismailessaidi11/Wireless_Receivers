function conf = config(f_s, f_spacing, nbits, f_c, N)
% Configuration Values

conf.audiosystem = 'matlab'; % Values: 'matlab','native','bypass'
conf.noise = "awgn";

conf.f_s     = f_s;   % sampling rate  
conf.f_spacing   = f_spacing;     % 5Hz of spacing
conf.nframes = 1;       % number of frames to transmit
conf.nbits   = nbits;    % number of bits 
conf.modulation_order = 2; % BPSK:1, QPSK:2
conf.f_c     = f_c;
conf.npreamble  = 200;

conf.bitsps     = 16;   % bits per audio sample
conf.offset     = 0;

% ofdm conf fields:
conf.N = N;       % number of subcarriers
conf.T = 1/conf.f_spacing; % length of an OFDM symbol
conf.CP = 0.5 * conf.N; % half the ofdm symbol length 
conf.BW_bb = ceil(0.5*(conf.N+1))*conf.f_spacing;
conf.f_cutoff = 2*conf.BW_bb; % experimental VALUE maybe CHANGE LATERRRRRRRRRRRRRRR

% Init Section
% all calculations that you only have to do once
conf.os_factor  = conf.f_s/(conf.f_spacing*conf.N); 
conf.os_factor_preamble = 300; % arbitrary value 
if mod(conf.os_factor,1) ~= 0
   disp('WARNING: Sampling rate must be a multiple of the symbol rate'); 
end
conf.nsyms      = ceil(conf.nbits/conf.modulation_order); % number of symbols

% added conf fields
conf.tx_filterlen = conf.os_factor * 20; % maybe change 
conf.rx_filterlen = conf.os_factor * 20;
conf.rolloff = 0.22;
conf.SNR_db = 10;
conf.SNR_lin = 10^(conf.SNR_db/10);

end

