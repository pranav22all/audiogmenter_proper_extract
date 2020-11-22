%% applyRandomImageWarp.m

function [trainingNEW,y] = applyRandomImageWarp(trainingImages,parameter,y)
% APPLYRANDOMIMAGEWARP generates a new set of spectrograms by applying to
%   trainingImages the Thin-Plane spline warping in time (along the 
%   horizontal dimension).
%   
%   Our code uses a modification of the implementation of the Thin-Plane 
%   spline warping available at 
%   https://it.mathworks.com/matlabcentral/fileexchange/24315-warping-using-thin-plate-splines
%
%   Original publication for the thin-Plane spline warping: 
%   F.L. Bookstein, "Principal Warps: Thin-Plate splines and the
%   decomposition of deformations", IEEE Transaction on Pattern Analysis
%   and Machine Intelligence, Vol. 11, No. 6, June 1989
%
%   [trainingNEW] = randomImageWarp(trainingImages,y,parameter)
%
%   Input
%   trainingImages: input images organized as cell array or single image
%
%   y: labels of trainingImages
%
%   parameter: parameters for image interpolation before warping
%   -xGrid: distance between consecutive landmarks in the x axis
%   -yGrid: distance between consecutive landmarks in the y axis
%   -xNoise: size of the random perturbation in the x axis
%   -numPunti: number of points used to generate the perturbation
%
%   Output
%   trainingNEW: image set of warped and masked images
%
%   y: labels of trainingNEW

if nargin<2
    parameter=struct();
end
if nargin<3
    y={};
end

if isfield(parameter,'xGrid')==0
    parameter.xGrid = 8;
end
if isfield(parameter,'yGrid')==0
    parameter.yGrid = 8;
end
if isfield(parameter,'xNoise')==0
    parameter.xNoise = 20;
end
if isfield(parameter,'numPunti')==0
    parameter.numPunti = 4;
end
if isfield(parameter,'maxChange')==0
    parameter.maxChange = 20;
end

addpath(genpath('tpsWarp'));
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
    trainingNEW{i}=changeImage_Interp(trainingImages{i}, parameter.xGrid, parameter.yGrid, parameter.xNoise, parameter.numPunti, parameter.maxChange); %apply image warp
end
if isSingle
    trainingNEW = trainingNEW{1};
end
end
