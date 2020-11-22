%% applyHarmonicDistortion.m
% This function uses the Audio Degradation Toolbox (ADT) available at
% <https://code.soundsoftware.ac.uk/projects/audio-degradation-toolbox>

function [dataNew, fs]  = applyHarmonicDistortion(nummp3, nApplications, fs)
%  APPLYHARMONICDISTORTION applies quadratic distortion to each audio signal in
%   nummp3.
%   The original function degradationUnit_applyHarmonicDistortion.m is
%   included in ./tools/audio/audio-degradation-toolbox/
%   Input
%   nummp3: raw audio signal (audio paths, cell of the signals or single signal)
%   nApplications: number of applications of the deformations
%   fs: frequencies of the audio signals. Not required if nummp3 contains
%       the audio paths.
%
%   Output
%   dataNew: new audio signals
%   fs: new frequencies
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
    % Set the parameters for the aliasing
    paramHarmonicDistortion{j} = struct();
    paramHarmonicDistortion{j}.nApplications = nApplications;
end

if singleInput
    dataNew = degradationUnit_applyHarmonicDistortion(data{1}, fs{1}, [], paramHarmonicDistortion{1});
    fs = fs{1};
else
    parfor j=1:length(nummp3)
        dataNew{j} = degradationUnit_applyHarmonicDistortion(data{j}, fs{j}, [], paramHarmonicDistortion{j});
    end
end
end