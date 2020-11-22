%% applyPitchShift.m
% This function uses the Matlab implementation of Phase Vocoder (D. P. W.
% Ellis, A Phase Vocoder in Matlab, 2002), available at
% <https://www.ee.columbia.edu/~dpwe/resources/matlab/pvoc/>

function [outAudioNEW, fs] = applyPitchShift(audio,minSemiTone,maxSemiTone,fs)
% APPLYPITCHSHIFT applies pitch shifting in semitone to the input audio signal
%   Input
%   audio: raw audio signal
%   minSemiTone: minimum pitch shift value in semitones (1 tone = 2 semitones)
%   maxSemiTone: maximum pitch shift value in semitones (1 tone = 2 semitones)
%   fs: frequencies of the audio signals. Not required if nummp3 contains
%       the audio paths.
%
%   Output
%   outAudioNEW: the pitched-shifted audio signal
%
%   This function uses the phase vocoder available from https://www.ee.columbia.edu.
%   The original code is included in
%   ./tools/audio/pitch shift/Phase Vocoder/


% Initialize data and the parameter
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

addpath(genpath('Phase Vocoder'));
parfor j = 1:nSamples

% Computes cents to be used in che calculations of the frequency ratio
semiTone{j} = minSemiTone + rand() * (maxSemiTone - minSemiTone);
cents{j}=abs(semiTone{j})*100;
freqRatio{j}=2^(cents{j}/1200);
if(semiTone{j}>0)
    freqRatio{j}=1/freqRatio{j};
end

% Stretches the audio file to modify the pitch
outAudio{j} = pvoc(data{j}, freqRatio{j});

% Converts decimal number to fraction
[num{j},dem{j}]=rat(freqRatio{j});
% the number cannot be too large
while num{j} > 5000
num{j}=floor(num{j}/10);
dem{j}=floor(dem{j}/10);
end

% Resamples the pitched file to return to the original audio size
outAudioNEW{j} = resample(outAudio{j},num{j},dem{j});

end

if singleInput
    outAudioNEW = outAudioNEW{1};
end

end
