function Map_norm = normalize(Map_nonorm)
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here
average_energy = sum(abs(Map_nonorm).^2)/length(Map_nonorm);
Map_norm = Map_nonorm / sqrt(average_energy);
end