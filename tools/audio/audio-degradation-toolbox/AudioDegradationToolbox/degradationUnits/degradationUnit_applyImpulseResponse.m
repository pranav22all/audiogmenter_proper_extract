function [f_audio_out,timepositions_afterDegr] = degradationUnit_applyImpulseResponse(f_audio, samplingFreq, timepositions_beforeDegr, parameter)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Name: degradation_applyImpulseResponse
% Date of Revision: 2013-04
% Programmer: Sebastian Ewert
%
% Description:
% - applies an FIR filter
% - takes care that f_audio and firfilter use same sampling frequency
% - set samplingFreqFilter = samplingFreq if you do not which to resample
%   the filter
% - predefines IR: 'GreatHall1','Classroom1','Octagon1',
%                  'GoogleNexusOneFrontSpeaker','GoogleNexusOneFrontMic'
%                  'VinylPlayer1960'
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
%   .presetIR = 'GreatHall1';          - load IR from a ADT preset
%   .impulseResponse = [];             - IR to apply
%   .impulseResponseSampFreq = 0;      - sampling rate of IR
%   .normalizeOutputAudio = 1          - normalize output
%   .normalizeImpulseResponse = 0      - l1-normalize firfilter before
%                                        application
%
% Output:
%   f_audio_out      - audio signal \in [-1,1]^{NxC} with C being the number of
%                      channels
%   timepositions_afterDegr - time positions corresponding to timepositions_beforeDegr
%
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
if isfield(parameter,'loadInternalIR')==0
    parameter.loadInternalIR = 1;
end
if isfield(parameter,'internalIR')==0
    parameter.internalIR = 'GreatHall1';
end
if isfield(parameter,'normalizeOutputAudio')==0
    parameter.normalizeOutputAudio = 1;
end
if isfield(parameter,'normalizeImpulseResponse')==0
    parameter.normalizeImpulseResponse = 0;
end
if isfield(parameter,'impulseResponse')==0
    parameter.impulseResponse = [];
end
if isfield(parameter,'impulseResponseSampFreq')==0
    parameter.impulseResponseSampFreq = 0;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Main program
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if parameter.loadInternalIR
    % load IR included in toolbox
    if ispc
        dirRootIRs = '\tools\audio\audio-degradation-toolbox\AudioDegradationToolbox\degradationData';
    elseif isunix
        dirRootIRs = '/tools/audio/audio-degradation-toolbox/AudioDegradationToolbox/degradationData';
    end
    
    names_internalIR = {'GreatHall1','Classroom1','Octagon1','GoogleNexusOneFrontSpeaker','GoogleNexusOneFrontMic','VinylPlayer1960'};
    indexIR = find(strcmpi(names_internalIR,parameter.internalIR), 1);
    if isempty(indexIR)
        error('Please specify a valid preset')
    end
    
    switch indexIR
        case 1
            file = fullfile(dirRootIRs,'RoomResponses','GreatHall_Omni_x06y06.wav');
        case 2
            file = fullfile(dirRootIRs,'RoomResponses','Classroom_Omni_30x20y.wav');
        case 3
            file = fullfile(dirRootIRs,'RoomResponses','Octagon_Omni_x06y06.wav');
        case 4
            file = fullfile(dirRootIRs,'PhoneResponses','IR_GoogleNexusOneFrontSpeaker.wav');
        case 5
            file = fullfile(dirRootIRs,'PhoneResponses','IR_GoogleNexusOneFrontMic.wav');
        case 6
            file = fullfile(dirRootIRs,'VinylSim','ImpulseReponseVinylPlayer1960_smoothed.wav');
    end
    [parameter.impulseResponse,parameter.impulseResponseSampFreq] = audioread(file);
end

fs = samplingFreq;
h = parameter.impulseResponse;
fs_h = parameter.impulseResponseSampFreq;
h_org = h;

f_audio_out = [];
if ~isempty(f_audio)

    if (size(h,2) > 1) && (size(h,1) ~= 1)
        error('Multichannel impulse responses are not supported');
    end
    
    if fs ~= fs_h
        h = resample(h,fs,fs_h);
    end
    
    if parameter.normalizeImpulseResponse
        h = h / max(abs(h));
    end
    
    f_audio_out = fftfilt(h,f_audio);
    
    if parameter.normalizeOutputAudio
        f_audio_out = adthelper_normalizeAudio(f_audio_out, samplingFreq);
    end
end

% This degradation does impose a delay
timepositions_afterDegr = [];
if ~isempty(timepositions_beforeDegr)
    % approximation via group delay
        
    [Gd,W] = mygrpdelay(h_org,1,fs_h,2048);  
    %[Gd,W] = grpdelay(h_org,1,1024);  % Matlab's own group delay function. Failt for some filters considerably.
    
    %figure;
    %plot(W,Gd/samplingFreqFilter)

    averageOfGroupDelays = mean(Gd);
    timeOffset_sec = averageOfGroupDelays / fs_h;
    
    timepositions_afterDegr = timepositions_beforeDegr + timeOffset_sec;
end

end

function [gd,w] = mygrpdelay(b,a,Fs,nfft)
% see also https://ccrma.stanford.edu/~jos/fp/Group_Delay_Computation_grpdelay_m.html

b = b(:);
a = a(:);

w=Fs*[0:nfft-1]/nfft;
oa = length(a)-1;             % order of a(z)
oc = oa + length(b)-1;        % order of c(z)
c = conv(b,fliplr(a));	% c(z) = b(z)*a(1/z)*z^(-oa)
cr = c.*[0:oc]';               % derivative of c wrt 1/z
num = fft(cr,nfft);
den = fft(c,nfft);
minmag = 10*eps;
polebins = find(abs(den)<minmag);
num(polebins) = 0;
den(polebins) = 1;
gd = real(num ./ den) - oa;

ns = nfft/2; % Matlab convention - should be nfft/2 + 1
gd = gd(1:ns);
w = w(1:ns);

w = w(:); % Matlab returns column vectors
gd = gd(:);

end



