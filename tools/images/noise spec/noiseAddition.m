%% noiseAddition.m

function imgOut=noiseAddition(imgIn,prob,sigma)
% NOISEADDITION adds noise to the input image with probability threshold 
%   prob. For each pixel in the input image, this function picks a random 
%   number and if it is smaller than the probability threshold, it 
%   multiplies the pixel value by a normal random number.
%
%   imgOut=noiseAddiction(imgIn,prob)
%
%   Input
%   imgIn: input image
%
%   prob: probability threshold for image corruption. 
%   sigma: value of the noise
%
%   Output
%   imgOut:  corrupted output image

% Probability scaling partamters
a=0;
b=1;

for j=1:size(imgIn,1)
    for k=1:size(imgIn,2)
        r=(b-a)*rand + a;
        if r<prob
            imgIn(j,k)=imgIn(j,k)*(1+sigma*(rand()-0.5));
        end
    end
end
imgOut = imgIn;
end