function [message] = decode_msg(rx_symb,const)
%DECODE_MSG extract the string encoded within the symbols provided
%   rx_symb: vector of symbols
%   const: the constellation to use to demap the symbols the message

% ensure rx_symb is a column vector
rx_symb = rx_symb(:);
%demodulate
[~,idx] = min(repmat(const,length(rx_symb),1)-repmat(rx_symb,1,length(const)),[],2);

%recover data bytes
bytes = reshape(de2bi(idx-1).',8,[]).';

%recoder ASCII string
message= reshape(char(bi2de(bytes,'left-msb')),1,[]);    
end

