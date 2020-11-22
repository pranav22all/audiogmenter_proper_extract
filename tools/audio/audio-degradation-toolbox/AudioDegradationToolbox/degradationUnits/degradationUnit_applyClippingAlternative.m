function [f_audio_out,timepositions_afterDegr] = degradationUnit_applyClippingAlternative(f_audio, samplingFreq, timepositions_beforeDegr, parameter)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Name: degradation_applyClippingAlternative
% Date: 2013-04
% Programmer: Sebastian Ewert
%
% Description:
% - applies clipping by over-normalising
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
%   .clipAPercentageOfSamples = 1    - if set to zero a fixed number of
%                                      samples will be clipped
%   .parameter.percentOfSamples = 1  - used only if clipAPercentageOfSamples
%                                      is 1
%   .parameter.numSamplesClipped = 1 - used only if clipAPercentageOfSamples
%                                      is 0
%   timepositions_beforeDegr - some degradations delay the input signal. If
%                              some points in time are given via this
%                              parameter, timepositions_afterDegr will
%                              return the corresponding positions in the
%                              output
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

if isfield(parameter,'clipAPercentageOfSamples')==0
    parameter.clipAPercentageOfSamples = 1;
end
if isfield(parameter,'percentOfSamples')==0
    parameter.percentOfSamples = 1;
end
if isfield(parameter,'numSamplesClipped')==0
    parameter.numSamplesClipped = 10000;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Main program
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

f_audio_out = [];
if ~isempty(f_audio)
    sortedValues = sort(abs(f_audio(:)));
    numSamples = length(sortedValues);
    if parameter.clipAPercentageOfSamples
        idxStartSample = round( (1-parameter.percentOfSamples/100) * numSamples);
        divisor = min(sortedValues(idxStartSample:numSamples));
    else
        if parameter.numSamplesClipped > numSamples
            numSamplesClipped = numSamples;
        else
            numSamplesClipped = parameter.numSamplesClipped;
        end
        divisor = min(sortedValues(numSamples-numSamplesClipped+1:numSamples));
    end
    clear sortedValues
    
    divisor = max(divisor,eps);
    f_audio_out = f_audio / divisor;
    
    f_audio_out(f_audio_out < -1) = -1;
    f_audio_out(f_audio_out > 1) = 1;
    f_audio_out = f_audio_out * 0.999;
    
end

% This degradation does not impose a delay
timepositions_afterDegr = timepositions_beforeDegr;

end
