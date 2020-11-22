%% VTLN.m

function Iout = VTLN(IM,f0,fmax,rangeA)
% VTLN generates a new spectrogram image based on the Vocal Tract Lenght
% Normalization (VTLN) and Perturbation (VTLP). VTLN is used to remove
% speaker to speaker variability resulting from differences in vocal tract 
% length (Lee & Rose, 1998). The frequency axis of the spectrogram of each 
% speaker is linearly warped using the factor a, that accounts for 
% the relative length of the speakers's vocal tract compared to the
% canonical mean. 
%
% This implementation takes into account also the a values for perturbation
% instead of normalization, as in Jaitly & Hinton, 2013)
%
%   Iout = VTLN(IM,f0,fmax,rangeA)
%
%   Input
%   IM: image (spectrogram)

%   f0: empirically chosen frequency (relate to fmax)

%   fmax: max frequency of the spectrogram

%   rangeA: range of random factor 'a' in form of array [min max]. a should
%      be between 0.8 and 1.2. If rangeA is empty then is used a random
%      value between 0.9 and 1.1 (to corrupt)
%
%   Output
%   Iout: transformed image
%
%   Original publications 
%   - (Lee & Rose, 1998) DOI: 10.1109/89.650310 
%   - (Jaitly & Hinton, 2013) https://scinapse.io/papers/2099621636


%check f0 <= fmax
if f0 > fmax
    error('f0 must be <= fmax')
end
%generate factor a
if isempty(rangeA)
    % corruption
    a = 0.9 + rand * 0.2;
elseif length(rangeA) == 2
    %normalization
    a = rangeA(1) + rand * (rangeA(2) - rangeA(1));
else
    error('rangeA is not valid!');
end
%prepare image
IM = double(IM);
[rows,columns,depth] = size(IM);
x = linspace(0,fmax,columns);
y = flipud(linspace(0,fmax,rows));
[X,Y] = meshgrid(x,y);
%define transformation with VTLN algorithm
Q = a * Y; %matrix for new y coordinates
Y2 = ((fmax-a*f0)/(fmax-f0))*(Y-f0)+a*f0;
Q(Y>f0) = Y2(Y>f0);
Iout = single(zeros(rows,columns,depth)); %preallocation
for d = 1:depth
    Iout(:,:,d) = single(round(interp2(X,Y,IM(:,:,d),X,Q,'linear',0))); %apply transformation to the image
end
end