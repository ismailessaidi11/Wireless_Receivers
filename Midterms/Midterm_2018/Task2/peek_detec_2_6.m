function p0 = peek_detec_2_6(rx_signal,preamble, L)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
rx = rx_signal(:);
Nr = length(rx_signal);
Np = length(preamble);

c = zeros(Nr-Np+1, 1);
c_norm = zeros(Nr-Np+1, 1);
    for n = 1:Nr-Np+1
        c(n, 1) = sum(conj(preamble).*rx(n : n+Np-1, 1));
        denom = sum(abs(rx(n: n+Np-1, 1).^2));
        c_norm(n, 1) = abs(c(n, 1))^2/denom;

    end 

    
end