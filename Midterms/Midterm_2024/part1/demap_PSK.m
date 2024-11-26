function demapped_bitstream = demap_PSK(chan_bitstream, Map_norm, num_symb);
%UNTITLED7 Summary of this function goes here
%   Detailed explanation goes here
        [~,ind] = min((ones(num_symb,16)*diag(Map_norm) - diag(chan_bitstream)*ones(num_symb,16)),[],2);
        demapped_bitstream = de2bi(ind-1, 'left-msb');
end