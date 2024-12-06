% EE-442 Wireless Receivers : algorithms and architectures
% Final Project : OFDM Audio Transmission System
% Authors : Palmisano Fabio, Riber Rafael

function [preamble] = preamble_generate(length)

% input : length: a scalar value, desired length of preamble.
% output: preamble: preamble bits

preamble = zeros(length, 1);
LFSR_length = 8;
LFSR = ones(LFSR_length,1);

for i = 1:length
    preamble(i) = LFSR(end);
    a = xor(LFSR(6),LFSR(end));
    b = xor(LFSR(5),a);
    c = xor(LFSR(4),b);
    LFSR(end) = c;
    LFSR = circshift(LFSR,1);
end

end

