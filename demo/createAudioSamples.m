%% Augment audio data
% This script augments the raw audio data and create the spectrograms. It
% also organize the augmented data in folds by divideding them into 5
% folders. Every folder contains 50 subfolders, one for each class.
%
% The orignal audio files must be included in a folder name ESC-50 that can
% be downloaded at https://github.com/karolpiczak/ESC-50.
%
% The spectrograms are saved in a new folder named audioAugmentedData.

%% Create the folders if they do not already exist
clear
d = dir('ESC-50');
if ~exist('audioAugmentedData','dir')
    mkdir('audioAugmentedData')
end
if ~exist(fullfile('audioAugmentedData','1'),'dir')
    mkdir(fullfile('audioAugmentedData','1'))
    mkdir(fullfile('audioAugmentedData','2'))
    mkdir(fullfile('audioAugmentedData','3'))
    mkdir(fullfile('audioAugmentedData','4'))
    mkdir(fullfile('audioAugmentedData','5'))
end

%% Select the folders that contain the data
classes = d([d(:).isdir]==1);
classes = classes(~ismember({classes(:).name},{'.','..'}));

%% Set the hyperparameters for rescaling the spectrograms
% the audio signal is cut or padded to be audioLength seconds long.
audioLength = 5;
% n is the number of new samples for every original one.
n = 4;

%% Iterate over classes and folds
for i = 1:2%length(classes)
    % the data is divided in 5 folds, identified by the first number of
    % their names
    for fold = 1:5
        %% Read the data
        files = dir(fullfile('ESC-50',classes(i).name,strcat(int2str(fold),'*.ogg')));
        for j = 1: length(files)
            % extract audio data
            [soundData{j},fs{j}] = audioread(fullfile('ESC-50',classes(i).name,files(j).name));
        end
        %% Augment the audio data
        [newAudioData,newFrequencies] = generateNewAudioSamples(soundData,fs,n);
        trainingSpectrograms = generateSpectrogram(newAudioData,newFrequencies,audioLength,'gammatonegram');
        %% Create the new folders for the new data
        if ~exist(fullfile('audioAugmentedData',int2str(fold),classes(i).name),'dir')
            mkdir(fullfile('audioAugmentedData',int2str(fold),classes(i).name));
        end
        targetFolder = fullfile('audioAugmentedData',int2str(fold),classes(i).name);
        if ~exist(targetFolder,'dir')
            mkdir(targetFolder)
        end
        %% Save the images
        for sample = 1:(n+1)*length(files)
            % the values of the spectrogram are linarly rescaled to 0-255 by mapping 
            % the pixels with intensity M and m respectively to 255 and 0.
            im = trainingSpectrograms{sample};
            M = max(im(:));
            m = max(min(im(:)),-300);
            im = uint8((im - m) * 255 / (M - m));
            imwrite(im,fullfile(targetFolder,strcat(int2str(sample),'.jpg')));
        end
    end
end

%% Augmentation function
% this function applies the data augmentation to the data. 4 different
% augmentations were applied to every sample n times. The functions outputs
% n+1 for every original sample (n new samples plus the original one).
function [augmentedAudioData,augmentedAudioFrequencies] = generateNewAudioSamples(audioData,fs,n)
    augmentedAudioData = audioData;
    augmentedAudioFrequencies = fs;
    for i = 1:n
        %generate new data. We apply 4 different augmentations to every
        %sample
        [newAudioData,newFrequencies] = applyGain(audioData,-0.5,0.5,fs);
        [newAudioData,newFrequencies] = applyPitchShift(newAudioData,-0.5,0.5,newFrequencies);
        [newAudioData,newFrequencies] = applyRandTimeShift(newAudioData,newFrequencies);
        [newAudioData,newFrequencies] = applySpeedUp(newAudioData,-5,5,newFrequencies);
        %add the new data to the old ones
        augmentedAudioData = [augmentedAudioData,newAudioData];
        augmentedAudioFrequencies = [augmentedAudioFrequencies,newFrequencies];
    end
end