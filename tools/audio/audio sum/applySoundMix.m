%% applySoundMix.m
% This function uses the Audio Degradation Toolbox (ADT) available at
% <https://code.soundsoftware.ac.uk/projects/audio-degradation-toolbox>

function [dataNew, fs]  = applySoundMix(nummp3,label,fs)
%  APPLYSOUNDMIX sums an audio signal to another randomly selected audio signal
%   (not the same) from the same class
%   Input
%   nummp3: raw audio signal (audio paths, cell of the signals or single signal)
%   label: array, class labels for the audio filed in nummp3
%   fs: frequencies of the audio signals. Not required if nummp3 contains
%       the audio paths.
%
%   Output
%   dataNew: the sum of audio signals of the same class
%   fs: new frequencies
%
%   The original function degradationUnit_addSound.m is included in
%   ./tools/audio/audio-degradation-toolbox/
%
%   The original publication and additional information are available at
%   https://zenodo.org/record/1415862 and
%   https://code.soundsoftware.ac.uk/projects/audio-degradation-toolbox

% Initialize data
if isa(nummp3,'struct')
    singleInput = false;
    nSamples = length(nummp3);
    flag = true;
elseif isa(nummp3,'cell')
    flag = false;
    singleInput = false;
    nSamples = length(nummp3);
    data = nummp3;
else      %the data is a single signal
    flag = false;
    singleInput = true;
    data = {nummp3};
    nSamples = 1;
    fs = {fs};
end

parfor j=1:nSamples
    % Check whether the input must be read
    if flag
        [data{j},fs{j}]=audioread(nummp3(j).name);
    end
end
    
paramSound = cell(1,length(nummp3));
parfor j=1:length(nummp3)
    
    % Finds all the audio signals from the same class of the current one
    idx{j}=find(label==label(j));
    
    % Removes the current audio signal from the list
    idx{j}(ismember(idx{j},j)) = [];
    
    % Random selection of the second audio signal to add to the current one
    num{j}=idx{j}(randperm(length(idx{j}),1));
    
    paramSound{j}.snrRatio = 0;
    paramSound{j}.loadInternalSound = 0;
    
    % Loads the second audio signal
    if flag
        paramSound{j}.addSound=audioread(nummp3(num{j}).name);
    else
        paramSound{j}.addSound=data{j};
    end
    
    paramSound{j}.addSoundSamplingFreq=fs{j};
    numChannels1{j} = size(data{j},2);
    numChannels2{j} = size(paramSound{j}.addSound,2);
    MinNumberChannel{j}=min([numChannels1{j} numChannels2{j}]);
    if (numChannels1{j} ~= numChannels2{j})
        data{j}=data{j}(:,1:MinNumberChannel{j});
        paramSound{j}.addSound=paramSound{j}.addSound(:,1:MinNumberChannel{j});
    end
    
end

if singleInput
    dataNew = degradationUnit_addSound(data{1}, fs{1}, [], paramSound{1});
    fs = fs{1};
else
    parfor j=1:length(nummp3)
        dataNew{j} = degradationUnit_addSound(data{j}, fs{j}, [], paramSound{j});
    end
end
end
