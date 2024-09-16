# ELabel
## Usage
### IC Classification
```
EEG = elabel(model_path, EEG);

% example model_path: 'net_0828.m'
```
### Finetuning
What you need:
- EEG datasets for training
- Manual IC labels in an excel file
- This repo

First, we will create a dataset of features extracted from the EEG datasets and our manual labels.
#### Creating a dataset for training
Firstly, divide your data into data you want to use for training and data you want to use for testing.
Create two folders, one with all your training datasets and one with test sets. Make sure to include the .fdt and .set files. Grab the folder path for training. 

Next, open get_inputs_from_datasets.m and replace the path in Line 15 with your training data folder path. At the bottom of the script, you can change the output file names if you want. 

Next, change the file path in Line 10 to your manual labels for the training datasets. Make sure your labels are formatted like they are in example_labels.xlsx. 

Run the get_inputs_from_datasets.m scripts. Repeat with your test set filepaths.

#### Running finetuning
Now that you have your training and testing datasets, you can run finetuning using the `finetune.m` script. Example usage from original ICLabel weights:
```
% Load in data
load('X_train', 'X_train');
load('Y_train', 'Y_train');
load('X_test', 'X_test');
load('Y_test', 'Y_test');

% Load in model 
load('iclabel_default.mat', 'net_8')
model = net_8

% Run finetuning
newModel = finetune(model, X_train, Y_train, X_test, Y_test)
```
The finetune script will automatically save the model to a .mat file. You can now use that saved off model for IC classifcation.

## Model Version History
net_0828 - Model from first training run, training information found in [`net_0828_info.mat`](/net_0828_info.mat)