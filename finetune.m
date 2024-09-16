% Model output file
% Parameters
%  - model: the model to finetune
%  - X_train: the features to train on
%  - Y_train: the labels to train on
%  - X_test: the features to test on
%  - Y_test: the labels to test on

function modelOut = finetune(model, X_train, Y_train, X_test, Y_test)
    % ICs per step
    batchSize = 64;

    disp('Starting finetuning...');
    [netTrained, info]= trainnet(X_train.X, Y_train.Y, model, @(y, targets) customLoss(y, targets), trainingOptions("adam", "Verbose", 1, "VerboseFrequency", ...
        1, 'Shuffle', 'every-epoch', 'MiniBatchSize', batchSize, 'MaxEpochs', 15, 'Plots', 'training-progress', 'ValidationData', {X_test.X, Y_test.Y}, 'ValidationFrequency', 11));
    
    disp('Finetuning completed.');
    save('finetuned_net.mat', 'netTrained');
    save('finetuning_graph.mat', 'info');
    modelOut = netTrained;
end