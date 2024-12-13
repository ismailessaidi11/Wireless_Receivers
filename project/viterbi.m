function theta_hat = viterbi(symbol_stream, old_theta)

theta_hat = zeros(length(symbol_stream),1);

for i = 1: length(symbol_stream)
    % Apply viterbi-viterbi algorithm
    deltaTheta = (1/4)*angle(-symbol_stream(i)^4) + pi/2*(-1:4);
        
    % Unroll phase
    [~, ind] = min(abs(deltaTheta - old_theta(i)));
    theta = deltaTheta(ind);
    % Lowpass filter phase
    theta_hat(i) = mod(0.01*theta + 0.99*old_theta(i), 2*pi);
end
end


