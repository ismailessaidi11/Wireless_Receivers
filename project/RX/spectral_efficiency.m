function eta = spectral_efficiency(conf)
    % Calculate Spectral Efficiency for the OFDM system

    % Derived Parameters
    num_ofdm_symbols = ceil(conf.nsyms / conf.N);      % Number of OFDM symbols
    len_ofdm_symbol = conf.N * conf.os_factor;         % Length of each OFDM symbol
    len_cp = conf.CP * conf.os_factor;                 % CP length for OFDM symbol

    % Frame Length Calculation (including preamble, training, and data)
    % Preamble Length
    L_preamble = conf.npreamble * conf.os_factor_preamble; 
    
    % Training Length (includes CP)
    L_train = conf.len_cp_train + conf.len_train_data;
    
    % Data OFDM Symbols Length (including CP)
    L_data = num_ofdm_symbols * (len_ofdm_symbol + len_cp);

    % Total Frame Length (in samples)
    L_frame = L_preamble + L_train + L_data;

    % Frame Duration (in seconds)
    T_frame = L_frame / conf.f_s;
    
    % System Bandwidth
    BW = conf.N * conf.f_spacing; % Total bandwidth in Hz
    
    % Useful Data Rate
    R_useful = conf.nbits / T_frame; % Bits per second
    
    % Spectral Efficiency
    eta = R_useful / BW; % Bits/s/Hz

    fprintf('Spectral Efficiency: %.2f bits/s/Hz\n', eta);
end