rng(123)
rx_filterlen_array  = [2 5 7 10 15 20];
for i = 1:length(rx_filterlen_array)
    rx_filterlen = rx_filterlen_array(i);
    [~, ~, ~, ~, ~, BER] = ex3_3_2(rx_filterlen);
    ber(i) = BER;
end

target = 7e-3;

best_length = rx_filterlen_array(find(ber - target<0, 1));

figure
semilogy(rx_filterlen_array,ber,'o-');