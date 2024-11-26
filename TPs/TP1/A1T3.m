SNR_range = -6:2:12;
L = 1e4;

rng(123)

% Initialize
BER_list_Gray = zeros(size(SNR_range));
BER_list_NonGray = zeros(size(SNR_range));
    

gray_map = (1/sqrt(2))*[-1-1i, -1+1i, 1-1i, 1+1i];
non_gray_map = (1/sqrt(2))*[1-1i, 1+1i, -1+1i, -1-1i];


    
for ii = 1:numel(SNR_range) 
    % Convert SNR from dB to linear
    SNRlin = 10^(SNR_range(ii)/10);
    
    % Generate source bitstream
    source = randi([0 1],L,2);
       
    % Map input bitstream using Gray mapping
    mappedGray = mapGrayfunc(source, gray_map);

      
    % Add AWGN
    mappedGrayNoisy = add_awgn_solution(mappedGray, SNRlin);
        
    % Demap
    [~,ind] = min((ones(L,4)*diag(gray_map) - diag(mappedGrayNoisy)*ones(L,4)),[],2);

    demappedGray = de2bi(ind-1, 'left-msb');
    if ii == 1
        demappedGray_record = demappedGray;
    end
        
    % BER calculation for Gray mapping
    BER_list_Gray(ii) = mean(source(:) ~= demappedGray(:));
        
    % Map input bitstream using non-Gray mapping
    sources_nongray_indices = bi2de(source, 'left-msb') + 1;
    mappedNonGray = non_gray_map(sources_nongray_indices);
    if ii == 1
        mappedNonGray_record = mappedNonGray;
    end
          
          
    % Add AWGN
    mappedNonGrayNoisy = add_awgn_solution(mappedNonGray, SNRlin);
        
    % Demap
    diff_nonGray_NoisyNonGray = ones(L,4)*diag(non_gray_map) - diag(mappedNonGrayNoisy)*ones(L,4);
    [~,ind] = min(diff_nonGray_NoisyNonGray, [], 2);
    demappedNonGray = de2bi(ind-1,'left-msb');
    if ii == 1
        demappedNonGray_record = demappedNonGray;
    end
        
    % BER calculation for Gray mapping
    BER_list_NonGray(ii) = mean(source(:) ~= demappedNonGray(:));
end


% graphical ouput
figure;
semilogy(SNR_range, BER_list_Gray, 'bx-' ,'LineWidth',3)

hold on
semilogy(SNR_range, BER_list_NonGray, 'r*--','LineWidth',3);
xlabel('SNR (dB)')
ylabel('BER')
legend('Gray Mapping', 'Non-Gray Mapping')
grid on


% optional: you can write your function for Map/Demap here
function mappedGray = mapGrayfunc(source, gray_map)
    % Map input bitstream using Gray mapping
    source_index = bi2de(source, 'left-msb')+1; %first element 1 not 0
    mappedGray = gray_map(source_index).'; %transpose
end
%function output = demapGrayfunc(input)
%end