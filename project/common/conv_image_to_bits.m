function [txbits, conf] = conv_image_to_bits(conf)
% Reads Image and converts it to bit stream

image_path = fullfile(conf.image_folder_path, conf.image); 
image = imread(image_path);

% Convert to grayscale
%if size(image, 3) == 3
%    image = rgb2gray(image);
%end
[conf.image_h, conf.image_w, conf.image_c] = size(image);

% Flatten the image into a 1D array
pixel_values = image(:);

% Convert each pixel value to an 8-bit binary string
txbits = dec2bin(pixel_values, 8);

% Convert the binary strings into a stream of bits
txbits = reshape(txbits.' - '0', [], 1); % 1xN array of bits
conf.nbits = length(txbits);
end

