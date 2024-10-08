function EEG = elabel(model_path, EEG)
    % check EEG data for errors
    assert(isfield(EEG, 'icawinv') && ~isempty(EEG.icawinv), ...
        'You must have an ICA decomposition to use ICLabel')
    if EEG.srate < 100
        error('ICLabel requires a sampling frequency of at least 100 Hz')
    end
    
    % extract features
    disp 'ELabel: extracting features...'
    flag_autocorr = true;
    features = ICL_feature_extractor(EEG, flag_autocorr);
    
    % run ICL
    disp 'ELabel: calculating labels...'
    labels = run_EL(model_path, features{:});
    
    % save into EEG
    disp 'ELabel: saving results...'
    EEG.etc.ic_classification.ELabel.classes = ...
        {'Brain', 'Other', 'Other', 'Other', ...
         'Other', 'Other', 'Other'};
    EEG.etc.ic_classification.ELabel.classifications = labels;
end