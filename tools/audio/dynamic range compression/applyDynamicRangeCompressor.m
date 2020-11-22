%% applyDynamicRangeCompressor.m

function [newAudio, fs] = applyDynamicRangeCompressor(audio,parameter,fs)
% APPLYDYNAMICRANGECOMPRESSOR 
%   applies a Dynamic Range Compression to audio dataset using the function
%   dynamicRangeCompressor.m
%   
%   [newAudio,fs] = applyDynamicRangeCompressor(audio,parameter)
%
%   Input
%   audio: list of files (e.g. from command DIR), or a given dataset of audio
%       signal
%   fs: frequencies of the audio signals. Not required if nummp3 contains
%       the audio paths.
%
%   parameter: see the function dynamicRangeCompressor.m for parameter
%       details
%
%   Output
%   newAudio; cell array, containing one cell for each of the audio signals
%       included in audio
%   fs: new frequencies


if nargin<2
    parameter=[];
end
if nargin<1
    error('Please specify input data');
end

if isa(audio,'struct')
    singleInput = false;
    nSamples = length(audio);
    flag = true;
elseif isa(audio,'cell')
    flag = false;
    nSamples = length(audio);
    singleInput = false;
    data = audio;
else      %the data is a single signal
    flag = false;
    singleInput = true;
    data = {audio};
    fs = {fs};
    nSamples = 1;
end

parfor j=1:nSamples
    % Check whether the input must be read
    if flag
        [data{j},fs{j}]=audioread(audio(j).name);
    end
end

newAudio=cell(1,length(audio));
parfor j=1:nSamples
    newAudio{j} = dynamicRangeCompressor(data{j}, parameter);
end

if singleInput
    newAudio = dynamicRangeCompressor(data{1}, parameter);
    fs = fs{1};
else
    parfor j=1:length(audio)
        newAudio{j} = dynamicRangeCompressor(data{j}, parameter);
    end
end
end

