%% Extract spectrograms from original data
% This script creates the spectrograms of the audio files of the ESC-50
% dataset for audio classification.
%
% This script creates the spectrograms of the raw audio samples and
% splits them into 5 folders, one for every fold. Each one of these folders
% contain 50 subfolders, one for every class.
%
% The orignal audio files must be included in a folder name ESC-50 that can
% be downloaded at https://github.com/karolpiczak/ESC-50.
%
% The spectrograms are saved in a new folder named originalSpectrograms.


%% Create the folders if they do not already exist
clear
d = dir('ESC-50');
if ~exist('originalSpectrograms','dir')
    mkdir('originalSpectrograms')
end
if ~exist(fullfile('originalSpectrograms','1'),'dir')
    mkdir(fullfile('originalSpectrograms','1'))
    mkdir(fullfile('originalSpectrograms','2'))
    mkdir(fullfile('originalSpectrograms','3'))
    mkdir(fullfile('originalSpectrograms','4'))
    mkdir(fullfile('originalSpectrograms','5'))
end

%% select the folders that contain the data
classes = d([d(:).isdir]==1);
classes = classes(~ismember({classes(:).name},{'.','..'}));

%% Set the hyperparameters for rescaling the spectrograms
% the audio signal is cut or padded to be audioLength seconds long.
audioLength = 5;

%% Iterate over classes and folds
for i = 1:2%length(classes)
    % the data is divided in 5 folds, identified by the first number of
    % their names
    for fold = 1:5
        %% Read the data
        files = dir(fullfile('ESC-50',classes(i).name,strcat(int2str(fold),'*.ogg')));
        for j = 1:length(files)
            % extract audio data
            [soundData{j},fs{j}] = audioread(fullfile('ESC-50',classes(i).name,files(j).name));
        end
        %% Create the folders for storing the spectrograms
        if ~exist(fullfile('originalSpectrograms',int2str(fold),classes(i).name),'dir')
            mkdir(fullfile('originalSpectrograms',int2str(fold),classes(i).name));
        end
        testFolder = fullfile('originalSpectrograms',int2str(fold),classes(i).name);
        if ~exist(testFolder,'dir')
            mkdir(testFolder)
        end
        %% Generate and save the spectrograms
        originalSpectrograms = generateSpectrogram(soundData,fs,audioLength,'gammatonegram');
        for sample = 1:length(files)
            im = originalSpectrograms{sample};
            % the values of the spectrogram are linarly rescaled to 0-255 by mapping 
            % the pixels with intensity M and m respectively to 255 and 0.
            M = max(im(:));
            m = max(min(im(:)),-300);
            im = uint8((im - m) * 255 / (M - m));
            imwrite(im,fullfile(testFolder,strcat(int2str(sample),'.jpg')));
        end
    end
end