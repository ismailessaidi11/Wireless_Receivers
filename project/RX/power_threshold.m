function threshold_power = power_threshold(power_delay_profile)
%POWER_THRESHOLD Computes the threshold to measure the length of our
%channel
%   Uses a Median Absolute Deviation method (robust to outliers) to find
%   the power of the noise that should used as a threshold to measure the
%   lngth of the channel

% Compute the median of power_delay_profile
median_noise = median(power_delay_profile);

% Compute the Median Absolute Deviation 
sigma_est = median(abs(power_delay_profile - median_noise));

% Define the threshold 
alpha = 12;  % hyperparameter tuned for the channel
threshold_power = median_noise + alpha * sigma_est;

end

