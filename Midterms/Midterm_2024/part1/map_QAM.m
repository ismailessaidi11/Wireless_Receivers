function mapped_bitstream = map_QAM(bitstream, Map_norm)

    gray_code_map = [
        0 0 0 0;  % (-3 + 3j)
        0 0 0 1;  % (-3 + 1j)
        0 0 1 1;  % (-3 - 1j)
        0 0 1 0;  % (-3 - 3j)
        0 1 0 0;  % (-1 + 3j)
        0 1 0 1;  % (-1 + 1j)
        0 1 1 1;  % (-1 - 1j)
        0 1 1 0;  % (-1 - 3j)
        1 1 0 0;  % (3 + 3j)
        1 1 0 1;  % (3 + 1j)
        1 1 1 1;  % (3 - 1j)
        1 1 1 0;  % (3 - 3j)
        1 0 0 0;  % (1 + 3j)
        1 0 0 1;  % (1 + 1j)
        1 0 1 1;  % (1 - 1j)
        1 0 1 0   % (1 - 3j)
    ];
    % Map each 4-bit group to the corresponding index in Map_norm using Gray code
    symbol_indices = zeros(size(bitstream, 1), 1);
    for i = 1:size(bitstream, 1)
        for j = 1:16
            if isequal(bitstream(i, :), gray_code_map(j, :))
                symbol_indices(i) = j; % Found the matching Gray code index
                break;
            end
        end
    end
    
    % Map each index to the normalized 16-QAM symbol
    mapped_bitstream = Map_norm(symbol_indices);
end