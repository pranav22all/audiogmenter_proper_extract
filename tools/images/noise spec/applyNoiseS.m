%% applyNoiseS.m

function [trainingNEW,y] = applyNoiseS(trainingImages,prob,sigma,y)
% APPLYNOISES generates a new set of images adding noise to the original images
%   with probability prob
%
%   [trainingNEW,y] = noiseS(trainingImages,y,prob)
%
%   Input
%   trainingImages: input images organized as cell array or single image.
%
%   y: labels of the input images (optional)
%
%   prob: probability threshold for image corruption
%
%   sigma: value of the noise
%
%   Output
%   trainingNEW:  set of corrupted images
%
%   y: labels of trainingNEW

if nargin<4
    y={};
end

%preparing variables
if isa(trainingImages,'cell')
    d = length(trainingImages);
    trainingNEW = cell(1,d); %preallocation
    isSingle = false;
else
    d  = 1;
    isSingle = true;
    trainingImages = {trainingImages};
end
%for every image in trainingImages, add noise
parfor i = 1:d
    trainingNEW{i} = noiseS(trainingImages{i}, prob, sigma); %add new to trainingNEW
end
if isSingle
    trainingNEW = trainingNEW{1};
end
end

function IM2 = noiseS(IM,prob,sigma)
    IM2(:,:,1)=noiseAddition(IM(:,:,1),prob,sigma);
    try IM2(:,:,2)=noiseAddition(IM(:,:,2),prob,sigma); end
    try IM2(:,:,3)=noiseAddition(IM(:,:,3),prob,sigma); end
end