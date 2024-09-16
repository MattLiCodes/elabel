EEG = pop_loadset();
EEG = elabel('net_0828.mat', EEG);
disp(EEG.etc.ic_classification.ELabel.classifications)