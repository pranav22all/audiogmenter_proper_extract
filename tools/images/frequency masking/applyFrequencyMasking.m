%% applyFrequencyMasking.m

function [trainingNEW, y] = applyFrequencyMasking(trainingImages,parameter,y)
% APPLYFREQUENCYMASKING generates a new set of spectrograms by masking
%   bands in frequency (horizontal bands) and time (vertical bands) setting 
%   pixel values to 0.
%
%   [trainingNEW] = randomImageWarp(trainingImages,y,parameter)
%
%   Input
%   trainingImages: input images organized as cell array.
%
%   y: labels of trainingImages (optional)
%
%   parameter: parameters for image interpolation before warping
%   -numCutF: number of bands used to mask frequencies (horizontal bands)
%   -numCutT: number of bands used to mask time (vertical bands)
%   -wCutF: width of the frequency masking bands
%   -wCutT: width of the time masking bands
%   -value: is the new value of the masked pixels. If not given it is the
%           minumium value of every spectrogram.
%
%   Output
%   trainingNEW: image set of warped and masked images
%
%   y: labels of trainingImages

if nargin<2
    parameter = struct();
end
if nargin<3
    y = {};
end

if isfield(parameter,'numCutF')==0
    parameter.numCutF = 2;
end
if isfield(parameter,'wCutF')==0
    parameter.wCutF = 5;
end
if isfield(parameter,'numCutT')==0
    parameter.numCutT = 1;
end
if isfield(parameter,'wCutT')==0
    parameter.wCutT = 15;
end
if isfield(parameter,'value')==0
    parameter.value = 'min';
end


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
    trainingNEW{i}=cutFreqTime(trainingImages{i}, parameter.numCutF, parameter.wCutF, parameter.numCutT,parameter.wCutT, parameter.value);     %apply cut 
end
if isSingle
    trainingNEW = trainingNEW{1};
end
end

function img= cutFreqTime(IM,numCutF,wCutF,numCutT,wCutT,value)
% CUTFREQTIME randomly masks frequency and time bands
%   Input
%   IM: image
%
%   numCutF: number of bands used to mask frequencies (horizontal bands)
%
%   wCutF: width of the frequency masking bands
%
%   numCutT: number of bands used to mask time (vertical bands)
%
%   wCutT: width of the time masking bands
%
%   value: new value of the masked pixels
%
%   Output
%   img: masked image

    if strcmp(value, 'min')
        value = min(IM(:));
    end
    
    pointF=randperm(size(IM,1),numCutF);
    pointT=randperm(size(IM,2),numCutT);
    for i=1:numCutF
        interval=generateInterval(pointF(i),wCutF,size(IM,1),1);
        IM(interval,:,:)=value;
    end
    for i=1:numCutT
        interval=generateInterval(pointT(i),wCutT,size(IM,1),1);
        IM(:,interval,:)=value;
    end
    img=IM;
end


function interval= generateInterval(point,window,upperBound,lowerBound)
% GENERATEINTERVAL computes the interval of the portion of data to
%   mask, checking it is all included between the image size limits
%   (upperBound and loweBound).
    tmpupBound=upperBound;
    tmplowBound=lowerBound;
    if(mod(window-1,2)==1)
        tmp=floor(window-1/2);
        if((point+tmp)<upperBound)
            tmpupBound=point+tmp;
        end
        if((point-tmp-1)>lowerBound)
            tmplowBound=point-tmp-1;
        end
    else
        tmp=floor(window-1/2);
        if((point+tmp)<upperBound)
            tmpupBound=point+tmp;
        end
        if((point-tmp)>lowerBound)
            tmplowBound=point-tmp;
        end
    end
    interval=tmplowBound:1:tmpupBound;
    
end