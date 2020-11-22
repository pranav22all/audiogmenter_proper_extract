%% Augmentation techniques for audio signals
% This script illustrates how to 
% augment raw audio signals and convert them into spectrograms
% and augment spectrograms already created from audio signals
%
% Illustrative results of augmentation from raw audio signals and from
% precomputed spectrograms are shown by the plotTestAugmentation.m script

%% Load sample audio signal dataset ./examples/SmallInputDatasets/inputAugmentationFromAudio.mat
% inputAugmentationFromAudio.mat contains a list of 6 raw mp3 files, located
% in ./examples/OriginalAudioFiles/, together with their labels
load inputAugmentationFromAudio

%% Sampling rate for the 6 audio signals in the dataset
fs = {48000 48000 48000 48000 48000 48000};

%% Apply 11 illustrative augmentation techniques to audio signals
% * CreateDataAUGFromAudio.m: applies the chosen augmentation technique
% * generateSpectrogram.m: generates the spectrograms once the audio signals
%   have been augmented

nummp3 = aaa; label = myLabels;
tmp = 1;
clear ImN
tmp = 1;
len = 10;
Im =CreateDataAUGFromAudio(nummp3,'wowResampling',label);ImN{tmp} = generateSpectrogram(Im, fs, len);tmp=tmp+1;
Im =CreateDataAUGFromAudio(nummp3,'noise',label);ImN{tmp} = generateSpectrogram(Im, fs, len);tmp=tmp+1;
Im =CreateDataAUGFromAudio(nummp3,'clipping',label);ImN{tmp} = generateSpectrogram(Im, fs, len);tmp=tmp+1;
Im =CreateDataAUGFromAudio(nummp3,'speedUp',label);ImN{tmp} = generateSpectrogram(Im, fs, len);tmp=tmp+1;
Im =CreateDataAUGFromAudio(nummp3,'harmonicDistortion',label);ImN{tmp} = generateSpectrogram(Im, fs, len);tmp=tmp+1;
Im =CreateDataAUGFromAudio(nummp3,'gain',label);ImN{tmp} = generateSpectrogram(Im, fs, len);tmp=tmp+1;
Im =CreateDataAUGFromAudio(nummp3,'randTimeShift',label);ImN{tmp} = generateSpectrogram(Im, fs, len);tmp=tmp+1;
Im =CreateDataAUGFromAudio(nummp3,'soundMix',label);ImN{tmp} = generateSpectrogram(Im, fs, len);tmp=tmp+1;
Im =CreateDataAUGFromAudio(nummp3,'dynamicRange',label);ImN{tmp} = generateSpectrogram(Im, fs, len);tmp=tmp+1;
Im =CreateDataAUGFromAudio(nummp3,'pitchShift',label);ImN{tmp} = generateSpectrogram(Im, fs, len);tmp=tmp+1;
Im =CreateDataAUGFromAudio(nummp3,'lowpassFilter',label);ImN{tmp} = generateSpectrogram(Im, fs, len);tmp=tmp+1;
ImNFromAudio = ImN;

%% Save the spectrograms from the augmented audio signals in ./examples/AugmentedImages/
save(strcat(pwd,'/AugmentedImages/AugmentedFromAudio.mat'), 'ImNFromAudio')

%% Load sample spectrogram dataset ./examples/SmallInputDatasets/inputAugmentationFromSpectrograms.mat
% inputAugmentationFromSpectrograms.mat contains the 6 spectrograms (together with their classes)
% computed from the 6 raw audio signals in
% ./examples/SmallInputDatasets/inputAugmentationFromAudio.mat, resized to 224x244
% pixels
clear ImN
load inputAugmentationFromSpectrograms
size(spectrogramsOrigFromAudio)
Img = spectrogramsOrigFromAudio; label = myLabels;
tmp = 1;

%% Set frame rate for the spectrograms
fs = 48000;

%% Apply 7 illustrative augmentation techniques to the spectrograms
ImN{tmp}=CreateDataAUGFromImage(Img,'frequencyMasking',label);tmp=tmp+1;
ImN{tmp}=CreateDataAUGFromImage(Img,'sameClassSum',label);tmp=tmp+1;
ImN{tmp}=CreateDataAUGFromImage(Img,'VTLN',label);tmp=tmp+1;
ImN{tmp}=CreateDataAUGFromImage(Img,'EMDA',label);tmp=tmp+1;
ImN{tmp}=CreateDataAUGFromImage(Img,'noiseS',label);tmp=tmp+1;
ImN{tmp}=CreateDataAUGFromImage(Img,'timeShift',label);tmp=tmp+1;
ImN{tmp}=CreateDataAUGFromImage(Img,'imageWarp',label);tmp=tmp+1;
ImNFromImage = ImN;

%% Save the augmented spectrograms in ./AugmentedImages/
save(strcat(pwd,'/AugmentedImages/AugmentedFromImages.mat'), 'ImNFromImage')