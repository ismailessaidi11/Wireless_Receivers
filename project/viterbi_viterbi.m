function  phase_corrected_signal = viterbi_viterbi(signal)
%VITERBI_VITERBI algorithm for phase estimation and correction

phase_corrected_signal = zeros(length(signal),1);
theta_hat = zeros(length(signal)+1, 1);

for k = 1 : length(signal)
    % Apply viterbi-viterbi algorithm
    deltaTheta = 1/4*angle(-signal(k)^4) + pi/2*(-1:4);
    
    % Unroll phase
    [~, ind] = min(abs(deltaTheta - theta_hat(k)));
    theta = deltaTheta(ind);
    % Lowpass filter phase
    theta_hat(k+1) = mod(0.01*theta + 0.99*theta_hat(k), 2*pi);
    
    % Phase correction
    phase_corrected_signal(k) = signal(k) * exp(-1j * theta_hat(k+1));

end
end

