% Start time measurement
tic();

L= 1000000;
p = 0.2;

% Source: Generate random bits
txbits = randi([0 1],L,1);

% Mapping: Bits to symbols

tx = {};
for i=1:1000000
    if txbits(i) == 0
        tx{i} = 'A';
    else
        tx{i} = 'B';
    end
end

% Channel: Apply BSC
rx = {};
i = 1000000;
while i >= 1
    randval = rand(1);
    
    if randval < p
        switch tx{i}
            case 'A'
               rx{i} = 'B';
            case 'B'
               rx{i} = 'A'; 
        end
    else
        rx{i} = tx{i};
    end
    i = i - 1;
end

% Demapping: Symbols to bits
rxbits = [];
for i=1:1000000
    if rx{i} == 'A'
        rxbits(i) = 0;
    else
        rxbits(i) = 1;
    end
end

% BER: Count errors
errors = 0;
for i=1:1000000
    if rxbits(i) ~= txbits(i)
        errors = errors + 1;
    end
end

% Output result
err_rate = errors/1000000;
disp(['BER: ' num2str(err_rate*100) '%'])

% Stop time measurement
runTime = toc
