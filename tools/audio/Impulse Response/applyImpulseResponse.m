%% applyImpulseResponse.m
% This function uses the Audio Degradation Toolbox (ADT) available at
% <https://code.soundsoftware.ac.uk/projects/audio-degradation-toolbox>

function [dataNew, fs]  = applyImpulseResponse(nummp3, impulseResponses, fs)
%   APPLYIMPULSERESPONSE is a method that modifies each audio signal in nummp3
%   applying a FIR filter.
%   Input
%   nummp3: raw audio signal
%   impulseResponse: type of impulse response
%   fs: frequencies of the audio signals. Not required if nummp3 contains
%       the audio paths.
%
%   Output
%   dataNew: perturbed audio signal
%   fs: new frequencies
%
%   The original function degradationUnit_applyImpulseResponse.m is included in
%   ./tools/audio/audio-degradation-toolbox/

%sets the inpulseResponse.
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

if length(impulseResponses) == 0
    impulseResponses = {'GreatHall1',...
        'Classroom1',...
        'Octagon1',...
        'GoogleNexusOneFrontSpeaker',...
        'GoogleNexusOneFrontMic',...
        'VinylPlayer1960'};
end

parfor j=1:nSamples
    % Check whether the input must be read
    if flag
        [data{j},fs{j}]=audioread(nummp3(j).name);
    end
    % Set the parameters for the aliasing
    num{j} = randi(length(impulseResponses));
    paramHarmonicDistortion{j} = setParameterImpulseResponse(impulseResponses{num{j}});
end

if singleInput
    dataNew = degradationUnit_applyImpulseResponse(data{1}, fs{1}, [], paramHarmonicDistortion{1});
    fs = fs{1};
else
    parfor j=1:length(nummp3)
        dataNew{j} = degradationUnit_applyImpulseResponse(data{j}, fs{j}, [], paramHarmonicDistortion{j});
    end
end

end