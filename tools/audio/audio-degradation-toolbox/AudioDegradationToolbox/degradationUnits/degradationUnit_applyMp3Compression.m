function [f_audio_out,timepositions_afterDegr] = degradationUnit_applyMp3Compression(f_audio, samplingFreq, timepositions_beforeDegr, parameter)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Name: degradation_applyMp3Compression
% Date: 2013-01-22
% Programmer: Sebastian Ewert
%
% Description:
% - encodes audio using mp3
% - f_audio_out is the decoded version of that mp3
% - uses lame for mp3 handling
% - some binaries for lame are provided. Under linux it additionally tries
%   to  find a binary installed on the system.
% - if no suitable lame can be found please install one and point
%   parameter.LocationLameBinary to it
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
%   .LocationLameBinary    - not set. Use to specify path to lame
%   .LameOptions = '--preset cbr 128'  - lame encoding options
%   .deleteIntermediateFiles = 1 - delete temporary files
%
% Output:
%   f_audio_out   - audio signal \in [-1,1]^{NxC} with C being the number
%                   of channels
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

if isfield(parameter,'LocationLameBinary')==0
    if ispc
        pathstr = 'tools\audio\audio-degradation-toolbox\AudioDegradationToolbox';
        parameter.LocationLameBinary = fullfile(pathstr, '\degradationData\Compressors\lame.exe');
    elseif isunix
        pathstr = 'tools/audio/audio-degradation-toolbox/AudioDegradationToolbox';
        if ismac
            parameter.LocationLameBinary = fullfile(pathstr,'/degradationData/Compressors/lame.mac');
        else
            % linux/unix
            [status,result] = system('which lame');
            if status == 0
                parameter.LocationLameBinary = result;
            else
                parameter.LocationLameBinary = fullfile(pathstr, '/degradationData/Compressors/lame.linux');
                
                [status,result] = system(parameter.LocationLameBinary);
                if status > 1
                    error(['Cannot find a valid lame binary. Possible solutions:',...
                        '1.) Install lame on your system using the package system. ',...
                        '2.) Compile a lame binary yourself and point parameter.LocationLameBinary ',...
                        'to it. See also http://lame.sourceforge.net/'])
                end
            end
        end
    end
    
else
end
if isfield(parameter,'compressionLevel')==0
    parameter.compressionLevel = 'strong'; % {'maximum','strong','medium','light','verylight'};
end
if isfield(parameter,'LameOptions')==0
    parameter.LameOptions = [];  % usually set via parameter.compressionLevel
end
if isfield(parameter,'deleteIntermediateFiles')==0
    parameter.deleteIntermediateFiles = 1;
end
if isfield(parameter,'normalizeOutputAudio')==0
    parameter.normalizeOutputAudio = 1;
end

if ~exist(parameter.LocationLameBinary,'file')
    error('audio_to_mp3: could not find Lame under %s .\n',parameter.LocationLameBinary);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Main program
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

f_audio_out = [];
if ~isempty(f_audio)
    
    if isempty(parameter.LameOptions)
        compressionLevels = {'maximum','strong','medium','light','verylight'};
        indexLevel = find(strcmpi(compressionLevels,parameter.compressionLevel), 1);
        if isempty(indexLevel)
            error('Please specify a valid preset')
        end
        
        switch indexLevel
            case 1
                parameter.LameOptions = '--preset cbr 32';
            case 2
                parameter.LameOptions = '--preset cbr 64';
            case 3
                parameter.LameOptions = '--preset cbr 128';
            case 4
                parameter.LameOptions = '--preset cbr 192';
            case 5
                parameter.LameOptions = '--preset cbr 256';
        end
    end
    
    wavFilenameAndPath = [tempname,'.wav'];
    [tempdir,wavFilename,wavExt] = fileparts(wavFilenameAndPath);
    audiowrite(wavFilenameAndPath,f_audio,samplingFreq,'BitsPerSample',24);
    
    mp3FilenameAndPath = [tempdir,'/',wavFilename,'.mp3'];
    [status,result] = system(sprintf('"%s" %s "%s" "%s"',parameter.LocationLameBinary,parameter.LameOptions,...
        wavFilenameAndPath, mp3FilenameAndPath));
    if status ~= 0
        warning(sprintf('There has been an error during the creation of %s. Error message:\n%s\n',mp3FilenameAndPath,result));
    end
    if parameter.deleteIntermediateFiles
        delete(wavFilenameAndPath);
    end
    
    [status,result] = system(sprintf('"%s" --decode "%s" "%s"',parameter.LocationLameBinary,...
        mp3FilenameAndPath,wavFilenameAndPath ));
    if status ~= 0
        warning(sprintf('There has been an error during the creation of %s. Error message:\n%s\n',wavFilenameAndPath,result));
    end
    if parameter.deleteIntermediateFiles
        delete(mp3FilenameAndPath);
    end
    
    try
        [f_audio_out, fs] = audioread(wavFilenameAndPath);
    catch % fix incorrect chunk size, see http://www.mathworks.com/support/solutions/en/data/1-1BZMF/index.html
        warning('lame returned an ill-formed audio file. Trying to correct the file header...')
        d = dir(wavFilenameAndPath);
        fileSize = d.bytes;
        fid=fopen(wavFilenameAndPath,'r+','l');
        fseek(fid,4,-1);
        fwrite(fid,fileSize-8,'uint32');
        fseek(fid,40,-1);
        fwrite(fid,fileSize-44,'uint32');
        fclose(fid);
        [f_audio_out, fs] = audioread(wavFilenameAndPath);
    end
    
    if parameter.deleteIntermediateFiles
        delete(wavFilenameAndPath);
    end
    
    if fs ~= samplingFreq
        f_audio_out = resample(f_audio_out,samplingFreq,fs);
    end
    
    if parameter.normalizeOutputAudio
        f_audio_out = adthelper_normalizeAudio(f_audio_out, samplingFreq);
    end
    
end

% This degradation does not impose a delay.
% Note: Remark that MP3 does impose a delay on the encoder as well as on
% the decoder side. In case of lame, the decoder delay is the negative to
% the encoder delay so both cancel each other out.
timepositions_afterDegr = timepositions_beforeDegr;

end
