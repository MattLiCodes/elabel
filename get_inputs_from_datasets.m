% Load in the pre-trained ICLabel model
net = dagnn.DagNN.loadobj(load('netICL.mat'));

% Remove the last two layers
net.removeLayer('discriminator_softmax');
net.removeLayer('discriminator_conv');
net.conserveMemory = false;

% Get datasets from folder
labels = get_labels;
datasets = cell(length(keys(labels)), 1);
dataset_names = keys(labels);
for dataset = 1:length(keys(labels))
    file = string(dataset_names(dataset));
    EEG = pop_loadset(file{1}, '/Users/bartonsbrain/Documents/sinaptica/data/step5/train');
    datasets{dataset} = EEG;
end

X = [];
Y = [];

% Get labels for epoch
dataset_names = keys(labels);
for dataset = 1:length(keys(labels))
    % Get labels
    gt = labels(dataset_names(dataset));
    gt = gt{1};

    % Load in dataset
    file = string(dataset_names(dataset));
    EEG = datasets{dataset};

    % Convert dataset into batch
    features = ICL_feature_extractor(EEG, true);
    images = features{1};
    psds = features{2};
    autocorrs = features{3};
    images = cat(4, images, -images, images(:, end:-1:1, :, :), -images(:, end:-1:1, :, :));
    psds = repmat(psds, [1 1 1 4]);
    input = {
        'in_image', single(images), ...
        'in_psdmed', single(psds)
    };
    autocorrs = repmat(autocorrs, [1 1 1 4]);
    input = [input {'in_autocorr', single(autocorrs)}];

    % Forward pass
    net.eval(input);
    predictions = net.getVar(net.getOutputs()).value;
    preds_reshaped = reshape(predictions, 4, 4, 712, 4, []);
    preds_reshaped = mean(preds_reshaped, 4);
    preds_reshaped = reshape(preds_reshaped, 4,4,712,size(preds_reshaped,5));
    
    % Add data to output array
    X = [cat(4, X, preds_reshaped)];
    Y = [Y; gt(:,1)];
end

save('X_train.mat', 'X');
save('Y_train.mat', 'Y');