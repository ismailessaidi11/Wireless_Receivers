SNR_range = -6:2:12;
L = 1e4;

rng(123)

% Initialize
BER_list_Gray = zeros(size(SNR_range));
BER_list_NonGray = zeros(size(SNR_range));
    




    
for ii = 1:numel(SNR_range) 
    % Convert SNR from dB to linear
    SNRlin = 10^(SNR_range(ii)/10)
    
    % Generate source bitstream
    source = randi([0 1],L,2);
       
    % Map input bitstream using Gray mapping
    mappedGray = bi2de(source,'left-msb');
    for j = 1:numel(mappedGray)
        if mappedGray(j) ==  0
            mappedGray(j) = (-1 - 1i)/(sqrt(2));
        elseif mappedGray(j)  == 1
            mappedGray(j) = (-1 + 1i)/(sqrt(2));
        elseif mappedGray(j) == 2 
            mappedGray(j) = (1 - 1i)/(sqrt(2));
        else 
            mappedGray(j) = (1 + 1i)/(sqrt(2));
        end
    end 
 
    if ii == 1
        mappedGray_record = mappedGray;
    end
      
    % Add AWGN
    mappedGrayNoisy = add_awgn_solution(mappedGray, SNRlin);
        
    % Demap
    demap = mappedGrayNoisy;
    z_z = (-1 - 1i)/(sqrt(2));
    z_o = (-1 + 1i)/(sqrt(2));
    o_z = (1 - 1i)/(sqrt(2));
    o_o = (1 + 1i)/(sqrt(2));
    
    for z = 1:numel(demap)
        a = abs(demap(z)-z_z);
        b = abs(demap(z)-z_o);
        c = abs(demap(z)-o_z);
        d = abs(demap(z)-o_o);
        minimum = min([a b c d]);

        if minimum == a
            demap(z) = 0;
        elseif minimum == b 
            demap(z) = 1;
        elseif minimum == c
            demap(z) = 2;
        elseif minimum == d 
            demap(z) = 3;
        end
    end
    demap;
    demappedGray = de2bi(demap,'left-msb');
    size(demappedGray)
    if ii == 1
        demappedGray_record = demappedGray;
    end
        
    % BER calculation for Gray mapping
    BER_list_Gray(ii) = mean(source(:) ~= demappedGray(:));
        
    % Map input bitstream using non-Gray mapping
        % Map input bitstream using Gray mapping
    mappedNonGray = bi2de(source,'left-msb');
    for j = 1:numel(mappedNonGray)
        if mappedNonGray(j) ==  0
            mappedNonGray(j) = (1 - 1i)/(sqrt(2));
        elseif mappedNonGray(j)  == 1
            mappedNonGray(j) = (1 + 1i)/(sqrt(2));
        elseif mappedNonGray(j) == 2 
            mappedNonGray(j) = (-1 + 1i)/(sqrt(2));
        else 
            mappedNonGray(j) = (-1 - 1i)/(sqrt(2));
        end
    end 
    
    if ii == 1
        mappedNonGray_record = mappedNonGray;
    end
          
          
    % Add AWGN
    mappedNonGrayNoisy = add_awgn_solution(mappedNonGray, SNRlin);
        
    % Demap
        % Demap
    demapNG = mappedNonGrayNoisy;
    z_zNG = (1 - 1i)/(sqrt(2));
    z_oNG = (1 + 1i)/(sqrt(2));
    o_zNG = (-1 + 1i)/(sqrt(2));
    o_oNG = (-1 - 1i)/(sqrt(2));
    
    for z = 1:numel(demapNG)
        aNG = abs(demapNG(z)-z_zNG);
        bNG = abs(demapNG(z)-z_oNG);
        cNG = abs(demapNG(z)-o_zNG);
        dNG = abs(demapNG(z)-o_oNG);
        minimumNG = min([aNG bNG cNG dNG]);

        if minimumNG == aNG
            demapNG(z) = 0;
        elseif minimumNG == bNG 
            demapNG(z) = 1;
        elseif minimumNG == cNG
            demapNG(z) = 2;
        elseif minimumNG == dNG
            demapNG(z) = 3;
        end
    end
   
   
    demappedNonGray = de2bi(demapNG,'left-msb');
    if ii == 1
        demappedNonGray_record = demappedNonGray;
    end
        
    % BER calculation for Gray mapping
    BER_list_NonGray(ii) = mean(source(:) ~= demappedNonGray(:));
 end


% uncomment this part for plot
% graphical ouput
figure;
semilogy(SNR_range, BER_list_Gray, 'bx-' ,'LineWidth',3)

hold on
semilogy(SNR_range, BER_list_NonGray, 'r*--','LineWidth',3);

xlabel('SNR (dB)')
ylabel('BER')
legend('Gray Mapping', 'Non-Gray Mapping')
grid on


%% optional: you can write your function for Map/Demap here
% function output = mapGrayfunc(input)
% end
% function output = demapGrayfunc(input)
% end