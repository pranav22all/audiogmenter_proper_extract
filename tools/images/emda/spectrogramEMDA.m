%% spectrogramEMDA.m

function IMout = spectrogramEMDA(IM1,IM2,varargin)
% SPECTROGRAMEMDA applies the Equalized Mixture Data Augmentation (EMDA)
%   algorithm to a couple of spectrograms.
%   Originally, EMDA randomly mixes two sounds of the same class, with 
%   randomly selected timings. Furthermore, it perturbs the sound by 
%   moderately modifying frequency characteristics of each source sound by 
%   boosting/attenuating a particular frequency band.
%   
%   THIS IMPLEMENTATION OF EMDA WORKS WITH SPECTROGRAMS INSTEAD OF AUDIO
%   SIGNALS
%
%   IMout = spectrogramEMDA(IM1,IM2,varargin)
%
%   Input
%   IM1,IM2: spectrograms
%
%   Optionals input
%   freq: [f0min, f0max, fmax]
%       f0min: min center frequency (in relation to fmax)
%       f0max: max center frequency (in relation to fmax)
%       fmax: max frequency of the spectrogram
%   
%   Q: [Qmin, Qmax] are the min and max bandwidth (in pixel)
%
%   gain: [GainMin, GainMax] are the min and max gains
%
%   delayMax: max delay in pixel
%
%   circularShift: if true the delay is applied with a circular shift
%                   if false the dalay is applied with padding
%   Output
%   IMout: new generated spectrogram
%
%   Original publication https://arxiv.org/abs/1604.07160


%default value
f0min = 100;
f0max = 6000;
fmax = 22000;
Qmin = 1;
Qmax = 9;
GainMin = -8;
GainMax = 8;
delayMax = 50;
circularShift = true;
%parse optional arguments
if nargin > 2
    for i = 1:2:length(varargin)
        arg = varargin{i+1};
        switch(varargin{i})
            case 'freq'
                if length(arg) ~= 3
                    error('freq is invalid! Must be [f0min,f0max,fmax]')
                end
                f0min = arg(1);
                f0max = arg(2);
                fmax = arg(3);
            case 'Q'
                if length(arg) ~= 2
                    error('Q is invalid! Must be [min max]')
                end
                Qmin = arg(1);
                Qmax = arg(2);
            case 'gain'
                if length(arg) ~= 2
                    error('gain is invalid! Must be [min max]')
                end
                GainMin = arg(1);
                GainMax = arg(2);
            case 'delayMax'
                if length(arg) ~= 1
                    error('delayMax is invalid! Must be a scalar')
                end
                delayMax = arg;
            case 'circularShift'
                if length(arg) ~= 1
                    error('circularShift is invalid! Must be a scalar')
                end
                circularShift = arg;
            otherwise
                error(strcat('Argument number ', num2str(1+i), ' is not valid!'))
        end
    end
end
%start algorithm
[A,B,~] = size(IM1);
%apply delay
if circularShift
    IM2 = circularShiftFunc(IM2,randi([0,delayMax])); %apply circular shift
else
    %applay delay with padding
    delay = randi([0,delayMax]);
    IM2 = padarray(IM2,[0,delay],0,'pre');
    IM1 = padarray(IM1,[0,delay],0,'post');
end
%combining spectrograms
a = rand(); %random value
IM1 = a * spectrogramEQ(IM1, f0min + rand()*(f0max-f0min), fmax, randi([GainMin,GainMax]), randi([Qmin,Qmax]));
IM2 = (1-a) * spectrogramEQ(IM2, f0min + rand()*(f0max-f0min), fmax, randi([GainMin,GainMax]), randi([Qmin,Qmax]));

[min1,max1] = bounds(IM1,'all');
[min2,max2] = bounds(IM2,'all');
IMout = single(rescale(single(IM1)+single(IM2),min(min1,min2),max(max1,max2))); %sum and rescale

if ~circularShift
    IMout = imresize(IMout,[A,B]); %resize for use in training
end
end

function IM3 = circularShiftFunc(IM,shift)
% CIRCULARSHIFTFUNC circularly shifts the input image IM by shift
if shift == 0
    IM3 = IM;
else
    [a,b,~,~] = size(IM);
    IM1 = imcrop(IM,[0,0,b-shift,a]);
    IM2 = imcrop(IM,[b-shift+1,0,shift,a]);
    IM3 = [IM2 IM1];
end
end