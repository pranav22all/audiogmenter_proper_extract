%% spectrogramShift.m

function IMshift = spectrogramShift(IM,shift,type)
% SPECTROGRAMSHIFT shifts a spectrogram by shift pixels in time or pitch 
%   cropping the input spectrogram along it vertical or horizontal
%   direction, respectively.  
%
%   IMshift = spectrogramShift(IM,shift,type)
%
%   Input
%   IM: original spectrogram
%
%   shift: shift amount in pixel
%
%   type: "time" or "pitch"
%
%   Output
%   IMshift: shifted spectrogram

type = string(type);
if type == "time"
    IMshift = timeShift(IM,shift);
elseif type == "pitch"
    IMshift = pitchShift(IM,shift);
else
    error('Type not valid! It must be "time" or "pitch"');
end
end


function IM3 = timeShift(IM,shift)
[a,b,~,~] = size(IM);
IM1 = imcrop(IM,[0,0,b-shift,a]);
IM2 = imcrop(IM,[b-shift+1,0,shift,a]);
IM3 = [IM2 IM1];
end
function IM3 = pitchShift(IM,shift)
[a,b,~,~] = size(IM);
IM1 = imcrop(IM,[0,0,b,a-shift]);
IM2 = imcrop(IM,[0,a-shift+1,b,shift]);
IM3 = [IM2; IM1];
end