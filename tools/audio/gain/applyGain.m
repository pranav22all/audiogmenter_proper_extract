%% applyGain.m
function [dataNew, fs]  = applyGain(nummp3, minDecibel, maxDecibel, fs)
%   APPLYGAIN is a simple method to increase/decrease the gain of each audio
%   signal in nummp3 (useful for signals with low volume).
%   Input
%   nummp3: raw audio signal (audio paths, cell of the signals or single signals)
%   minDecibel: minimum size of the volume gain
%   maxDecibel: maximum size of the volume gain
%   fs: frequencies of the audio signals. Not required if nummp3 contains
%       the audio paths.
%
%   Output
%   dataNew: delayed audio signal
%   fs: new frequencies

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
    decibel{j} = minDecibel + floor(rand() * (maxDecibel - minDecibel));
end

if singleInput
    dataNew = single(data{1}(:,1).*(10^(decibel{1}/20)));
    fs = fs{1};
else
    parfor j=1:length(nummp3)
        dataNew{j} = single(data{j}(:,1).*(10^(decibel{j}/20)));
    end
end

end