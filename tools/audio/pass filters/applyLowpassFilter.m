%% applyLowpassFilter.m
% This function uses the Audio Degradation Toolbox (ADT) available at
% <https://code.soundsoftware.ac.uk/projects/audio-degradation-toolbox>

function [dataNew, fs]  = applyLowpassFilter(nummp3, stopFrequency, passFrequency, fs)
%   APPLYLOWPASSFILTER is a method that stops every frequency below
%   stopFrequeny and attenuates every frequency between stopFrequency and
%   passFrequency of each audio signal in nummp3.
%   As a reference, audible frequencies range from 20 to 20.000 Hz.
%   Input
%   nummp3: raw audio signal
%   stopFrequency: highest passed frequency
%   passFrequency: lower bound of attenuated frequencies
%   fs: frequencies of the audio signals. Not required if nummp3 contains
%       the audio paths.
%
%   Output
%   dataNew: new audio signal
%   fs: new frequencies
%
%   The original sampling rate is restored using a regular resampling method.
%   The original function degradationUnit_applyLowPassFilter.m is included in
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
    % Set the parameters for the aliasing
end

parameter.stopFrequency = stopFrequency;
parameter.passFrequency = passFrequency;

if singleInput
    dataNew = degradationUnit_applyLowpassFilter(data{1}, fs{1}, [], parameter);
    fs = fs{1};
else
    parfor j=1:length(nummp3)
        dataNew{j} = degradationUnit_applyLowpassFilter(data{j}, fs{j}, [], parameter);
    end
end

end