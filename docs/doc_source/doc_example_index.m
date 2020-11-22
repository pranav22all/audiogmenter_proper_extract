%% Examples
% We provide two examples for our Augmentation Toolbox, together with a
% small illustrative dataset of six mp3 files for audio signal augmentation
% and another dataset containing six spectrograms produced from the six mp3
% files.

%% Illustrative datasets
% * The original audio files used to produce spectrograms are located in
% ./examples/AugmentedImages/ and were downloaded from
% <https://www.xeno-canto.org/>.
% * inputAugmentationFromAudio.mat, included in
% ./examples/SmallInputDatasets/, contains the list of the six raw mp3
% files.
% * inputAugmentationFromSpectrograms.mat, included in
% ./examples/SmallInputDatasets/, contains the six spectrograms resized to
% 224x224 pixels (together with their classes) computed from the six raw
% mp3 files listed in
% ./examples/SmallInputDatasets/inputAugmentationFromAudio.mat by means of
% the sgram.m function.

%% Example 1
% *testAugmentation.m* demonstrates how to
%%
% * augment directly audio signals and convert them into spectrograms
% (augmentation from audio);
% * augment spectrograms derived from audio signals (augmentation from
% images) The augmented images produced by this example are saved in the
% folder ./examples/AugmentedImages/

%% Example 2
% *plotTestAugmentation.m*
% simply plots the augmented versions of a chosen audio signal.