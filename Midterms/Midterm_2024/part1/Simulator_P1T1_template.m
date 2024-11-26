function BER = Simulator_P1T1_template(SNR, channel_type)
% Initialization
BER = zeros(size(SNR));
% number of symbols
num_bit_frame = 2000;
num_bit_symb = 2;
num_frames = 1000;  % simulate a number of frames (The higher the number of frames the better we estimte the channel!!!!) 
num_symb_frame = num_bit_frame/num_bit_symb;  % define number of symbols in one frame (QPSK)
num_symb = num_frames * num_symb_frame;  % total number of symbols
        
GrayMap = 1/sqrt(2) * [(-1-1j) (-1+1j) ( 1-1j) ( 1+1j)]; % gray map

for ii = 1: length(SNR)  % loop over all SNR values
    sum_error = 0;

    for kk = 1: num_frames   % loop over all frames
        % Convert SNR from dB to linear
        SNR_lin = 10^(SNR(ii)/10);

        % Generate source bitstream
        bitstream = randi([0 1],num_symb_frame,num_bit_symb); 

        % Map input bitstream using Gray mapping
        frame = GrayMap(bi2de(bitstream, 'left-msb')+1).';
        switch channel_type
            case 'awgn'
                h = 1;
            case 'fading'
                % Rayleigh Fading Channel
                h = randn(1,1)+1i*randn(1,1);
        end 
    
        % apply channel
        chanFrame = h * frame;
        % add AWGN
        y = chanFrame + sqrt(1/(2*SNR_lin)) * (randn(size(chanFrame)) + 1i*randn(size(chanFrame))); 
        % invert the effect of the channel h
        y_recovered = y/h;
        
        % Demap AWGN
        distances = abs(y_recovered - GrayMap).^2;  % Matrix of distances
        [~, ind] = min(distances, [], 2);  % Closest constellation points
        demapped_frame = de2bi(ind - 1, num_bit_symb, 'left-msb');
        % calculate error
        sum_error = sum_error + sum(bitstream(:) ~= demapped_frame(:));
    end
    
    % BER calculation for Gray mapping
    
    BER(ii) = sum_error/num_bit_frame;

end
end
