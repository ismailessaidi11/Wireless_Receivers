const_blue = [-6-6i,-3i,3i,-3,3,6+6i];
const_red  = [-3-3i,-3+3i,3-3i,3+3i];
% Calculate here:



average_energy_blue = sum(abs(const_blue).^2)/length(const_blue);
 

average_energy_red = sum(abs(const_red).^2)/length(const_red);

%normalized the constellation (we expect value with size(1, 6))
const_blue_norm = const_blue / average_energy_blue
    
const_red_norm = const_red / average_energy_red

%plot normalized constellations
plot(const_blue,'bo'),hold on,grid on
plot(const_red,'ro')
plot(const_blue_norm,'bx')
plot(const_red_norm,'rx')

legend("const A","const B","const A normalized","const B normalized")
% 3.2 observations
%
