%% applySpeedUp.m
% This function uses the Audio Degradation Toolbox (ADT) available at
% <https://code.soundsoftware.ac.uk/projects/audio-degradation-toolbox>

function [dataNew, fs] = applySpeedUp(nummp3, minPercentChange, maxPercentChange, fs)
%  APPLYSPEEDUP function for time stretching/compression of the audio signal
%   dataset nummp3.
%   Each audio signal is resampled at a specified sampling
%   rate and returned using the original sampling rate
%   Input
%   nummp3: raw audio signal
%   minPercentChange: minimum percentual increase (or decrease) in the speed
%   maxPercentChange: maximum percentual increase (or decrease) in the speed
%   fs: frequencies of the audio signals. Not required if nummp3 contains
%       the audio paths.
%
%   Output
%   dataNew: new audio signal
%   fs: new frequencies
%
%   The original function degradationUnit_applySpeedup.m is included in 
%   ./tools/audio/audio-degradation-toolbox/
%
%   The original publication and additional information are available at
%   https://zenodo.org/record/1415862 and
%   https://code.soundsoftware.ac.uk/projects/audio-degradation-toolbox

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
    % Set the parameters for the speedup
    paramSpeed{j} = struct();
    paramSpeed{j}.changeInPercent = minPercentChange + rand() * (maxPercentChange - minPercentChange);
end

if singleInput
    dataNew=degradationUnit_applySpeedup(data{1}, fs{1}, [], paramSpeed{1});
    fs = fs{1};
else
    parfor j=1:length(nummp3)
        dataNew{j}=degradationUnit_applySpeedup(data{j}, fs{j}, [], paramSpeed{j});
    end
end

end
