function degradation_config = vinylRecording()
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Preset: vinylRecording
% Date of Revision: 2013-04
% Programmer: Sebastian Ewert
%
% Description:
% - this degradation preset employs
%   * degradation_applyFirFilter to apply an impulse response taken from a
%     vinyl player
%   * degradation_addSound to add some sounds originating from the player
%     mechanics
%   * degradation_applyWowResampling to simulate wow-and-flutter
%   * degradation_addNoise to add noise (preset is light pink noise at 40db SNR)
%   * adthelper_normalizeAudio to normalize the output audio
% - First, applies an impulse response taken from a vinyl player
% - Then, a recording of cranking sounds (dust, mechanical noise,...) is
%   added
% - then some light pink noise is added
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
degradation_config(1).parameter.internalIR = 'VinylPlayer1960';

degradation_config(2).methodname = 'degradationUnit_addSound';
degradation_config(2).parameter.loadInternalSound = 1;
degradation_config(2).parameter.internalSound = 'OldDustyRecording';
degradation_config(2).parameter.snrRatio = 40; % in dB

degradation_config(3).methodname = 'degradationUnit_applyWowResampling';
degradation_config(3).parameter.intensityOfChange = 1.3;    
degradation_config(3).parameter.frequencyOfChange = 33/60;  % vinyl at 33 rpm

degradation_config(4).methodname = 'degradationUnit_addNoise';
degradation_config(4).parameter.snrRatio = 40; % in dB
degradation_config(4).parameter.noiseColor = 'pink';

degradation_config(5).methodname = 'adthelper_normalizeAudio';

end




