%% Welcome to Audiogmenter
% Audiogmenter is an audio data augmentation library. It can be
% used to boost the performance of machine learning approaches to
% audio-related tasks. It contains 15 methods for raw audio signals augmentation 
% (such as pitch shift and pass filters) and 8 methods for spectrograms
% augmentation (such as frequency masking and noise addition). Every
% algorithm is implemented to work in parallel.
%
% With Audiogmenter you can create your own data augmentation
% strategy and you can also visualize the algorithm on six audio files that
% we provide as an example. Besides, you can use the demos to train a
% network for audio classification.
%
% Audiogmenter is structured in the following folders:
%
% - *./docs/*, including this documentation;
%
% - *./tools/*, including the actual Matlab code, which is described in the
% Function Reference Section;
%
% - *./examples/*, including two examples and two illustrative datasets
% that are described in the Augmentation Examples Section.
%
% - *./demos/*, including the scripts for training AlexNet on an audio
% classification task described in the Demos Section.
%
% A detailed description of Audiogmenter can be found in its relative
% software paper:
% Maguolo, G., Paci, M., Nanni, L., & Bonan, L. (2019). Audiogmenter: a
% MATLAB Toolbox for Audio Data Augmentation. arXiv preprint
% arXiv:1912.05472.