function b = QPSK_demapper(a)

QPSK_Map = (1/sqrt(2)) * [(-1-1j) (-1+1j) ( 1-1j) ( 1+1j)];
[~, ind] = min(a-QPSK_Map,[],2);
b = de2bi(ind-1, 'left-msb');
b = b(:);
end