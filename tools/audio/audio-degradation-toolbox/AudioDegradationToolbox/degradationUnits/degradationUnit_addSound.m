function [f_audio_out,timepositions_afterDegr] = degradationUnit_addSound(f_audio, samplingFreq, timepositions_beforeDegr, parameter)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Name: degradation_addSound
% Date of Revision: 2013-01-23
% Programmer: Sebastian Ewert
%
% Description:
% - adds f_audioAdd to f_audio, looping f_audioAdd if necessary
% - sampling rate of f_audioAdd will be adjusted to be equal to samplingFreq
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
%   .snrRatio = 10  - in dB. Treating "f_audioAdd" as noise, f_audioAdd is
%                     scaled such that a signal to noise ratio snr_ratio is obtained.
%                     Signal energy is the total energy for both signals (after f_audioAdd
%                     was looped if necessary)
%   .transposeSignalsIfNecessary=1 -
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

if isfield(parameter,'loadInternalSound')==0
    parameter.loadInternalSound = 1;
end
if isfield(parameter,'internalSound')==0
    parameter.internalSound = 'OldDustyRecording';
end
if isfield(parameter,'normalizeOutputAudio')==0
    parameter.normalizeOutputAudio = 1;
end
if isfield(parameter,'snrRatio')==0
    parameter.snrRatio = 0; % in dB
end
if isfield(parameter,'transposeSignalsIfNecessary')==0
    parameter.transposeSignalsIfNecessary = 1;
end
if isfield(parameter,'addSound')==0
    parameter.addSound = [];
end
if isfield(parameter,'addSoundSamplingFreq')==0
    parameter.addSoundSamplingFreq = 0;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Main program
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
f_audio_out = f_audio;
if ~isempty(f_audio)
    
    if parameter.loadInternalSound
        % load sound included in toolbox
        
        fullFilenameMfile = mfilename('fullpath');
        [pathstr,name,ext] = fileparts(fullFilenameMfile);
        dirRootIRs = fullfile(pathstr,'../degradationData');
        
        names_internalSounds = {'OldDustyRecording', 'PubEnvironment1', 'Hum50Hz'};
        indexSound = find(strcmpi(names_internalSounds,parameter.internalSound), 1);
        if isempty(indexSound)
            error('Please specify a valid internal name')
        end
        
        switch indexSound
            case 1
                file = fullfile(dirRootIRs,'VinylSim/old_dusty_vinyl_recording.wav');
            case 2
                file = fullfile(dirRootIRs,'PubSounds/restaurant08.wav');
            case 3
                file = fullfile(dirRootIRs,'PubSounds/hum_50Hz_from_headphone_plug.wav');
        end
        [f_audioAdd,samplingFreqAdd] = audioread(file);
    else
        f_audioAdd = parameter.addSound;
        samplingFreqAdd = parameter.addSoundSamplingFreq;
    end
    
    if isempty(f_audioAdd) || (samplingFreqAdd == 0)
        error('To use %s you must specify parameter.addSound and parameter.addSoundSamplingFreq',mfilename());
    end
    
    if parameter.transposeSignalsIfNecessary
        if size(f_audio,1) < size(f_audio,2)
            f_audio = f_audio';
        end
        if size(f_audioAdd,1) < size(f_audioAdd,2)
            f_audioAdd = f_audioAdd';
        end
    end
    
    numChannels1 = size(f_audio,2);
    numChannels2 = size(f_audioAdd,2);
    MinNumberChannel=min([numChannels1 numChannels2]);
    
    if (numChannels1 ~= numChannels2)
        f_audio=f_audio(:,1:MinNumberChannel);
        f_audioAdd=f_audioAdd(:,1:MinNumberChannel);
    end
    
    if samplingFreq ~= samplingFreqAdd
        f_audioAdd = resample(f_audioAdd,samplingFreq,samplingFreqAdd);
    end
    
    numLength1 = size(f_audio,1);
    numLength2 = size(f_audioAdd,1);
    numFullRepetitions = floor(numLength1/numLength2);
    
    totalAdditiveSound = zeros(numLength1,numChannels2);
    totalAdditiveSound(1:numFullRepetitions*numLength2,:) = repmat(f_audioAdd,numFullRepetitions,1);
    totalAdditiveSound(numFullRepetitions*numLength2+1:numLength1,:) = f_audioAdd(1:numLength1-numFullRepetitions*numLength2,:);
    
    if parameter.snrRatio == inf
        scaler = 0;
        prescaler = 1;
    elseif parameter.snrRatio == -inf
        scaler = 1;
        prescaler = 0;
    else
        power1 = sum(f_audio.^2);
        power2 = sum(totalAdditiveSound.^2);
        if (numChannels2 == 1)
            power2 = repmat(power2,1,numChannels1);
        end
        
        destSnr = parameter.snrRatio;
        
        scaler = sqrt( power1 ./ (power2 * 10^(destSnr/10)) );
        prescaler = 1;
    end
    
    f_audio_out = zeros(size(f_audio));
    if (numChannels2 == 1)
        for nc=1:numChannels1
            f_audio_out(:,nc) = prescaler * f_audio(:,nc) + scaler(nc) * totalAdditiveSound;
        end
    else
        for nc=1:numChannels1
            f_audio_out(:,nc) = prescaler * f_audio(:,nc) + scaler(nc) * totalAdditiveSound(:,nc);
        end
    end
    
    if parameter.normalizeOutputAudio
        f_audio_out = adthelper_normalizeAudio(f_audio_out, samplingFreq);
    end
    
end

% This degradation does not impose a delay
timepositions_afterDegr = timepositions_beforeDegr;

end




