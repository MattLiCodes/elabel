function labels = get_labels_from_sheet(filename)
    %   example_filename = 'iclabels_manual_elias_train.xlsx';
        sheetname = 'Foglio1';
        
        % Read the data from the Excel file
        data = readtable(filename, 'Sheet', sheetname);
        
        % Initialize an empty cell array to store the results
        results = cell(height(data), 1);
        filenames = strings(height(data), 1);
        
        % Loop through each row of the data
        for i = 1:height(data)
            % Read the length value and the list string
            n = data{i, 'Count'};
            num_str = data{i, 'ICS'}{1};
            
            % Generate the (n, 2) matrix for the current row
            indicator_matrix = generate_matrix_from_array(num_str, n);
            
            % Store the indicator matrix in the results cell array
            results{i} = indicator_matrix;
            file = table2array(data(i, 'Filenames'));
            filenames(i) = string(file{1});
        end
        labels = dictionary(filenames, results);
    end
    
    function result = generate_matrix_from_array(num_str, n)
        % Split the string by commas and convert to array of numbers
        indices = str2num(num_str); %#ok<ST2NM>
        
        % Initialize the result matrix with zeros and ones
        result = zeros(n, 2);
        result(:, 2) = 1; % By default, set the second column to 1
        
        % Set the elements at the specified indices
        for i = 1:length(indices)
            index = indices(i);
            if index >= 1 && index <= n
                result(index, :) = [1, 0];
            end
        end
        % Elements that are not set to [1, 0] remain [0, 1] as initialized
    end