function [f_audio_out,timepositions_afterDegr] = degradationUnit_applyWowResampling(f_audio, samplingFreq, timepositions_beforeDegr, parameter)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Name: degradation_applyWowResampling
% Date of Revision: 2013-03
% Programmer: Sebastian Ewert
%
% Description:
% - This is useful for wow and flutter simulations.
% - a playback speed of 1 is modulated by a cos signal via
%   f(x) = a_m * cos(2*pi*f_m*x)+1
% - the function mapping a position in the original recording
%   to a position in the generated recording:
%   F(x) = x + a_m * sin(2*pi*f_m*x) / (2*pi*f_m)
% - an optimal solution now would employ a sinc reconstruction of f_audio,
%   sinc_fa, and sampling sinc_fa(F^-1(y)) equidistantly.
% - This implementation employs only an approximation by first upsampling
%   f_audio and then sampling that using nearest neighbors
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
%   .intensityOfChange = 1.5    - a_m = parameter.intensityOfChange/100; stay below 100
%   .frequencyOfChange = 0.5    - f_m
%   .upsamplingFactor = 5       - the higher the better the quality (and the more memory)
%   .normalizeOutputAudio = 0   - normalize audio
%
% Output:
%   f_audio_out   - audio signal \in [-1,1]^{NxC} with C being the number
%                   of channels
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

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

if isfield(parameter,'intensityOfChange')==0
    parameter.intensityOfChange = 1.5;      % a_m = parameter.intensityOfChange/100;   %stay below 100
end
if isfield(parameter,'frequencyOfChange')==0
    parameter.frequencyOfChange = 0.5;  % f_m
end
if isfield(parameter,'upsamplingFactor')==0
    parameter.upsamplingFactor = 5;  % the higher the better the quality (and the more memory)
end
if isfield(parameter,'normalizeOutputAudio')==0
    parameter.normalizeOutputAudio = 0;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Main program
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fs = samplingFreq;
fsOverSampled = fs * parameter.upsamplingFactor;
a_m = parameter.intensityOfChange / 100;
f_m = parameter.frequencyOfChange;

f_audio_out = f_audio;
if ~isempty(f_audio)
    numSamples = size(f_audio,1);
    numChannels = size(f_audio,2);
    length_sec = numSamples/fs;
    numFullPeriods = floor(length_sec * f_m);
    numSamplesToWarp = round(numFullPeriods *fs / f_m);
    
    oldSamplePositions_to_newOversampledPositions = round(timeAssignment_newToOld([1:numSamplesToWarp]/fs,a_m,f_m)*fsOverSampled);
    
    for ch=1:numChannels
        audioUpsampled = resample(f_audio(:,ch),parameter.upsamplingFactor,1);
        
        f_audio_out(1:numSamplesToWarp,ch) = audioUpsampled(oldSamplePositions_to_newOversampledPositions);
        
        clear audioUpsampled
    end
    
    if parameter.normalizeOutputAudio
        f_audio_out = adthelper_normalizeAudio(f_audio_out, samplingFreq);
    end
    
end

%pitchShifted_semitones = getPitchShiftAtPositionsInNewFile([0:0.1:length_sec],a_m,f_m);  % not used yet but might be useful later on

%selftest(length_sec,a_m,f_m);

% This degradation does impose a complex temporal distortion
timepositions_afterDegr = [];
if ~isempty(timepositions_beforeDegr)
    timepositions_afterDegr = timeAssignment_oldToNew(timepositions_beforeDegr,a_m,f_m);
end

end


function timeAssigned = timeAssignment_oldToNew(x,a_m,f_m)
% vectorized

timeAssigned = x + a_m * sin(2*pi*f_m*x) / (2*pi*f_m);

end

function timeAssigned = timeAssignment_newToOld(y,a_m,f_m)
% vectorized
% SE: non linear equation: solved numerically (we are lucky:
% As G(x) := x - (F(x)-y) is a contraction for a_m<1 we can simply employ the Banach fixpoint theorem)

timeAssigned = y;
for k=1:40
    timeAssigned = y - a_m * sin(2*pi*f_m*timeAssigned) / (2*pi*f_m);
end

end

function pitchShifted_semitones = getPitchShiftAtPositionsInNewFile(y,a_m,f_m)
% vectorized

% maps times from new to old and takes a look at the value of the derivative
% there

timeAssigned = timeAssignment_newToOld(y,a_m,f_m);

derivative = 1 + a_m * cos(2*pi*f_m*timeAssigned);

pitchShifted_semitones = log2(1./derivative)*12;

end

function selftest(length_sec,a_m,f_m)

x0 = rand(10000,1) * length_sec;

timeAssigned1 = timeAssignment_oldToNew(x0,a_m,f_m);
timeAssigned2 = timeAssignment_newToOld(timeAssigned1,a_m,f_m);

figure;
plot(x0 - timeAssigned2);

end






