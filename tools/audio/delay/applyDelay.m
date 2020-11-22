%% applyDelay.m
% This function uses the Audio Degradation Toolbox (ADT) available at
% <https://code.soundsoftware.ac.uk/projects/audio-degradation-toolbox>

function [dataNew, fs]  = applyDelay(nummp3, minDelay, maxDelay, fs)
%  APPLYDELAY is a  method to delay each audio signal in nummp3.
%  The delay is expressed in number of samples, i.e: delay = fs leads to 
%  a one second delay.
%   Input
%   nummp3: raw audio signal
%   minDelay: minimum number of zeros at the beginning of the new signals
%   maxDelay: maximum number of zeros at the beginning of the new signals
%   fs: frequencies of the audio signals. Not required if nummp3 contains
%       the audio paths.
%
%   Output
%   dataNew: delayed audio signal
%   fs: new frequencies
%
%   The original sampling rate is restored using a regular resampling method.
%   The original function degradationUnit_applyDelay.m is included in
%   ./tools/audio/audio-degradation-toolbox/

% Initialize data and the parameter
if isa(nummp3,'struct')
    singleInput = false;
    nSamples = length(nummp3);
    flag = true;
elseif isa(nummp3,'cell')
    flag = false;
    nSamples = length(nummp3);
    singleInput = false;
    data = nummp3;
else      %the data is a single signal
    flag = false;
    singleInput = true;
    data = {nummp3};
    fs = {fs};
    nSamples = 1;
end

parfor j=1:nSamples
    % Check whether the input must be read
    if flag
        [data{j},fs{j}]=audioread(nummp3(j).name);
    end
    % Set the parameters for the delay
    parameter{j} = struct();
    parameter{j}.nSample = minDelay + floor(rand() * (maxDelay - minDelay));
end

if singleInput
    dataNew = degradationUnit_applyDelay(data{1}, fs{1},[], parameter{1});
    fs = fs{1};
else
    parfor j=1:length(nummp3)
        dataNew{j} = degradationUnit_applyDelay(data{j}, fs{j},[], parameter{j});
    end
end
end