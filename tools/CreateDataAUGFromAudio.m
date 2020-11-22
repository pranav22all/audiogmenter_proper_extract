%% CreateDataAUGFromAudio.m

function dataNew=CreateDataAUGFromAudio(nummp3,typeAgument,label)
fs = 48000;
% CREATEDATAAUGFROMAUDIO  Spectrogram augmentation directly from audio
%   files.
%   dataNew=CREATEDATAAUGFROMAUDIO(nummp3,typeAgument,label)
%   
%   Input
%   nummp3: list of files (e.g. from command DIR), a given dataset of audio
%       signal
%
%   typeAgument: string, one of the available augmentation methods:
%   - 'wowResampling', for more information type: help applyWowResampling
%   - 'noise', for more information type: help applyNoise
%   - 'clipping', for more information type: help applyClipping
%   - 'speedUp', for more information type: help applySpeedUp
%   - 'aliasing', for more information type: help applyAliasing
%   - 'harmonicDistortion', for more information type: help applyHarmonicDistortion
%   - 'gain', for more information type: help applyGain
%   - 'randTimeShift', for more information type: help applyrandTimeShift
%   - 'soundMix', for more information type: help applySoundMix
%   - 'dynamicRange', for more information type: help applyDynamicRangeCompressor
%   - 'pitchShift', for more information type: help applyPitchShift
%   - 'impulseResponse', for more information type: help applyImpulseResponse
%   - 'delay', for more information type: help applyDelay
%   - 'lowpassFilter', for more information type: help applyLowpassFilter
%   - 'highpassFilter', for more information type: help applyHighpassFilter
%   
%   label: array, class labels for the audio files in nummp3
%
%   Output
%   dataNew: cell array, containing one cell for each augmentation
%   technique. Each cell contains the augmented version of the audio files
%   included in nummp3

if strcmp(typeAgument,'wowResampling')
    parameter.minIntensityOfChange = 3;
    parameter.maxIntensityOfChange = 3;
    parameter.minFrequencyOfChange = 2;
    parameter.maxFrequencyOfChange = 2;   % min and max intensities and frequencies are set to be the same
    [dataNew, fs] = applyWowResampling(nummp3, parameter);
end
if strcmp(typeAgument,'noise')
    snrRatio = 10;
    % min and max ratios are the same
    [dataNew, fs] = applyNoise(nummp3, snrRatio, snrRatio);
end
if strcmp(typeAgument,'clipping')
    percentOfSamples = 10;
    % min and max percent of samples are set to be the same
    [dataNew, fs] = applyClipping(nummp3, percentOfSamples, percentOfSamples);
end
if strcmp(typeAgument,'speedUp')
    percentChange = 15;
    % min and max percents of change are set to be the same
    [dataNew, fs] = applySpeedUp(nummp3, percentChange, percentChange);
end
if strcmp(typeAgument,'aliasing')
    dsFrequency = 40000;
    % min and max frequencies are set to be the same
    [dataNew, fs] = applyAliasing(nummp3, dsFrequency, dsFrequency);
end
if strcmp(typeAgument,'harmonicDistortion')
    nApplications = 5;
    [dataNew, fs] = applyHarmonicDistortion(nummp3, nApplications);
end
if strcmp(typeAgument,'gain')
    decibel = 10;
    % min and max gain decibels are set to be the same
    [dataNew, fs] = applyGain(nummp3, decibel, decibel);
end
if strcmp(typeAgument,'randTimeShift')
    [dataNew, fs] = applyRandTimeShift(nummp3);
end
if strcmp(typeAgument,'soundMix')
    [dataNew, fs] = applySoundMix(nummp3,label);
end
if strcmp(typeAgument,'dynamicRange')
	[dataNew, fs] = applyDynamicRangeCompressor(nummp3,[]);
end
if strcmp(typeAgument,'pitchShift')
    decibel = 2;
    % min and max shifts are set to be the same
	[dataNew, fs] = applyPitchShift(nummp3,decibel,decibel);
end
if strcmp(typeAgument,'impulseResponse')
	[dataNew, fs] = applyImpulseResponse(nummp3,{'GreatHall1'});
end
if strcmp(typeAgument,'delay')
    % min and max delays are set to be the same
    nOfZeros = 100;
	[dataNew, fs] = applyDelay(nummp3,nOfZeros,nOfZeros);
end
if strcmp(typeAgument,'lowpassFilter')
	[dataNew, fs] = applyLowpassFilter(nummp3,4000,2000);
end
if strcmp(typeAgument,'highpassFilter')
	[dataNew, fs] = applyHighpassFilter(nummp3,500,4000);
end

% check isnan & is inf
for j=1:length(dataNew)
    dataNew{j}(find(isnan(dataNew{j})))=0;
    dataNew{j}(find(isinf(dataNew{j})))=0;
end

end