function preamble = preamble_generate(preamble_len)
% A linear feedback shift register (LFSR) which outputs a PN sequence of length output_length.
% The current LFSR has a period length of 255, but the polynomial can easily be changed for a longer one.

% The implementation of this shift register is not very efficient, bit operations would be faster.
% But this version is more readable, so who cares...

% feed back polynomial
% this one here means:
% x^0 + x^2 + x^3 + x^4 + x^8
% The term x^8 is only implicitly given by the length of the polynomial
polynomial = [1 0 1 1 1 0 0 0]';

% All memories are initialized with ones
state = ones(size(polynomial));

preamble = zeros(preamble_len, 1);

for i = 1:preamble_len,
    preamble(i) = state(1);
    feedback = mod(sum(state .* polynomial), 2);
    state = circshift(state, -1);
    state(end) = feedback;
end
preamble = preamble*2 -1; % convert to BPSK
end