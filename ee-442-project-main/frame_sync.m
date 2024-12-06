% EE-442 Wireless Receivers : algorithms and architectures
% Final Project : OFDM Audio Transmission System
% Authors : Palmisano Fabio, Riber Rafael

function beginning_of_data = frame_sync(rx_signal, L, frame_sync_sequence, conf)

detection_threshold = conf.detection_threshold;
frame_sync_length = conf.npreamble;

for i = L * frame_sync_length + 1 : L : length(rx_signal)
    r = rx_signal(i - L * frame_sync_length : L : i - L); 
    c = frame_sync_sequence' * r;
    T = abs(c)^2 / abs(r' * r);
    
    if (T > detection_threshold)
        beginning_of_data = i;
        return;
    end
    
end

error('No synch sequence found.');
end
