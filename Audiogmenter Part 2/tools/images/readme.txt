The spectrogram augmentations take as inputs the original spectrograms along with their labels.
The original spectrograms must be a cell array.

The outputs are the augmented spectrograms along with their (new) labels.
The functions are implemented to augment multiple spectrograms in parallel.

The details of every augmentations are in the comments of the functions.

The main functions are the ones that start with apply.