The audio augmentations take as inputs the original audio files or their names.
The files are read inside the functions.

The inputs are the original files along with their frequencies, or the names
or the path of those files. In the first case, signals and frequencies must
be included in two different cell objects.
Otherwise, the functions also work for single signals.
The outputs are the augmented audio signals.
The functions are implemented to augment multiple audio files in parallel.

The details of every augmentations are in the comments of the function.

The main functions are the ones that start with apply.