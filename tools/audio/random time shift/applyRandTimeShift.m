%%applyRandTimeShift.m
function [audioOut, fs] = applyRandTimeShift(nummp3, fs)  
%  APPLYRANDTIMESHIFT randomly breaks in two parts each audio signal in nummp3,
%   swaps the two parts and mounts a new randomly shifted audio signal.
%   Input
%   nummp3: raw audio signal
%   fs: frequencies of the audio signals. Not required if nummp3 contains
%       the audio paths.
%
%   Output
%   dataNew: shifted audio signal
%   fs: new frequencies

% Initialize data
if isa(nummp3,'struct')
    singleInput = false;
    nSamples = length(nummp3);
    flag = true;
elseif isa(nummp3,'cell')
    flag = false;
    nSamples = length(nummp3);
    singleInput = false;
    data = nummp3;
else      %the data is a single signal
    flag = false;
    singleInput = true;
    data = {nummp3};
    fs = {fs};
    nSamples = 1;
end

parfor j=1:nSamples
    if flag
        [data,fs{j}]=audioread(nummp3(j).name);
    elseif singleInput
        data = nummp3;
    else
        data = nummp3{j};
    end
    data=data(:,1);
    div = floor(rand(1)*(length(data)-1)+1); 
    audioOut{j}=vertcat(data(div+1:end),data(1:div));
end

if singleInput
    fs = fs{1};
    audioOut = audioOut{1};
end

end