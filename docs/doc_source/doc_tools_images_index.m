%% Functions for augmentation from images
% In this section we present the functions included *./tools/images*

%% Functions descriptions
% Our data augmentation functions are named starting with "apply". They
% are implemented to get as an input the original spectrograms
% along with their associated labels. The output is a cell containing the
% augmented signals, along with their labels.
%
% The other functions are used inside the main augmentation algorithms, but
% they can also be used as stand alone functions.

%% Additional toolboxes
% In addition to our function, this folder includes also
%%
% * Fitzgerald Archibald (2019). Warping Using Thin Plate Splines
% (https://www.mathworks.com/matlabcentral/fileexchange/24315-warping-using-thin-plate-splines),
% MATLAB Central File Exchange. Retrieved December 5, 2019. 