function degradation_config = smartPhonePlayback()
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Preset: smartPhonePlayback
% Date of Revision: 2013-04
% Programmer: Sebastian Ewert
%
% Description:
% - simulating a user playing a song on this mobile phone
% - this degradation preset employs
%   * degradation_applyImpulseResponse to apply an impulse response taken from 
%     the speaker of a typical smart phone
%   * degradation_addNoise to add noise (preset is light pink noise at 40db SNR)
% - note that due to the size of speakers in a phone the speaker often
%   cannot play bass sounds. This cut-off can be as high as 400-600 Hz.
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
degradation_config(1).parameter.internalIR = 'GoogleNexusOneFrontSpeaker';

degradation_config(2).methodname = 'degradationUnit_addNoise';
degradation_config(2).parameter.snrRatio = 40; % in dB
degradation_config(2).parameter.noiseColor = 'pink';

degradation_config(3).methodname = 'adthelper_normalizeAudio';

end




