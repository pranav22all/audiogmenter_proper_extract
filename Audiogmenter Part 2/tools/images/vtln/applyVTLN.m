%% applyVTLN.m

function [newImages ,newLabels] = applyVTLN(trainingImages,parameter,y)
% APPLYVTLN applies random crop (randCrop) and the the Vocal Tract Lenght
%   Normalization (VTLN) on a spectrogram set expanding it.
%
%   [trainingImages,y] = VTLN(trainingImages,y,n,varargin)
%
%   Input
%   trainingImages: input images organized as a cell array.
%   y: labels of the training set
%   Optional input
%   parameter:
%   -fmax: max frequency of the spectrograms, used for VTLN (default 1)
%   -f0: frequency value ( 0 <= f0 <= fmax), used for VTLN (default 0.5)
%   -rangeA: range of the ramdom factor 'a' factor for VTLN
%       in form if [minvalue maxvalue] (defualt [0.9 1.1])
%
%   Output
%   newImages = new spectrogram set
%
%   newLabels = labels of outImages

%default values
if nargin < 2
    parameter = struct();
end

if nargin < 3
    y = {};
end

if isfield(parameter,'fmax')==0
    parameter.fmax = 1;
end
if isfield(parameter,'f0')==0
    parameter.f0 = 0.5;
end
if isfield(parameter,'rangeA')==0
    parameter.rangeA = [];  %this leads to [0.9 1.1]
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

parfor i = 1:d
    % d is the number of original images.
    newImages{i} = VTLN(trainingImages{i},parameter.f0,parameter.fmax,parameter.rangeA);
end
newLabels = y;

if isSingle
    newImages = newImages{1};
end

end