function labels = run_EL(model_path, images, psds, autocorrs)
    %% load network
    netStruct = dagnn.DagNN.loadobj(load('netICL.mat'));
    netStruct.removeLayer('discriminator_softmax');
    netStruct.removeLayer('discriminator_conv');
    try
        net = dagnn.DagNN.loadobj(netStruct);
    catch
        net = dagnn_bc.DagNN.loadobj(netStruct);    
    end
    clear netStruct;
    %% format network inputs
    images = cat(4, images, -images, images(:, end:-1:1, :, :), -images(:, end:-1:1, :, :));
    psds = repmat(psds, [1 1 1 4]);
    input = {
        'in_image', single(images), ...
        'in_psdmed', single(psds)
    };
    flag_autocorr = true;
    if flag_autocorr
        autocorrs = repmat(autocorrs, [1 1 1 4]);
        input = [input {'in_autocorr', single(autocorrs)}];
    end
    
    % check path (sometimes mex file not first which create a problem)
    path2vl_nnconv = which('-all', 'vl_nnconv');
    if ~ischar(path2vl_nnconv)
        if ~isempty(path2vl_nnconv) && isempty(findstr('mex', path2vl_nnconv{1})) && length(path2vl_nnconv) > 1
            addpath(fileparts(path2vl_nnconv{2}));
        end
    end
    
    %% inference
    try
        % run with mex-files
        net.eval(input);
    catch
        % failed, try to recompile mex-files
        disp 'Failed to run ICLabel. Trying to compile MEX-files.'
        curr_path = pwd;
        cd(fileparts(which('vl_compilenn')));
        try
            vl_compilenn
            cd(curr_path)
            disp(['MEX-files successfully compiled. Attempting to run ICLabel again. ' ...
                'Please consider emailing Luca Pion-Tonachini at lpionton@ucsd.edu to ' ...
                'share the compiled MEX-files. They will likely help other EEGLAB users ' ...
                'with similar computers as yourself.'])
            net.eval(input);
        catch
            % could not recompile. running natively
            % ~80x slower than using mex-files
            cd(curr_path)
            disp(['MEX-file compilation failed. Further instructions on compiling ' ...
                  'the MEX-files can be found at http://www.vlfeat.org/matconvnet/install/. ' ...
                  'Further, you may contact Luca Pion-Tonachini at lpionton@ucsd.edu for help. ' ...
                  'If you solve this issue without help, please consider emailing Luca as the ' ...
                  'compiled files will likely be useful to other EEGLAB users with similar ' ...
                  'computers as yourself.'])
            warning('ICLabel: defaulting to uncompiled matlab code (about 80x slower)')
            net = uncompiled_network_evaluation(net, input);
        end
    end
    
    predictions = net.getVar(net.getOutputs()).value;
    preds_reshaped = reshape(predictions, 4, 4, 712, 4, []);
    preds_reshaped = mean(preds_reshaped, 4);
    preds_reshaped = reshape(preds_reshaped, 4,4,712,size(preds_reshaped,5));
    X = preds_reshaped;

    % Run finetuned final layer
    load(model_path, 'netTrained');
    labels = predict(netTrained, X);