%% Train AlexNet on the original dataset
% This script shows how to train AlexNet using the spectrograms generated 
% from the original audio signals. This provides a baseline for the data
% augmentation
%
% We test the classification accuracy on the ESC-50 dataset.

%% Create the dataset
createOriginalData
clear

%% Iterate over folds
for fold = 1:5
    %% Select which fold is the test set
    train = [];
    for f = 1:5
        if f == fold
            test = f;
        else
            train = [train,f];
        end
    end
    %% Create a datastore containing the training data
    % folders with training data
    trainingData = {fullfile('originalSpectrograms',int2str(train(1))),...
        fullfile('originalSpectrograms',int2str(train(2))),....
        fullfile('originalSpectrograms',int2str(train(3))),....
        fullfile('originalSpectrograms',int2str(train(4)))};
    
    % create a datastore
    trainDs = imageDatastore(trainingData,...
        'IncludeSubfolders',true,'FileExtensions','.jpg','LabelSource','foldernames');
    augTrainDs = augmentedImageDatastore([227,227],trainDs,'ColorPreprocessing','gray2rgb');
    
    %% Load the network
    net = alexnet;
    numClasses = 50;
    %% Replace the last layers for transfer learning
    layersTransfer = net.Layers(1:end-3);
    layers = [
        layersTransfer
        fullyConnectedLayer(numClasses,'WeightLearnRateFactor',10,'BiasLearnRateFactor',10)
        softmaxLayer
        classificationLayer];
    
    %% training options
    miniBatchSize = 64;
    learningRate = 1e-4;
    % stochastic gradient descent with momentum
    metodoOptim='sgdm';
    executionEnvironment = 'gpu';
    options = trainingOptions(metodoOptim,...
        'MiniBatchSize',miniBatchSize,...
        'MaxEpochs',60,...
        'ExecutionEnvironment', executionEnvironment,...
        'InitialLearnRate',learningRate,...
        'Verbose',false,...
        'Plots','training-progress');
    
    %% Train the Network
    netTransfer = trainNetwork(augTrainDs,layers,options);
    
    %% Test the network
    testData = {fullfile('originalSpectrograms',int2str(fold))};
    
    testDs = imageDatastore(testData,...
        'IncludeSubfolders',true,'FileExtensions','.jpg','LabelSource','foldernames');
    augTestDs = augmentedImageDatastore([227,227],testDs,'ColorPreprocessing','gray2rgb');
    
    [outclass{fold},scores{fold}] = classify(netTransfer,augTestDs);

    %calculate the accuracy of the network on the fold
    YPred = outclass{fold};
    YTest = testDs.Labels;
    %% Print the accuracies
    accuracy(fold) = sum(YPred == YTest)/numel(YTest)
end
%% Print the final average accuracy
avgAccuracy = sum(accuracy)/5