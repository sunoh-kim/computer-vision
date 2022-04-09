close all
format compact

%% Main Script

%% Parameters
model = 'model_train';
positive_training_path= '../../datasets/INRIAPerson/train_64x128_H96/pos';
negative_training_path= '../../datasets/INRIAPerson/Train/neg';

test_imgs_path = '../../datasets/INRIAPerson/Test/pos';
label_path = 'human_gt.txt';

%% MODE ( MODE = 1 : Training, MODE = 2 : Testing )
if MODE == 1 % Training
    clc
    training(model,positive_training_path,negative_training_path);
    
elseif MODE == 2 % Test
    % load('param.mat');
    load('model.mat');
    [bboxes, confidences, img_ids] = detector(W,b,test_imgs_path);
    evaluating(bboxes, confidences, img_ids,label_path);

else
    fprintf(" MODE = 1 :\t Training \n MODE = 2 :\t Testing\n");
end


