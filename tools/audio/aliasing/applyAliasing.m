%% applyAliasing.m
% This function uses the Audio Degradation Toolbox (ADT) available at
% <https://code.soundsoftware.ac.uk/projects/audio-degradation-toolbox>

function [dataNew, fs]  = applyAliasing(nummp3, dsFrequencyMin, dsFrequencyMax, fs)
%  APPLYALIASING applies aliasing to the audio signal dataset nummp3.
%   Each audio signal is down-sampled to a specified sampling rate without lowpass filtering.
%
%   Input
%   nummp3: raw audio signal (audio paths, cell of the signals or single signal)
%   dsFrequencyMin: minimum down-sampling frequency for the new audio signals
%   dsFrequencyMax: maximum down-sampling frequency for the new audio signals
%   fs: frequencies of the audio signals. Not required if nummp3 contains
%       the audio paths.
%
%   Output
%   dataNew: the new audio signals
%   fs: new frequencies
%
%   The original sampling rate is restored using a regular resampling method.
%   The original function degradationUnit_applyAliasing.m is included in
%   ./tools/audio/audio-degradation-toolbox/
%
%   The original publication and additional information are available at
%   https://zenodo.org/record/1415862 and
%   https://code.soundsoftware.ac.uk/projects/audio-degradation-toolbox

% Sets the down-sampling frequency for the new audio signal

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

for j=1:nSamples
    % Check whether the input must be read
    if flag
        [data{j},fs{j}]=audioread(nummp3(j).name);
    end
    % Set the parameters for the aliasing
    paramAliasing{j} = struct();
    paramAliasing{j}.dsFrequency = dsFrequencyMin + floor(rand() * (dsFrequencyMax - dsFrequencyMin));
end

if singleInput
    dataNew = degradationUnit_applyAliasing(data{1}, fs{1}, [], paramAliasing{1});
    fs = fs{1};
else
    parfor j=1:length(nummp3)
        dataNew{j} = degradationUnit_applyAliasing(data{j}, fs{j}, [], paramAliasing{j});
    end
end
end
