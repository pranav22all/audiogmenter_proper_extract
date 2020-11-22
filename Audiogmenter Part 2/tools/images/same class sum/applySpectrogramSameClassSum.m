%% applySpectrogramSameClassSum.m

function [trainingNEW, newY] = applySpectrogramSameClassSum(trainingImages,n,y)
% APPLYSPECTROGRAMSAMECLASSSUM generates a new set of images summing together
%   images of the same class/label
%
%   [newImages, newY] = applySpectrogramSameClassSum(trainingImages,y,n,f)
%
%   Input
%   trainingImages: input images organized as cell array.
%
%   y: labels of images
%
%   n: number of images to sum at time
%
%
%   Output
%   trainingNEW: image set of same-class added images (not cointaining the
%       original images)
%
%   newY: labels of trainingNEW

%divide images by class
labels = unique(y);
classes = cell(1,labels(end)); %preallocation
for class = labels
    classes{class} = [];
end
d = length(y);
for j = 1:d
    class = y(j);
    n = length(classes{class}) + 1;
    classes{class}{n} = trainingImages{j};
end
%generate new images
index = 1;
for i = labels %for every class
    classImages = classes{i};
    [newImages{i},yy{i},numNew{i}] = spectrogramSameClassSum(classImages,i,n);
end

tot = 0;
trainingNEW = {};
for i = labels
    trainingNEW = [trainingNEW,newImages{i}];
    newY(tot+1:tot+numNew{i}) = yy{i};
    tot = tot + numNew{i};
end
end

function [newImages,newY,index] = spectrogramSameClassSum(classImages,i,n)
    index = 1;
    len = length(classImages);
    combinations = nchoosek(1:len,n); %possible combination of images
    combinations_len = size(combinations,1);
    gen_num = len; %number of generated images
    if gen_num > combinations_len  %if there aren't enough for f
        gen_num = combinations_len; %use all available combinations
    end
    for c = combinations(randperm(combinations_len, gen_num),:)' %choosen random combinations
        args = cell(1,n); %preallocation
        % if only one image has class i, there is no sum.
        if n > 1
            for k = 1:n
                args{k} = classImages{c(k)}; %collect choosen images
            end
            IM = spectrogramSum(args{:}); %sum images
        else
            IM = classImages{1};
        end
        newImages{index} = IM; %add new image to output set
        newY(index) = i;
        index = index + 1;
    end
    index = index - 1;
end