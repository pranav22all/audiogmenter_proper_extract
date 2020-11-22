%% spectrogramEQ.m

function IM = spectrogramEQ(IM,f0,fmax,gain,Q)
% SPECTROGRAMEQ simulates an effect similar to the one
%produced by an equalizer on a spectrogram.
%
%   Input
%   IM: spectrogram
%
%   f0: center frequency of the equalization (in relation to fmax)
%
%   fmax: maximum frequency represented in the spectrogram
%
%   gain: gain to apply in f0
%
%   Q: quality factor
%
%   Output
%   IM = equalized spectrogram
%
%   NOTE: if the BW is too large for the choosen f0 it will be reduced
if f0 > fmax
    error('f0 must be <= fmax')
end
A = size(IM,1);
B = size(IM,2);
C = size(IM,3);
%The brandwidth in Hz is BW = f0/Q
BW = ((f0/Q)/fmax)*A; %Brandwidth in pixel
f0 = round(f0 * A/fmax);
if f0 + BW/2 > A || f0 - BW/2 < 1
    BW(1) = min((A-f0)*2, f0*2-1);
end
f1 = f0 - floor(BW/2);
f2 = f0 + floor(BW/2);
gainsArray = single(linspace(1,gain,BW/2+1));
gainsArray = repmat(gainsArray(1:end-1)',1,B,C);
IM(f0,:,:,:) = IM(f0,:,:,:) + gain;
IM(f1:f1+floor(BW/2)-1,:,:,:) = IM(f1:f1+floor(BW/2)-1,:,:,:) + gainsArray;
IM(f2-floor(BW/2)+1:f2,:,:) = IM(f2-floor(BW/2)+1:f2,:,:) + flipud(gainsArray);
end