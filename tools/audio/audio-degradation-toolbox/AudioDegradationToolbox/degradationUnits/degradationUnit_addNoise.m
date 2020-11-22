function [f_audio_out,timepositions_afterDegr] = degradationUnit_addNoise(f_audio, samplingFreq, timepositions_beforeDegr, parameter)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Name: degradation_addNoise
% Date of Revision: 2013-01-23
% Programmer: Sebastian Ewert
%
% Description:
% - adds white, pink, or brown noise to f_audio at specific SNR
% - white: white noise (same energy in every two spectral bands of same linear width)
% - pink:  frequency spectrum inversely proportional to frequency (1/f)
%   (i.e. 3db attenuation per octave). Same power level in all octaves
% - brown:  noise produced by Brownian motion. Inversely proportional to
%   frequency squared (1/f^2) (i.e. 6db attenuation per octave)
% - blue: +3db increase per octave (less long term effects)
% - violet: +6db increase per octave  (equivalent to differentiating white noise)
%
% Input:
%   f_audio      - audio signal \in [-1,1]^{NxC} with C being the number of
%                  channels
%   samplingFreq - sampling frequency of f_audio
%   timepositions_beforeDegr - some degradations delay the input signal. If
%                             some points in time are given via this
%                             parameter, timepositions_afterDegr will
%                             return the corresponding positions in the
%                             output. Set to [] if unavailable. Set f_audio
%                             and samplingFreq to [] to compute only
%                             timepositions_afterDegr.
%
% Input (optional): parameter
%   .normalizeOutputAudio = 1 - peak normalize audio after adding the
%                               signals
%   .snrRatio = 20  - in dB.
%                     noise is scaled such that a signal to noise ratio snr_ratio is obtained.
%   .noiseColor = 'pink' %
%   .filterOrderZeros = 3 - number of zeros in the IIR filter
%   .filterOrderPoles = 6 - number of poles in the IIR filter
%   .visualization = 0 - visualizes the magnitude response of the filter
%                        used
%
% Output:
%   f_audio_out   - audio signal \in [-1,1]^{NxC} with C being the number
%                   of channels
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Audio Degradation Toolbox
%
% Centre for Digital Music, Queen Mary University of London.
% This file copyright 2013 Sebastian Ewert, Matthias Mauch and QMUL.
%    
% This program is free software; you can redistribute it and/or
% modify it under the terms of the GNU General Public License as
% published by the Free Software Foundation; either version 2 of the
% License, or (at your option) any later version.  See the file
% COPYING included with this distribution for more information.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Check parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if nargin<4
    parameter=[];
end
if nargin<3
    timepositions_beforeDegr=[];
end
if nargin<2
    error('Please specify input data');
end

if isfield(parameter,'normalizeOutputAudio')==0
    parameter.normalizeOutputAudio = 1;
end
if isfield(parameter,'snrRatio')==0
    parameter.snrRatio = 20; % in dB
end
if isfield(parameter,'filterOrderZeros')==0
    parameter.filterOrderZeros = 3;
end
if isfield(parameter,'filterOrderPoles')==0
    parameter.filterOrderPoles = 6;
end
if isfield(parameter,'noiseColor')==0
    parameter.noiseColor = 'pink';
end
if isfield(parameter,'visualization')==0
    parameter.visualization = 0;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Main program
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

f_audio_out = f_audio;
if ~isempty(f_audio)
    
    filterTheNoise = 1;
    switch(lower( parameter.noiseColor))
        case 'white'
            filterTheNoise = 0;
        case 'pink'
            freqExponent = 0.5;
        case 'brown'
            freqExponent = 1;
        case 'blue'
            freqExponent = -0.5;
        case 'violet'
            freqExponent = -1;
    end
    
    f_noise = rand(size(f_audio))-0.5;
    
    if filterTheNoise
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % designing the filter
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        % building the magnitude response
        Nfft = 8192;  % FFT size to use during filter design
        lengthMagResp = Nfft/2+1;
        freqinfo = linspace(0,samplingFreq/2,lengthMagResp);
        magResp = 1./freqinfo.^freqExponent;
        magResp(1) = 1;
        magRespFull = [magResp,magResp(lengthMagResp-1:-1:2)]; % add negative-frequencies
        magRespFullDb = 20 * log10(magRespFull);
        
        % We want to use invfreqz as a filter design tool (least squares fit to
        % given mag response). However, invfreqz also needs a phase response and is
        % very sensitive to it. We use the cepstrum method to compute a min-phase
        % frequency response from the mag response:
        
        % Fold cepstrum to reflect non-min-phase zeros inside unit circle:
        cepstrum = ifft(magRespFullDb); % compute real cepstrum from log magnitude spectrum
        cepstrumFolded = [cepstrum(1), cepstrum(2:lengthMagResp-1)+cepstrum(Nfft:-1:lengthMagResp+1), cepstrum(lengthMagResp), zeros(1,Nfft-lengthMagResp)];
        cepstrumFolded = fft(cepstrumFolded);
        magRespFullDbNew = 10 .^ (cepstrumFolded/20);
        
        magRespFullDbNewPos = magRespFullDbNew(1:lengthMagResp); % nonnegative-frequency portion
        weightVector = 1 ./ (freqinfo+1); % weighting the importance
        freqinfo_rad = 2*pi*freqinfo/samplingFreq;
        [B,A] = invfreqz(magRespFullDbNewPos,freqinfo_rad,parameter.filterOrderZeros,parameter.filterOrderPoles,weightVector);
        
        if parameter.visualization
            fvtool(B,A);
        end
        
        f_noise = filter(B,A,f_noise);
    end
    
    parameter.loadInternalSound = 0;
    parameter.addSound = f_noise;
    parameter.addSoundSamplingFreq = samplingFreq;
    f_audio_out = degradationUnit_addSound(f_audio_out, samplingFreq, [], parameter);
    
end


% This degradation does not impose a delay
timepositions_afterDegr = timepositions_beforeDegr;

end




