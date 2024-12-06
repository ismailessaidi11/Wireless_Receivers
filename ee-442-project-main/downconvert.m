function downconverted_signal = downconvert(signal, conf)
%Downconversion to baseband
    t = 0:1/conf.f_s:(length(signal)-1)/conf.f_s;
    downconverted_signal= signal.* exp(-1i*2*pi*(conf.f_c*t'));
end