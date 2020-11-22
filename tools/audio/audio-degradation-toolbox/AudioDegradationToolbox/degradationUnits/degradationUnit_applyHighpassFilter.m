function [f_audio_out,timepositions_afterDegr] = degradationUnit_applyHighpassFilter(f_audio, samplingFreq, timepositions_beforeDegr, parameter)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Name: degradation_applyHighpassFilter
% Date: 2013-04
% Programmer: Matthias Mauch
%
% Description:
% - applies a highpass filter to the audio
%
% Input:
%   f_audio      - audio signal \in [-1,1]^{NxC} with C being the number of
%                  channels
%   timepositions_beforeDegr - some degradations delay the input signal. If
%                             some points in time are given via this
%                             parameter, timepositions_afterDegr will
%                             return the corresponding positions in the
%                             output. Set to [] if unavailable. Set f_audio
%                             and samplingFreq to [] to compute only
%                             timepositions_afterDegr.
%
% Input (optional): parameter
%   .stopFrequency = 200     - stop band edge frequency in Hz
%   .passFrequency =         - pass band edge frequency in Hz,
%                              default is 2 x [stop band edge frequency]
%
% Output:
%   f_audio_out  - audio output signal
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Audio Degradation Toolbox
%
% Centre for Digital Music, Queen Mary University of London.
% This file copyright 2013 Sebastian Ewert, Matthias Mauch and QMUL.
%    
% This program is free software; you can redistribute it and/or
% modify it under the terms of the GNU General Public License as
% published by the Free Software Foundation; either version 2 of the
% License, or (at your option) any later version.  See the file
% COPYING included with this distribution for more information.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Check parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if nargin<4
    parameter=[];
end
if nargin<3
    timepositions_beforeDegr=[];
end
if nargin<2
    error('Please specify input data');
end

if isfield(parameter,'stopFrequency')==0
    parameter.stopFrequency = 200;
end
if isfield(parameter,'passFrequency')==0
    parameter.passFrequency = 2 * parameter.stopFrequency;
end

if parameter.stopFrequency > parameter.passFrequency
    error('Please choose a pass frequency greater than the stop frequency.');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Main program
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

f_audio_out = [];
if ~isempty(f_audio)
    
    omega_stop = parameter.stopFrequency / samplingFreq * 2 * pi; % stopband omega
    omega_pass = parameter.passFrequency / samplingFreq * 2 * pi; % passband omega
    transition_width = abs(omega_stop-omega_pass);
    
    lobe_width = 3.32;
    filter_order = ceil(lobe_width*pi/transition_width); % filter order via transition bandwidth (see lecture)
    
    
    filter_length = 2*filter_order + 1;
    
    n = 0:(filter_length-1);
    omega_cutoff = (omega_stop+omega_pass)/2; % cutoff frequency is mean of pass and stopband edges
    alpha = (filter_length-1)/2;
    m = n - alpha; % symmetricised indices
    
    hd = -omega_cutoff/pi * sinc(omega_cutoff/pi*m);
    hd(alpha+1) = hd(alpha+1) + 1;
    
    window = hamming(filter_length)';
    h = hd .* window;
    
    f_audio_out = fftfilt(h, [f_audio; zeros([filter_order, size(f_audio,2)])]);
    f_audio_out = f_audio_out((filter_order + 1):end, :);
    
    
    f_audio_out(f_audio_out < -1) = -1;
    f_audio_out(f_audio_out > 1) = 1;
    f_audio_out = f_audio_out * 0.999;
    
end

% This degradation has no delay.
timepositions_afterDegr = timepositions_beforeDegr;

end
