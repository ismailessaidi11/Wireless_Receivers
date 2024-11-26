function mapped_bitstream = map_PSK(bitstream, Map_norm)
%UNTITLED6 Summary of this function goes here
%   Detailed explanation goes here
   mapped_bitstream = Map_norm(bi2de(bitstream, 'left-msb')+1).';

end