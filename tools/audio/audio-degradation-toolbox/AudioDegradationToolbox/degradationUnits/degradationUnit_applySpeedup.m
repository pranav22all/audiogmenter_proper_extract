function [f_audio_out,timepositions_afterDegr] = degradationUnit_applySpeedup(f_audio, samplingFreq, timepositions_beforeDegr, parameter)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Name: degradation_applySpeedup
% Version: 1
% Date: 2013-01-23
% Programmer: Sebastian Ewert
%
% Description:
% - changes the playback speed of f_audio via resampling
% - change is specified in percent:
%   total length of f_audio after the degradation is
%   (100 - parameter.changeInPercent)/100 * originalLength
% - positive values lead to a speed-up, while negative values lead to a
%   slow-down
% - Note: Frequencies are shifted to 100/(100 - parameter.changeInPercent),
%   i.e. the default of parameter.changeInPercent = +3 shifts all
%   frequencies by about half a semitone
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
%   .changeInPercent = +3  - see description
%   .normalizeOutputAudio = 1     - normalize output
%
% Output:
%   f_audio_out   - audio signal \in [-1,1]^{NxC} with C being the number
%                   of channels
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

if isfield(parameter,'changeInPercent')==0
    parameter.changeInPercent = +3;
end
if isfield(parameter,'normalizeOutputAudio')==0
    parameter.normalizeOutputAudio = 1;
end
if isfield(parameter,'maxProblemComplexity')==0
    % lower this if you run into 'reduce problem complexity' problems
    parameter.maxProblemComplexity = 2^27;  % limit defined in resample: 2^31, however, that is still too large
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Main program
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

f_audio_out = [];
if ~isempty(f_audio)     
    Q = round(sqrt(parameter.maxProblemComplexity * 100 / (100 - parameter.changeInPercent)));
    P = round(parameter.maxProblemComplexity / Q);
    
    f_audio_out = resample(f_audio,P,Q);
    
    if parameter.normalizeOutputAudio
        f_audio_out = adthelper_normalizeAudio(f_audio_out, samplingFreq);
    end
end

% This degradation does impose a temporal distortion
timepositions_afterDegr = (100 - parameter.changeInPercent)/100 * timepositions_beforeDegr;

end
