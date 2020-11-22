function [f_audio_out,timepositions_afterDegr] = degradationUnit_applyAliasing(f_audio, samplingFreq, timepositions_beforeDegr, parameter)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Name: degradation_applyAliasing
% Version: 1
% Date: 2013-01-23
% Programmer: Matthias Mauch
%
% Description:
% - downsamples without filtering, then upsamples again using S&H
%
% Input:
%   f_audio      - audio signal \in [-1,1]^{NxC} with C being the number of
%                  channels
%   samplingFreq - sampling frequency of f_audio
%   timepositions_beforeDegr - some degradations delay the input signal. If
%                             some points in time are given via this
%                             parameter, timepositions_afterDegr will
%                             return the corresponding positions in the
%                             output. Set to [] if unavailable. Set f_audio
%                             and samplingFreq to [] to compute only
%                             timepositions_afterDegr.
%
% Input (optional): parameter
%   .dsFrequency = 8000 - destination sampling frequency
%   .normalizeOutputAudio = 1 - peak normalize output audio
%
% Output:
%   f_audio      - audio output signal
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

if isfield(parameter,'dsFrequency')==0
    parameter.dsFrequency = 8000;
end
if isfield(parameter,'normalizeOutputAudio')==0
    parameter.normalizeOutputAudio = 1;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Main program
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

f_audio_out = [];
if ~isempty(f_audio)
    
    % We cannot employ resample as it always imposes a lowpass pass filter to
    % counter aliasing
    
    nSample = size(f_audio, 1);
    nSampleNew = round(nSample / samplingFreq * parameter.dsFrequency);
    
    tOld = (0:(nSample-1))/samplingFreq;
    tNew = (0:(nSampleNew-1))/parameter.dsFrequency;
    
    temp = interp1(tOld, f_audio, tNew, 'nearest');
    f_audio_out = resample(temp, samplingFreq, parameter.dsFrequency);
    
    if parameter.normalizeOutputAudio
        f_audio_out = adthelper_normalizeAudio(f_audio_out, samplingFreq);
    end
end

% This degradation does not impose a delay
timepositions_afterDegr = timepositions_beforeDegr;

end
