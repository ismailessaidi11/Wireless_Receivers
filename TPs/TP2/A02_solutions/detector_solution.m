function [start] = detector_solution(p,r, thr)
%DETECTOR Summary of this function goes here
%   Detailed explanation goes here
Np = size(p,1);
Nr = size(r,1);
c = zeros(Nr-Np, 1);
c_norm = zeros(Nr-Np, 1);
    for n = 1:Nr-Np
        % c: complex value
        c(n, 1) = sum(p.*r(n : n+ (Np-1), 1));
        demominator = sum(abs(r(n  : n + (Np-1), 1)).^2);
        if demominator == 0
            c_norm(n, 1) = 0;
        else
            % normalized c
            c_norm(n, 1) = abs(c(n, 1))^2/demominator;

        end
        if c_norm(n, 1) > thr
            start = n+100;
            return
        end
    end
disp('Frame start not found.')
start = -1;
end