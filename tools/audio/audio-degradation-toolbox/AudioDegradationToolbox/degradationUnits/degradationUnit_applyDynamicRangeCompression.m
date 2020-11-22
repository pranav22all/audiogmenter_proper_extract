function [f_audio_out,timepositions_afterDegr] = degradationUnit_applyDynamicRangeCompression(f_audio, samplingFreq, timepositions_beforeDegr, parameter)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Name: degradation_applyDynamicRangeCompression
% Version: 1
% Date: 2013-01-23
% Programmer: Matthias Mauch, Sebastian Ewert
%
% Description:
% - applies dynamic range compression to a signal
% - f_audio_out is the compressed audio
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
%    .preNormalization = 0; % db for 95% RMS quantile / 0 means "off"
%    .forgettingTime = 0.1; % seconds
%    .compressorThreshold = -40; % dB
%    .compressorSlope = 0.9;
%    .attackTime = 0.01; % seconds
%    .releaseTime = 0.01; % seconds
%    .delayTime = 0.01; % seconds
%    .normalizeOutputAudio = 1;
%
% Output:
%   f_audio_out      - audio output signal
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

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

if isfield(parameter,'preNormalization')==0
    parameter.preNormalization = 0; % db for 95% RMS quantile / 0 means "off"
end
if isfield(parameter,'forgettingTime')==0
    parameter.forgettingTime = 0.1; % seconds
end
if isfield(parameter,'compressorThreshold')==0
    parameter.compressorThreshold = -40; % dB
end
if isfield(parameter,'compressorSlope')==0
    parameter.compressorSlope = 0.9;
end
if isfield(parameter,'attackTime')==0
    parameter.attackTime = 0.01; % seconds
end
if isfield(parameter,'releaseTime')==0
    parameter.releaseTime = 0.01; % seconds
end
if isfield(parameter,'delayTime')==0
    parameter.delayTime = 0.01; % seconds
end
if isfield(parameter,'normalizeOutputAudio')==0
    parameter.normalizeOutputAudio = 1;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Main program
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

f_audio_out = [];
if ~isempty(f_audio)
    
    %% secondary parameters
    
    AT = 1 - exp(-2.2/(samplingFreq*parameter.attackTime)); % attack parameter
    RT = 1 - exp(-2.2/(samplingFreq*parameter.releaseTime)); % release parameter
    FT = 1 - exp(-2.2/(samplingFreq*parameter.forgettingTime)); % forgetting parameter
    
    delay = floor(parameter.delayTime * samplingFreq);
    
    mono_audio = mean(f_audio, 2);
    
    if parameter.preNormalization < 0
        quantMeasured = max(quantile(abs(mono_audio), 0.95),eps);
        quantWanted = db2mag(parameter.preNormalization);
        f_audio = f_audio * quantWanted / quantMeasured;
        mono_audio = mono_audio * quantWanted / quantMeasured;
    end
    
    %%
    
    nSample = size(f_audio, 1);
    nChannel = size(f_audio, 2);
    
    if AT == RT
        % Vectorized version
        %%
        runningMS_all = filter(FT,[1 -(1-FT)],mono_audio.^2);
        runningRMSdB_all = 10 * log10(runningMS_all);
        gainDB_all = min([zeros(1,length(runningRMSdB_all));...
            parameter.compressorSlope * (parameter.compressorThreshold - runningRMSdB_all(:)')]);
        preGain_all = 10.^(gainDB_all/20);
        gain_all = filter(AT,[1 -(1-AT)],[1/AT,preGain_all(2:end)]);
        % The next line is equivalent to the behaviour of the serial version. Is that a bug?
        %f_audio_out = repmat(gain_all(:),1,nChannel) .* [zeros(delay+1,nChannel);f_audio(1:end-(delay+1),:)];
        f_audio_out = repmat(gain_all(:),1,nChannel) .* [zeros(delay,nChannel);f_audio(1:end-delay,:)];
    else
        % Serial version (The non-linearity 'if preGain < gain' does not seem to allow for a vectorization in all cases)
        %%
        runningMS = mono_audio(1)^2 * FT;
        gain = 1;
        buffer = zeros(delay + 1, nChannel);
        f_audio_out = zeros(size(f_audio));
        
        for iSample = 2:nSample
            runningMS = ...
                runningMS * (1-FT) +...
                mono_audio(iSample)^2 * FT;
            runningRMSdB = 10 * log10(runningMS);
            
            gainDB = min([0, ...
                parameter.compressorSlope * (parameter.compressorThreshold - runningRMSdB)]);
            preGain = 10^(gainDB/20);
            
            if preGain < gain % "gain" being old gain
                coeff = AT;   % we're in the attack phase
            else
                coeff = RT;   % we're in the release phase
            end
            
            % calculate new gain as mix of current gain (preGain) and old gain
            gain = (1-coeff) * gain + coeff * preGain;
            
            f_audio_out(iSample, :) = gain * buffer(end,:);
            if delay > 1
                buffer = [f_audio(iSample, :); buffer(1:end-1,:)];
            else
                buffer = f_audio(iSample, :);
            end
        end
    end
    
    if parameter.normalizeOutputAudio
        f_audio_out = adthelper_normalizeAudio(f_audio_out, samplingFreq);
    end
    
end

% This degradation does impose a temporal distortion
timepositions_afterDegr = timepositions_beforeDegr + parameter.delayTime;

end




