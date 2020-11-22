%% Demos
% We provide three demos of a neural network training using the data
% augmentation techniques the we implemented. We train AlexNet on the
% ESC-50 dataset. The first training is on the original data and is used as
% a baseline. Besides, we train two more network on, respectively, audio
% augmented data and spectrogram augmented data.

%% The ESC-50 dataset
% The ESC-50 dataset is made by 2000 audio samples divided in 50 classes
% containing 40 samples per class. Each audio file is about 5 seconds long.
% The dataset is divided into 5 different folds and the testing protocol is
% cross fold validation. It can be downloaded at
% https://github.com/karolpiczak/ESC-50. In order to use the demos, the 
% dataset must be included in a folder name ESC-50.

%% Baseline method
% *createOriginalData.m* creates the spectrograms of the original audio
% files and store them in a folder named *originalSpectrograms*. In this
% folder the data is organized in 5 subfolders, i.e: one for every fold.
% Each of these folders also contain 50 subfolders, one for every class.
% The function *demoBaseline.m* train AlexNet on those spectrograms and
% test the results on every fold.
%% Raw Audio Augmentation
% *createAudioSamples.m* generates new audio samples from the original
% audio data. After that, the samples are turned into spectrograms and
% saved in a folder named *audioAugmentedData*.
% The function *demoAudioAugmentation.m* train AlexNet on the augmented
% audio samples and test the network on the original data, using the same 5
% fold validation.
%% Spectrogram Augmentation
% *createSpectrogramSamples.m* transform the raw audio signals into
% spectrograms and then applies data augmentation. The augmented data are
% saved in a folder named *imageAugmentedData*.
% The function *demoSpectrogramAugmentation.m* train AlexNet on the augmented
% spectrograms and test the network on the original data, using the same 5
% fold validation.