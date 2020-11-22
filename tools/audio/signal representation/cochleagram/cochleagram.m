function C = cochleagram(sample, fs, numChannels, freqRange)
% Calculates the cochleagram of sample
%
% The parameters are:
%  - sample:        the audio signal
%  - fs:            the frequency of the audio signal
%  - numChannels:   number of channels used for the gamatone filter
%                   (optional)
%  - freqRange:     frequency range (optional)

% set default parameters
if nargin < 3   
    numChannels = 100;           
end
if nargin < 4
    freqRange = [80 8000];      
end

% create filter bank and filter the audio sample
gammaFiltBank = gammatoneFilterBank(freqRange, numChannels, fs);    %range freq. - numCanali - freq. campionamento
y_gm = step(gammaFiltBank, sample)';
    
% window length and overlap
winLength = floor(fs/10);                    
overlap = winLength/2;

shiftWindow = winLength - overlap;
numFrame = floor(length(sample)/shiftWindow);

% C represents the energy of the singal
% initialize C
C = zeros(numChannels, numFrame);

for m = 1:numFrame     
    
    endPoint = m*shiftWindow;
    startPoint = max(1, endPoint-winLength);
    
    for i = 1:numChannels
            % the energy is the sum of the square ofthe filtered signal
            C(i,m) = y_gm(i,startPoint:endPoint)*y_gm(i,startPoint:endPoint)';
    end
end

C = C./max(C(:));            % rescale in [0,1]

