function plot_constellation(signal, plot_title)
    % Plot signal Constellation
    figure;
    scatter(real(signal), imag(signal), 'filled');
    title(char(plot_title));
    xlabel('Real');
    ylabel('Imaginary');
    grid on;
    axis equal;

end
