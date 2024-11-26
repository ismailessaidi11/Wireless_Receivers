function BER = Simulator_P1T2_template(SNR, mapping_type)
%default values
if nargin < 1
    SNR=100;
    mapping_type ="QAM16";
end

% Initialization
BER = zeros(size(SNR));

% number of bits
numbits = 10^4;
num_bit_symb = 4;
num_symb = numbits/num_bit_symb;
 
switch mapping_type
       case 'QAM16'
            Map_nonorm = [(-3 + 3j) (-3 + 1j) (-3 - 3j) (-3 -1j) ...   % not normalized symbols
             (-1 + 3j) (-1 + 1j) (-1 - 3j) (-1 - 1j) ...
             (3 + 3j) (3 + 1j) (3 - 3j) (3 -1j) ...
             (1 + 3j) (1 + 1j) (1 - 3j) (1 - 1j)];
            Map_norm = normalize(Map_nonorm);
       case 'PSK16'
            Map_nonorm = exp([0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15].*1j*2*pi/16)  ;          
            Map_norm = normalize(Map_nonorm);

    otherwise
        error("Mapping type not supported")
end 

% normalized mapping

for ii = 1: length(SNR)
    % Convert SNR from dB to linear
    SNR_lin = 10^(SNR(ii)/10);
    % Generate source bitstream
    bitstream = randi([0 1],num_symb,num_bit_symb); 

    % Map input bitstream into Symbols
   switch mapping_type
       case 'QAM16'
            mapped_bitstream = map_QAM(bitstream, Map_norm);
       case 'PSK16'
            mapped_bitstream = map_PSK(bitstream, Map_norm);
     otherwise
        error("Mapping type not supported")
    end
    % Add AWGN
    chan_bitstream = mapped_bitstream + sqrt(1/(2*SNR_lin)) * (randn(size(mapped_bitstream)) + 1i*randn(size(mapped_bitstream))); 
    % Demapping
    switch mapping_type
       case 'QAM16'
            demapped_bitstream = demap_PSK(chan_bitstream, Map_norm, num_symb);
       case 'PSK16'
            demapped_bitstream = demap_PSK(chan_bitstream, Map_norm, num_symb);
     otherwise
        error("Mapping type not supported")
    end
    % calculate BER
    BER(ii) = mean(bitstream(:) ~= demapped_bitstream(:));

end
