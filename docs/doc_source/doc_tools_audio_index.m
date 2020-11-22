%% Functions for augmentation from audio signals
% In this section we present the functions included *./tools/audio/*.

%% Functions descriptions
% Our data augmentation functions are named starting with "apply". They
% are implemented to get as an input the location of the raw audio files
% along with their associated frequencies. The output is a cell containing the
% augmented signals.
%
% The function generateSpectrogram.m is the one that takes an audio signal
% and returns the associated spectrogram. 4 different kinds of spectrograms
% are available.

%% Additional toolboxes
% In addition to our function, this folder includes also
%%
% * the The Large Time-Frequency Analysis Toolbox (LTFAT), available at
% <http://ltfat.github.io/>,
% * the Audio Degradation Toolbox (ADT) available at
% <https://code.soundsoftware.ac.uk/projects/audio-degradation-toolbox>
% * the Matlab implementation of Phase Vocoder (D. P. W. Ellis, A Phase
% Vocoder in Matlab, 2002), available at
% <https://www.ee.columbia.edu/~dpwe/resources/matlab/pvoc/>
% * Malcolm Slaney (1998) "Auditory Toolbox Version 2", 
% Technical Report #1998-010, Interval Research Corporation, 1998. 
% http://cobweb.ecn.purdue.edu/~malcolm/interval/1998-010/
