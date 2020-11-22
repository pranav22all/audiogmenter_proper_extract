%% Augment spectrogram data
% This script augments the spectrograms. It also organizes the augmented
% data in folds by divideding them into 5 folders. Every folder contains 50
% subfolders, one for each class.
%
% The orignal audio files must be included in a folder name ESC-50 that can
% be downloaded at https://github.com/karolpiczak/ESC-50.
%
% The spectrograms are saved in a new folder named imageAugmentedData.

%% Create the folders if they do not already exist
clear
d = dir('ESC-50');
if ~exist('imageAugmentedData','dir')
    mkdir('imageAugmentedData')
end
if ~exist(fullfile('imageAugmentedData','1'),'dir')
    mkdir(fullfile('imageAugmentedData','1'))
    mkdir(fullfile('imageAugmentedData','2'))
    mkdir(fullfile('imageAugmentedData','3'))
    mkdir(fullfile('imageAugmentedData','4'))
    mkdir(fullfile('imageAugmentedData','5'))
end

%% Select the folders that contain the data
classes = d([d(:).isdir]==1);
classes = classes(~ismember({classes(:).name},{'.','..'}));

%% Set the hyperparameters for rescaling the spectrograms
% the values of the spectrogram are linarly rescaled to 0-255 by mapping 
% the pixels with intensity M and m respectively to 255 and 0.
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
        clear labels
        for j = 1: length(files)
            % the spectrogram augmentation requires the labels of the
            % inputs. Since we are iterating over classes, every sample has
            % the same label.
            labels(j) = 1;
            % extract audio data
            [soundData{j},fs{j}] = audioread(fullfile('ESC-50',classes(i).name,files(j).name));
        end
        %% Generate new spectrograms
        trainingSpectrograms = generateSpectrogram(soundData,fs,audioLength,'gammatonegram');
        newImageData = generateNewSpectrogramsSamples(trainingSpectrograms,n);
        %% Create the new folders for the new data
        if ~exist(fullfile('imageAugmentedData',int2str(fold),classes(i).name),'dir')
            mkdir(fullfile('imageAugmentedData',int2str(fold),classes(i).name));
        end
        targetFolder = fullfile('imageAugmentedData',int2str(fold),classes(i).name);
        if ~exist(targetFolder,'dir')
            mkdir(targetFolder)
        end
        %% Save the images
        for sample = 1:(n+1)*length(files)
            im = newImageData{sample};
            M = max(im(:));
            m = max(min(im(:)),-300);
            % save the images
            im = uint8((im-m) * 255 /(M-m));
            imwrite(im,fullfile(targetFolder,strcat(int2str(sample),'.jpg')));
        end
    end
end

%% Augmentation function
% this function applies the data augmentation to the data. 4 different
% augmentations were applied to every sample n times. The functions outputs
% n+1 for every original sample (n new samples plus the original one).
function [augmentedSpectrogramData] = generateNewSpectrogramsSamples(spectrograms,n)
    % parameter for frequency masking
    maskParameter.numCutF = 2;
    maskParameter.wCutF = 1;
    maskParameter.numCutT = 2;
    maskParameter.wCutT = 2;
    
    %parameter for time-pitch sift
    shiftParameter.time = [0,0];
    shiftParameter.pitch = [-1,1];
    augmentedSpectrogramData = spectrograms;
    for i = 1:n
        %generate new data
        [newSpectrograms] = applySpectrogramRandomShifts(spectrograms,shiftParameter);
        [newSpectrograms] = applySpecRandTimeShift(newSpectrograms);
        [newSpectrograms] = applyFrequencyMasking(newSpectrograms,maskParameter);
        [newSpectrograms] = applyNoiseS(newSpectrograms,0.1,0.7);
        %add the new data to the old ones
        augmentedSpectrogramData = [augmentedSpectrogramData,newSpectrograms];
    end
end