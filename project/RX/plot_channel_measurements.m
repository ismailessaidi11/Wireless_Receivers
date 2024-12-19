function  plot_channel_measurements(conf, H, theta_hat)
%PLOT_CHANNEL_MEASUREMENTS Summary of this function goes here
%   Detailed explanation goes here


% plot the Channel Spectrum (Amplitude and Phase)
figure;
subplot(2,1,1);
plot(abs(H))
xlabel("Subcarrier index")
ylabel("Magnitude")
title("Magnitude of H")
subplot(2,1,2);
plot(theta_hat)
ylabel("Subcarrier angle [rad]")
xlabel("Subcarrier index")
title("Phase of H")

fileName = 'Channel_Spectrum.png';       
saveas(gcf, fullfile(conf.channel_path, fileName)); 

% plot the CIR (time domain)
h = ifftshift(ifft(H));
power_delay_profile = abs(h) .^2;

% Calculate the power threshold that is larger than the noise
threshold_power = power_threshold(power_delay_profile);
taps_indices = find(power_delay_profile > threshold_power);

% Optional: Display results
fprintf('Noise Threshold: %.9f\n', threshold_power);

if ~isempty(taps_indices)
    delay_spread = taps_indices(end) - taps_indices(1);
    delay_spread_time = delay_spread / conf.f_s;
    fprintf("Delay Spread : %d samples\n", delay_spread);
    fprintf("Delay Spread : %d milliseconds\n", delay_spread_time*10^3);
else
    disp("No significant taps detected.")
end

Ts = 1/conf.f_s;
time = (0:length(h)-1)*Ts;

% Power Delay Profile - Plot
figure;
%subplot(2,1,1);
xlim([1 length(power_delay_profile)]);
plot(time, 10*log10(power_delay_profile), 'Color', [0.5 0.5 0.5]);
hold on;
%yline(10*log10(threshold_power), 'b--', 'LineWidth', 1.5);
xlabel("Time [s]");
ylabel("Power [dB]");
title("Log Channel Power Delay Profile ");
grid on;
% Power Delay Profile - Delay Spread
%subplot(2,1,2);
%plot(10*log10(power_delay_profile), 'LineWidth', 1.5);
%hold on;
%plot(taps_indices, 10*log10(power_delay_profile(taps_indices)), 'ro', 'MarkerSize', 8);
%xline(taps_indices(1), 'g--', 'LineWidth', 1.5);
%xline(taps_indices(end), 'r--', 'LineWidth', 1.5);
%xlabel('Delay (samples)');
%ylabel('Power [dB]');
%title('Power Delay Profile with Delay Spread Markers');
%legend('PDP', 'Significant Taps', 'First Tap', 'Last Tap');
%grid on;

end

