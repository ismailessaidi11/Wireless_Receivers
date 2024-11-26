function theta_n = generate_phase_noise(length_of_noise, sigmaDeltaTheta)
    % Create phase noise
    theta_n = zeros(length_of_noise, 1);
    theta_n(1, 1) = 2*pi*rand;
    %% TODO
    for ii = 2:length_of_noise
        
        theta_n(ii, 1) = theta_n(ii-1, 1) + sigmaDeltaTheta*randn;
    end
    
end