%% applyWowResampling.m
% This function uses the Audio Degradation Toolbox (ADT) available at
% <https://code.soundsoftware.ac.uk/projects/audio-degradation-toolbox>

function [dataNew, fs]  = applyWowResampling(nummp3, parameter, fs)      
%  APPLYWOWRESAMPLING maps a position in the original audio signal to a position
%   in the new signal, for each signal included in the audio signal dataset
%   nummp3.
%   This is useful for flutter simulations.
%   Each audio signal is resampled at a time-dependent sampling rate
%   oscillating around the original sampling rate at a specified frequency
%   and amplitude.
%   Input
%   nummp3: raw audio signal
%   parameter
%   -minIntensityOfChange: minimum percentage of the change on a 0 to 100 scale
%   -maxIntensityOfChange: maximum percentage of the change on a 0 to 100 scale
%   -minFrequencyOfChange: minimum frequency of the resampling
%   -maxFrequencyOfChange: maximum frequency of the resampling
%   fs: frequencies of the audio signals. Not required if nummp3 contains
%       the audio paths.
%
%   Output
%   dataNew: new audio signal
%   fs: new frequencies
%
%   The original function degradationUnit_applyWowResampling.m is included
%   in ./tools/audio/audio-degradation-toolbox/
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

for j=1:nSamples
    % Check whether the input must be read
    if flag
        [data{j},fs{j}]=audioread(nummp3(j).name);
    end
    % Set the parameters for the aliasing
    paramWow{j} = struct();
    paramWow{j}.intensityOfChange = parameter.minIntensityOfChange + rand() * (parameter.maxIntensityOfChange - parameter.minIntensityOfChange);
    paramWow{j}.frequencyOfChange = parameter.minFrequencyOfChange + floor(rand() * (parameter.maxFrequencyOfChange - parameter.minFrequencyOfChange));
end

if singleInput
    dataNew=degradationUnit_applyWowResampling(data{1}, fs{1}, [], paramWow{1});
    fs = fs{1};
else
    parfor j=1:length(nummp3)
        dataNew{j}=degradationUnit_applyWowResampling(data{j}, fs{j}, [], paramWow{j});
    end
end

end
