%% applyEMDAaugmenter.m

function [trainingNEW,yNew] = applyEMDAaugmenter(trainingImages,y,varargin)
% APPLYEMDAAUGMENTER uses the Equalized Mixture Data Augmentation 
%   (EMDA) to augment a set of images. Details on this technique in 
%   spectrogramEMDA.m and in the original publication https://arxiv.org/abs/1604.07160
%   
%   [trainingNEW,y] = applyEMDAaugmenter(trainingImages,y,f,varargin)
%
%   Input
%   trainingImages: input images organized as cell array. 4th
%       dimension represents the different images
%
%   y: labels of trainingImages
%
%   Optional input
%   refer to spectrogramEMDA.m for the optional arguments
%
%   Output
%   trainingNEW: augmented dataset
%
%   yNew: labels of the augmented dataset

d = length(y);
%divide images by class
labels = unique(y);
classes = cell(1,labels(end)); %preallocation
for class = labels
    classes{class} = [];
end
for j = 1:d
    class = y(j);
    n = length(classes{class}) + 1;
    classes{class}{n} = trainingImages{j};
end
clear trainingImages
%generate new images

parfor i = labels %for every class
    classImages = classes{i};
    [newImages{i}, yy{i}, numNew{i}] = spectrogramEMDAaugmenter(classImages,i,varargin{:});
end
tot = 0;
trainingNEW = {};
yNew = 0;
for i = labels
    trainingNEW = [trainingNEW,newImages{i}];
    yNew(tot+1: tot+numNew{i}) =  yy{i};
    tot = tot + numNew{i};
end
end

function [trainingNew, y, index] = spectrogramEMDAaugmenter(classImages,i,varargin)
%SPECTROGRAMEMDAAUGMENTER applies Equalized Mixture Data Augmentation
%(EMDA) to a set of images of the same class

    index = 1;
    len = length(classImages);
    combinations = nchoosek(1:len,2); %possible combination of images
    combinations_len = size(combinations,1);
    gen_num = len; %number of generated images
    if gen_num > combinations_len  %if there aren't enough for f
        gen_num = combinations_len; %use all available combinations
    end
    trainingNew = {};
    y = [];
    for c = combinations(randperm(combinations_len, gen_num),:)' %choosen random combinations
        IM = spectrogramEMDA(classImages{c(1)},classImages{c(2)},varargin{:});
        trainingNew{index} = IM; %add new image to output set
        y(index) = i;
        index = index + 1;
    end
    index = index - 1;
end