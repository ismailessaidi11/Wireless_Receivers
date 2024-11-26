% Start time measurement
tStart = tic;
tic
rng(123);
L = 1000000;
% source: Generate random bits
txbits = randi([0,1], L, 1);
p = 0.2;
% map
tx = txbits*2-1;
% channel
flip = (rand(L,1)>p)*2-1;
rx = tx.*flip;
% demap
rxbits = (rx+1)/2;

% BER
err = sum(rxbits ~= txbits);
err_rate = err/L;

% Output result
disp(['BER: ' num2str(err_rate*100) '%'])

% Stop time measurement
runTime = toc