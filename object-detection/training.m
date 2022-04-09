function training(model,positive_training_path,negative_training_path)
%% Training SVM after extracting HOGs

%% Loading Data
fprintf('1. Loading Training Data!\n')
pos = -1;
neg = -1;
[pos_imgs,neg_imgs] = get_files(pos, neg,{positive_training_path,negative_training_path});

%% Extracting HOGs
fprintf('2. HOG Extraction Starts!\n')
[HOGs, labels] = compute_HOGs(pos_imgs,neg_imgs);

%% Cross Validation
fprintf('3. Cross Validation Starts!\n')
range = [10^(-2),10^(-1), 0,5, 1, 2, 4, 8]; 
svm_param = cross_validation(range,HOGs,labels);
drawnow;

%% Training SVM
fprintf('4. Training Starts!\n')
[W, b] = vl_svmtrain(HOGs', labels, 10^(-7));
save(model,'W','b');


end