In this folder there are six functions for testing Audiogmenter on the task
of sound classification on the ESC-50 dataset. The ESC-50 dataset (which
can be dowloaded here: https://github.com/karolpiczak/ESC-50) is a 
challenging dataset of about five seconds long audio samples equally
divided in 50 classes. The dataset is also divided in 5 folds for
cross-fold validation.

The function createOriginalData.m creates the spectrograms of the original
data and store them in a folder named originalSpectrograms.

The functions createAudioSamples.m and createSpectrogramSamples.m create 
the spectrograms of the augmented audio data. The first one augments the
raw audio data and then turns it into spectrograms, while the second
applies the data augmentation after the transformation of the raw audio
data into spectrograms.

The function demoBaseline.m trains AlexNet on the original samples. The
testing protocol is a 5-fold cross validation.

The functions demoAudioAugmentation.m and demoSpectrogramAugmentation.m
train AlexNet on the augmented data using the two approaches described
above.