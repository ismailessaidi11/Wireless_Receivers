function conf = plot_channel_measurements(conf, H, theta_hat, k)
%PLOT_CHANNEL_MEASUREMENTS Summary of this function goes here
%   Detailed explanation goes here


% plot the Channel Spectrum (Amplitude and Phase)
figure;
subplot(2,1,1);
plot(abs(H))
xlabel("Subcarrier index")
ylabel("Magnitude")
title(sprintf("Magnitude of H (frame %s)", num2str(k)));
subplot(2,1,2);
plot(theta_hat)
ylabel("Subcarrier angle [rad]")
xlabel("Subcarrier index")
title(sprintf("Phase of H (frame %s)", num2str(k)));

fileName = 'Channel_Spectrum.png';       
saveas(gcf, fullfile(conf.channel_path, fileName)); 

% plot the CIR (time domain)
h = ifftshift(ifft(H));
power_delay_profile = abs(h) .^2;
power_delay_profile = power_delay_profile / max(power_delay_profile); % Normalize

% Calculate the power threshold that is larger than the noise
threshold_power = power_threshold(power_delay_profile);
peaks_indices = find(power_delay_profile > threshold_power);


if ~isempty(peaks_indices)
    delay_spread = peaks_indices(end) - peaks_indices(1);
    conf.delay_spread_time_ms = (delay_spread / conf.f_s) * 10^3; % calculate delay spread in ms
    fprintf("Delay Spread : %d samples\n", delay_spread);
    fprintf("Delay Spread : %d milliseconds\n", conf.delay_spread_time_ms);

    Ts = 1/conf.f_s;
    time = (0:length(h)-1)*Ts;
    
    % Power Delay Profile - Plot
    figure;
    subplot(2,1,1);
    xlim([1 length(power_delay_profile)]);
    plot(time, 10*log10(power_delay_profile), 'Color', [0.5 0.5 0.5]);
    hold on;
    yline(10*log10(threshold_power), 'b--', 'LineWidth', 1.5);
    xlabel("Time [s]");
    ylabel("Power [dB]");
    title("Log Channel Power Delay Profile ");
    grid on;
    % Power Delay Profile - Delay Spread
    subplot(2,1,2);
    plot(10*log10(power_delay_profile), 'LineWidth', 1.5);
    hold on;
    plot(peaks_indices, 10*log10(power_delay_profile(peaks_indices)), 'ro', 'MarkerSize', 8);
    xline(peaks_indices(1), 'g--', 'LineWidth', 1.5);
    xline(peaks_indices(end), 'r--', 'LineWidth', 1.5);
    xlabel('Delay (samples)');
    ylabel('Power [dB]');
    title('Power Delay Profile with Delay Spread Markers');
    legend('PDP', 'Significant Peaks', 'First Peak', 'Last Peak');
    grid on;
    
    fileName = 'pdp_and_delay_spread_calculation.png';       
    saveas(gcf, fullfile(conf.pdp_path, fileName)); 
else
    disp("No significant peaks detected.")
end


end

