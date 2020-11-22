%% CreateDataAUGFromImage.m

function [trainingImages2,y2]=CreateDataAUGFromImage(trainingImages,typeAgument,label)
% CREATEDATAAUGFROMIMAGE  Spectrogram augmentation from original spectrograms.
%   trainingImages2 = 
%    CreateDataAUGFromImage(trainingImages,typeAgument,label)
%   
%   Input
%   trainingImages: input images organized as cell array. 4th
%   dimension represents the different images
%
%   typeAgument: string, one of the available augmentation methods:
%   - 'frequencyMasking', generates a new set of images by masking one time
%       band and two frequency bands
%   - 'sameClassSum', generates a new set of images summing together images
%       from the same class
%   - 'VTLN', generates a new set of images normalizing or corrupting the
%       spectrogram by warping the frequency axes of trainingImages 
%   - 'EMDA', mixes two spectrograms of the same class with randomly
%       selected timings and it perturbs the frequency characteristics of
%       each source spectrogram by boosting/attenuating a particular 
%       frequency band.
%   - 'noiseS', adds random noise to the original image by setting to zero
%       the value of randomly selected pixels
%   - 'timeShift', selects a random number t and breaks the original
%       spectrogram into two pieces where time is larger or smaller than t.
%       Then swaps the tow parts to create a new spectrogram.
%   - 'imageWarp', applies Thin-Plane Spline Warping (TPS-Warp) to the
%       original image. TPS-warp is a random deformation of the original
%       image along the horizontal component.
%   - 'randomShifts', applies random time and pitch shifts to the original
%       spectrogram.
%       
%   
%   label: array, class labels for images included in trainingImages
%
%   Output
%   trainingImages2: cell array, containing one cell for each augmentation
%   technique. Each cell contains a cell array.

if strcmp(typeAgument,'frequencyMasking')
    [trainingImages2, y2] = applyFrequencyMasking(trainingImages, [], label);
elseif  strcmp(typeAgument,'sameClassSum')
    [trainingImages2, y2] = applySpectrogramSameClassSum(trainingImages, 2, label);
elseif strcmp(typeAgument,'VTLN')
    [trainingImages2, y2] = applyVTLN(trainingImages,[],label);
elseif  strcmp(typeAgument,'EMDA')
    [trainingImages2,y2] = applyEMDAaugmenter(trainingImages,label);
elseif  strcmp(typeAgument,'noiseS')
    [trainingImages2,y2] = applyNoiseS(trainingImages,0.3,0.5,label);
elseif  strcmp(typeAgument,'timeShift')
    [trainingImages2,y2] = applySpecRandTimeShift(trainingImages,label);
elseif  strcmp(typeAgument,'imageWarp')
    [trainingImages2,y2] = applyRandomImageWarp(trainingImages,[],label);
elseif  strcmp(typeAgument,'randomShifts')
    [trainingImages2,y2] = applySpectrogramRandomShifts(trainingImages,[],label);
end