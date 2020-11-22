%% applySpecRandTimeShift.m

function [trainingNEW,y] = applySpecRandTimeShift(trainingImages,y)
% APPLYSPECRANDTIMESHIFT applies a shift in time to the input set of spectrograms.
%   Each input image is randomly split in two parts along its vertical 
%   dimension and the parts are swapped.
%
%   [trainingNEW,y] = randTimeShift(trainingImages,y)
%
%   Input
%   trainingImages: input images organized as cell array or single image
%
%   y: labels of the input images (optional)
%
%   Output
%   trainingNEW:  set of corrupted images
%
%   y: labels of trainingNEW

if nargin<2
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
    trainingNEW{i}=timeShift(trainingImages{i});
end
if isSingle
    trainingNEW = trainingNEW{1};
end
end

function image = timeShift(IM)
% TIMESHIFT splits in two parts along the vertical dimension the input
%   image IM by picking a random number between one and IM horizontal size.

    len=size(IM,2);
    div = floor(rand(1)*(len-1)+1);
    image=horzcat(IM(:,div+1:end,:),IM(:,1:div,:));
end
