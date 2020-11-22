%% applySpectrogramRandomShifts.m

function [newImages,newY] = applySpectrogramRandomShifts(trainingImages,parameter,y)
% APPLYSPECTROGRAMRANDOMSHIFTS generates a new set of images by applying a random
%   shift (both in time and pitch) to the originals images. First, each
%   spectrogram is split in two parts along its vertical dimension and the
%   two parts are swapped. Then, the same procedure is applied to the
%   horizontal dimension. The amount of the time and pitch shifts is
%   randomly picked from the ranges timeShift and pitchShift.
%
%   [newImages,newY] = spectrogramRandomShifts(trainingImages,y,n,varargin)
%
%   Input
%   trainingImages: input images organized as cell array
%
%   y: labels of trainingImages (optional)
%
%   n: number of shift per image (factor of generated images)
%
%   %   parameter: parameters for image interpolation before warping
%   -time: min and max values for time shift represented as [min max]
%   -pitch: min and max values for pitch shift represented as [min max]
%
%   Output
%   newImages: image set of shifted images (not including original images)
%
%   newY: labels of newImages

if nargin<3
    y={};
end
%default values
if nargin<2
    parameter = struct();
end

if isfield(parameter,'timeShift')==0
    parameter.timeShift = [0,0];
end

if isfield(parameter,'pitchShift')==0
    parameter.pitchShift = [0,0];
end

if isa(trainingImages,'cell')
    d = length(trainingImages);
    newImages = cell(1,d); %preallocation
    isSingle = false;
else
    d  = 1;
    isSingle = true;
    trainingImages = {trainingImages};
end

newImages = cell(1,d); %preallocation
newY = y;
parfor i = 1:d
    IM = trainingImages{i};
    randPitchShift = parameter.pitchShift(1) + rand() * (parameter.pitchShift(2)-parameter.pitchShift(1));
    newImages{i} = spectrogramShift(spectrogramShift(IM,randi(parameter.timeShift),'time'),randPitchShift,'pitch');
end

if isSingle
    newImages = newImages{1};
end

end