%% applyClipping.m
% This function uses the Audio Degradation Toolbox (ADT) available at
% <https://code.soundsoftware.ac.uk/projects/audio-degradation-toolbox>

function [dataNew, fs]  = applyClipping(nummp3, minPercentOfSamples, maxPercentOfSamples, fs)
%  APPLYCLIPPING, for each signal in nummp3, normalizes the audio signal leaving
%   a percent of the samples out of [-1;1]. The out-of-range samples x are
%   clipped to sign(x).
%   Input
%   nummp3: raw audio signal
%   minPercentOfSamples: minimum percent of the samples out of [-1;1]
%   maxPercentOfSamples: maximum percent of the samples out of [-1;1]
%   fs: frequencies of the audio signals. Not required if nummp3 contains
%       the audio paths.
%
%   Output
%   dataNew: the clipped audio signal
%   fs: new frequencies
%
%   The original function degradationUnit_applyClippingAlternative.m is
%   included in ./tools/audio/audio-degradation-toolbox/
%
%   The original publication and additional information are available at
%   https://zenodo.org/record/1415862 and
%   https://code.soundsoftware.ac.uk/projects/audio-degradation-toolbox

% Sets the percent of samples to clip

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
    paramClipping{j} = struct();
    paramClipping{j}.dsFrequency = minPercentOfSamples + floor(rand() * (maxPercentOfSamples - minPercentOfSamples));
end

if singleInput
    dataNew = degradationUnit_applyClippingAlternative(data{1}, fs{1}, [], paramClipping{1});
    fs = fs{1};
else
    parfor j=1:length(nummp3)
        dataNew{j} = degradationUnit_applyClippingAlternative(data{j}, fs{j}, [], paramClipping{j});
    end
end
end
