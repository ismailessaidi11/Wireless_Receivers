% EE-442 Wireless Receivers : algorithms and architectures
% Final Project : OFDM Audio Transmission System
% Authors : Palmisano Fabio, Riber Rafael

function [filtered_signal] = ofdmlowpass(signal,conf,f)
% LOWPASS lowpass filter
% Low pass filter for extracting the baseband signal 
%
%   signal  : Unfiltered signal
%   conf    : Global configuration variable
%   f       : Corner Frequency
%
%   filtered_signal   : Filtered signal

filtered_signal = lowpass(signal,f,conf.f_s,StopbandAttenuation=30);
