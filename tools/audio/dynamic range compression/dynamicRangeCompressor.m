%% dynamicRangeCompressor.m

function audioOut = dynamicRangeCompressor(audio,parameter)
%DYNAMICRANGECOMPRESSOR applies a dynamic range compression (DRC) with 
%   default or custom parameters.
%   IN THIS IMPLEMENTATION, THE SETTINGS ARE HARD CODED TO THE 'MUSIC'
%   SETTINGS
%   
%   audioOut = dynamicRangeCompressor(audio,parameter)
%
%   Input
%   audio: the raw audio signal
%
%   parameters:
%       useIntenalSettings: if equals to 1, it uses the default settings, 
%           otherwise custom settings (default setting =1)
%       intenalSettings: select type of DRC from: 'music', 'film' or 
%           'speech' (default setting = music)
%
%   Customizable parameters
%    - maxBoost: boost (dB) for the intensities in the region below the 
%       BOOST region
%    - boostRangeBegin: starting intensity for the BOOST region
%    - boostRangeRatio: boost ratio for then intensities within the BOOST
%       region
%    - nullRangeBegin: starting intensity for the NULL region where no 
%       boost is applied. The BOOST region ends here
%    - earlyCutRangeBegin: starting intensity for the EARLY CUT region  
%       where intensities are attenuated by the earlyCutRangeRatio. The  
%       NULL region ends here
%    - earlyCutRangeRatio: attenuation ratio for then intensities within 
%       the EARLY CUT region
%    - cutRangeBegin: starting intensity for the CUT region where the 
%       intensities are attenuated by the cutRangeRatio. The EARLY CUT 
%       region ends here
%    - cutRangeRatio: attenuation ratio for then intensities in the CUT
%       region
%
%   Output
%   audioOut: compressed audio signal
%
%   DRC was used in https://ieeexplore.ieee.org/document/7829341
%   The original Dolby documentation is available at 
%   https://www.dolby.com/us/en/technologies/standards-and-practices-for-authoring-dolby-digital-and-dolby-e-bitstreams.pdf

if nargin<2
    parameter=[];
end

if isfield(parameter,'useIntenalSettings')==0   %set useIntenalSettings parameter to 1 if you want use the internal settings or use 0 if you want use your settings
    parameter.useIntenalSettings = 1;
end
if( parameter.useIntenalSettings == 1)
    if isfield(parameter,'intenalSettings')==0  %decide the type of DRC between audio, film and speach
        parameter.intenalSettings = 'music';
    end
    switch parameter.intenalSettings
        case 'music'    %it use the music standard setting from dolby-e standard
            maxBoost=12;    
            boostRangeBegin=-55;
            boostRangeRatio=2;
            nullRangeBegin=-31;
            earlyCutRangeBegin=-26;
            earlyCutRangeRatio=2;
            cutRangeBegin=-16;
            cutRangeRatio=20;
        case 'film'     %it use the film standard setting from dolby-e standard
            maxBoost=4;    
            boostRangeBegin=-43;
            boostRangeRatio=2;
            nullRangeBegin=-31;
            earlyCutRangeBegin=-26;
            earlyCutRangeRatio=2;
            cutRangeBegin=-16;
            cutRangeRatio=20;
        case 'speech'   %it use the speech setting from dolby-e standard
            maxBoost=15;    
            boostRangeBegin=-50;
            boostRangeRatio=5;
            nullRangeBegin=-31;
            earlyCutRangeBegin=-26;
            earlyCutRangeRatio=2;
            cutRangeBegin=-16;
            cutRangeRatio=20;
    end
else
    if isfield(parameter,'maxBoost')==0
        error('Please specify maxBoost data');
    end
    if isfield(parameter,'boostRangeBegin')==0
        error('Please specify boostRangeBegin data');
    end
    if isfield(parameter,'nullRangeBegin')==0
        error('Please specify nullRangeBegin data');
    end
    if isfield(parameter,'boostRangeRatio')==0
        error('Please specify boostRangeRatio data');
    end
    if isfield(parameter,'earlyCutRangeBegin')==0
        parameter.earlyCutRangeBegin = 0;
    end
    if isfield(parameter,'earlyCutRangeRatio')==0
        parameter.earlyCutRangeRatio = 0;
    end
    if isfield(parameter,'cutRangeBegin')==0
        error('Please specify cutRangeBegin data');
    end
    if isfield(parameter,'cutRangeRatio')==0
        error('Please specify cutRangeRatio data');
    end
    maxBoost=parameter.maxBoost;    
    boostRangeBegin= parameter.boostRangeBegin;
    boostRangeRatio=parameter.boostRangeRatio;
    nullRangeBegin=parameter.nullRangeBegin;
    if parameter.earlyCutRangeBegin==0    %in the case the personal setting doesn't have an early cut range
        earlyCutRangeBegin=parameter.cutRangeBegin;
        earlyCutRangeRatio=parameter.cutRangeRatio;
        cutRangeBegin=0;
        cutRangeRatio=0;
    else
        earlyCutRangeBegin=parameter.earlyCutRangeBegin;
        earlyCutRangeRatio=parameter.earlyCutRangeRatio;
        cutRangeBegin=parameter.cutRangeBegin;
        cutRangeRatio=parameter.cutRangeRatio;
    end
    
end
audioOut=zeros(size(audio,1),size(audio,2));
for i=1:size(audio,2)
    oldY=20*log10(abs(audio(:,i)));   %old track value
    y=oldY;      %new track value
    for j=1:length(y)
        if y(j)<=nullRangeBegin      %apply boost range
            y(j) = min(y(j),boostRangeBegin)+(1/boostRangeRatio)*max(0,y(j)-boostRangeBegin)+maxBoost;
        end
    end
    if cutRangeBegin~=0 %in the case the setting have an early cut range
    y = min(y,cutRangeBegin)+(1/(cutRangeRatio/earlyCutRangeRatio))*max(0,y-cutRangeBegin);     %apply cut range
    end
    y = min(y,earlyCutRangeBegin)+(1/earlyCutRangeRatio)*max(0,y-earlyCutRangeBegin);       %apply early cut range
    
    gain=y-oldY;    %calcolate the gain of each element
    for j=1:length(gain)    %apply the gain
        if isnan(gain(j))
            audioOut(j,i)=0;
        else
            audioOut(j,i)=audio(j,i)*(10.^(gain(j)./20));
        end
    end
end
end

