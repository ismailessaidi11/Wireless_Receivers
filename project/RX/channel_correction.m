function corrected_signal = channel_correction(signal,phase_of_peak,magnitude_of_peak)
% channel estimation and correction

h = magnitude_of_peak*exp(1j*phase_of_peak);
corrected_signal = conj(h)/norm(h)^2*signal;
end

