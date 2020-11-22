function [f_audio_out,timepositions_afterDegr] = applyDegradation(degradationname, f_audio, samplingFreq, timepositions_beforeDegr)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Name: applyDegradation
% Date of Revision: 2013-04
% Programmer: Sebastian Ewert
%
% Description:
% - in the ADT, (high-level) degradations are usually combinations of several
%   degradation units, using specific parameters
% - the "degradations" directory contains various degradations. They look like this:
%   ----------------------------------------------------------------%   
%   degradation_config(1).methodname = 'degradationUnit_applyImpulseResponse';
%   degradation_config(1).parameter.loadInternalIR = 1;
%   degradation_config(1).parameter.internalIR = 'GreatHall1';
%
%   degradation_config(2).methodname = 'degradationUnit_addNoise';
%   degradation_config(2).parameter.snrRatio = 40; % in dB
%   ----------------------------------------------------------------%   
% - This degradation specifies that f_audio should first be degraded using the
%   degradation unit degradationUnit_applyImpulseResponse and subsequently
%   using degradationUnit_addNoise. This works like a chain
% - To specify which degradation to use simply set degradationname accordingly.
% - If you specify timepositions_beforeDegr, then timepositions_afterDegr
%   will contain the corresponding time position in the output audio file.
%   Set f_audio=[] and samplingFreq=0 if you want to process only time
%   positions
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
% Output:
%   f_audio_out   - audio signal \in [-1,1]^{NxC} with C being the number
%                   of channels
%   timepositions_afterDegr - time positions corresponding to timepositions_beforeDegr
%                             after all degradations are applied
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

if nargin<4
    timepositions_beforeDegr=[];
end
if nargin<3
    error('Please specify the required input variables')
end

% the degradations are in a subdirectory called "degradations" of the folder this
% function is in
fullFilenameMfile = mfilename('fullpath');
[pathstr,name,ext] = fileparts(fullFilenameMfile);
dirDegradations = fullfile(pathstr,'degradations');

% add dirDegradations to matlab path if it is not included yet. Otherwise we
% cannot call the degradation functions
addpath(dirDegradations);

% retrieve the degradation configuration
degradationFunction = str2func(degradationname);
degradation_config = degradationFunction();

% traverse degradation_config and call all the degradation units specified in there
numDegradationUnits = length(degradation_config);
f_audio_out = f_audio;
timepositions_afterDegr = timepositions_beforeDegr;
for n=1:numDegradationUnits
    degradationFunction = str2func(degradation_config(n).methodname);
    [f_audio_out,timepositions_afterDegr] = degradationFunction(f_audio_out, samplingFreq, timepositions_afterDegr, degradation_config(n).parameter);
end

end







