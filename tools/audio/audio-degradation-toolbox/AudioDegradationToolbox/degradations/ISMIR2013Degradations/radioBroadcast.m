function degradation_config = radioBroadcast()
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Preset: radioBroadcast
% Date of Revision: 2013-04
% Programmer: Sebastian Ewert
%
% Description:
% - this degradation preset employs
%   * degradation_applyDynamicRangeCompression
%   * degradation_applySpeedup to simulate the increased playback speed
%     radio station often use
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

degradation_config(1).methodname = 'degradationUnit_applyDynamicRangeCompression';
degradation_config(1).parameter.forgettingTime = 0.3; % seconds
degradation_config(1).parameter.compressorThreshold = -40; % dB
degradation_config(1).parameter.compressorSlope = 0.6;
degradation_config(1).parameter.attackTime = 0.2; % seconds
degradation_config(1).parameter.releaseTime = 0.2; % seconds
degradation_config(1).parameter.delayTime = 0.2; % seconds

degradation_config(2).methodname = 'degradationUnit_applySpeedup';
degradation_config(2).parameter.changeInPercent = +2;

degradation_config(3).methodname = 'adthelper_normalizeAudio';

end


