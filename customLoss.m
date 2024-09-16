function loss = customLoss(predictions, targets)
    % Extract the predicted class by finding the index of the maximum value in the softmax output
    % [~, predictedClasses] = max(predictions, [], 1);
    real_targets = (1 - targets);
    predictions_1 = predictions(1, :);
    artifacts = predictions(2:end, :);
    maxArtifact = max(artifacts, [], 1);
    predictions_0 = sum(artifacts, 1);

    pred = predictions_1 > maxArtifact;
    difference = predictions_1 - maxArtifact;
    disp(difference);
    acc = sum(pred == (1 - targets));
    disp(acc / size(targets, 2));
    combinedProb = predictions_1 + maxArtifact;
    diff = predictions_1 ./ combinedProb;
    
    % Average the loss over the batch
    loss = -mean(real_targets .* log(diff + eps) + ...
                 (1 - real_targets) .* (log((1-diff) + eps)));

    % gt = targets(1, :);
    % acc = ((predictions_1 > maxArtifact));
    % acc_2 = ((predictions_1 < maxArtifact) && (gt == 0));

    % disp(size(acc) + size(acc_2) / size(predictions_1));
end