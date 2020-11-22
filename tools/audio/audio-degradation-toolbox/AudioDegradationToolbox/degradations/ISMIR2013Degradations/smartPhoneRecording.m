function degradation_config = smartPhoneRecording()
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Preset: radioBroadcast
% Date of Revision: 2013-04
% Programmer: Sebastian Ewert
%
% Description:
% - simulating a user holding a phone in front of a speaker
% - this degradation preset employs
%   * degradation_applyFirFilter to apply an impulse response taken from 
%     the mic of a typical smart phone (Google Nexus One)
%   * degradation_applyDynamicRangeCompression to simulate the phone's auto-gain
%   * degradation_applyClippingAlternative to apply some clipping
%   * degradation_addNoise to add noise (preset is light pink noise)
% - note that the impulse responses for the phones were not recorded in a 
%   perfect unechoic chamber but in a normal studio environment. Therefore,
%   the studio's room response is mixed in (acceptable considering the goal
%   of this simulation)
% - note that many (early) UMTS/3G phones employ DSPs cutting of
%   frequencies above 8kHz even for normal recordings (i.e. without
%   transmitting the signal over the network).
%   GSM/2G phones usually even cut at 4kHz.
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

degradation_config(1).methodname = 'degradationUnit_applyImpulseResponse';
degradation_config(1).parameter.loadInternalIR = 1;
degradation_config(1).parameter.internalIR = 'GoogleNexusOneFrontMic';

degradation_config(2).methodname = 'degradationUnit_applyDynamicRangeCompression';
degradation_config(2).parameter.forgettingTime = 0.2; % seconds
degradation_config(2).parameter.compressorThreshold = -35; % dB
degradation_config(2).parameter.compressorSlope = 0.5;
degradation_config(2).parameter.attackTime = 0.01; % seconds
degradation_config(2).parameter.releaseTime = 0.01; % seconds
degradation_config(2).parameter.delayTime = 0.01; % seconds

degradation_config(3).methodname = 'degradationUnit_applyClippingAlternative';
degradation_config(3).parameter.percentOfSamplesClipped = 0.3;

degradation_config(4).methodname = 'degradationUnit_addNoise';
degradation_config(4).parameter.snrRatio = 35; % in dB
degradation_config(4).parameter.noiseColor = 'pink';

degradation_config(5).methodname = 'adthelper_normalizeAudio';


end




