%% spectrogramSum.m

function IM = spectrogramSum(varargin)
% SPECTROGRAMSUM sums an arbitary number nargin of spectrograms and
%   normalizes them to preserve the original minimum and maximum
%   intensities among all the imagesmax amplitude. A 64-bit variable is
%   used for the sum
%
%   IM = spectrogramSum(varargin)
%
%   Input
%   varargin: variable number of spectrograms 
%
%   Output
%   IM: sum spectrogram

if nargin < 2
    error('spectrogramSum requires at least 2 images')
end

amin = 100000; %dummy value
amax = -1; %dummy value
%find min and max value off all images
for i = 1:nargin
    [m,M] = bounds(varargin{i}, 'all'); 
    if m < amin
        amin(1) = m;
    end
    if M > amax
        amax(1) = M;
    end
end

IM = single(zeros(size(varargin{1})));
for i = 1:nargin
    IM = IM + single(varargin{i}); %sum images
end
IM = single(rescale(IM,amin,amax)); %rescale
end