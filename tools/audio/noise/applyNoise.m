%% applyNoise.m
% This function uses the Audio Degradation Toolbox (ADT) available at
% <https://code.soundsoftware.ac.uk/projects/audio-degradation-toolbox>

function [dataNew, fs]  = applyNoise(nummp3, minSnrRatio, maxSnrRatio, fs)
%  APPLYNOISE adds white noise on each of the audio signals in the dataset
%   nummp3
%   Input
%   nummp3: raw audio signal
%   minSnrRatio: minimum sigma of the noise expressed in dB
%   maxSnrRatio: maximum sigma of the noise expressed in dB
%   fs: frequencies of the audio signals. Not required if nummp3 contains
%       the audio paths.
%
%   Output
%   dataNew: noisy audio signal
%   fs: new frequencies
%
%   The original function degradationUnit_addNoise.m is included in
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
    % Set the parameters for the noise
    paramNoise{j} = struct();
    paramNoise{j}.snrRatio = minSnrRatio + floor(rand() * (maxSnrRatio - minSnrRatio));
    % Selects noise type
    paramNoise{j}.noiseColor = 'white';
end

if singleInput
    dataNew = degradationUnit_addNoise(data{1}, fs{1}, [], paramNoise{1});
    fs = fs{1};
else
    parfor j=1:length(nummp3)
        [dataNew{j}] = degradationUnit_addNoise(data{j}, fs{j}, [], paramNoise{j});
    end
end

end
