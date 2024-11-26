function [c, c_norm] = correlator(p,r)
% Input:  p: preamble (shape = (Np, 1)), r: received signal (shape = (Nr, 1))
% output: c: correlated signal (shape = (Nr-Np+1, 1)), c_norm: normalized correlated signal (shape = (Nr-Np+1, 1))
Np = size(p,1);
Nr = size(r,1);
c = zeros(Nr-Np+1, 1);
c_norm = zeros(Nr-Np+1, 1);
%% TODO:
    for n = 1:Nr-Np+1
        c(n, 1) = sum(conj(p).*r(n : n+Np-1, 1));
        denom = sum(abs(r(n: n+Np-1, 1).^2));
        c_norm(n, 1) = abs(c(n, 1))^2/denom;
    end 
end



