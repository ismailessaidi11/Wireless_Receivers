function [beginning_of_data, phase_of_peak, magnitude_of_peak] = frame_sync(rx_signal, conf)

% Frame synchronizer.
% rx_signal is the noisy received signal, and L is the oversampling factor (L=1 in chapter 2, L=4 in all later chapters).
% The returned value is the index of the first data symbol in rx_signal.

if (rx_signal(1) == 0),
    warning('Signal seems to be noise-free. The frame synchronizer will not work in this case.');
    
end

detection_threshold = 10;
frame_sync_length = conf.npreamble;
magnitude_of_peak = 0;
L = conf.os_factor_preamble;

% Calculate the frame synchronization sequence (already mapped in BPSK)
frame_sync_sequence = preamble_generate(frame_sync_length);

% When processing an oversampled signal (L>1), the following is important:
% Do not simply return the index where T exceeds the threshold for the first time. Since the signal is oversampled, so will be the
% peak in the correlator output. So once we have detected a peak, we keep on processing the next L samples and return the index
% where the test statistic takes on the maximum value.
% The following two variables exist for exactly this purpose.
current_peak_value = 0;
samples_after_threshold = L;

for i = L * frame_sync_length + 1 : length(rx_signal)
    r = rx_signal(i - L * frame_sync_length : L : i - L); % The part of the received signal that is currently inside the correlator.
    c = frame_sync_sequence' * r;
    T = abs(c)^2 / abs(r' * r);
    
    if (T > detection_threshold || samples_after_threshold < L)
        samples_after_threshold = samples_after_threshold - 1;
        if (T > current_peak_value)
            beginning_of_data = i;
            phase_of_peak = mod(angle(c),2*pi);
            %TODO
            magnitude_of_peak =abs(c)/frame_sync_length;

            current_peak_value = T;
        end
        if (samples_after_threshold == 0)
            return;
        end
    end
    
end
beginning_of_data = -1;
phase_of_peak=0;
magnitude_of_peak=0;
warning('No synchronization sequence found.');
return;