function [all_bboxes, all_confidences, img_ids]=detector(W,b,test_imgs_path)
%% Sliding-Window based Multi Detector

%% Parameters
param = get_params('param');
th = param.threshold;
scale_size = param.scale;
num_levels= param.levels;
window_height = param.height;
window_width = param.width;

eval_count = 1;

%% Getting Test Data
fprintf('5. Loading Test Data!\n')
IMG_WILDCARDS = {'*.jpg','*.png','*.ppm'};

test_imgs = [];
for ii=1:numel(IMG_WILDCARDS)
    wildcard = strcat(test_imgs_path,filesep,IMG_WILDCARDS{ii});
    test_imgs = [test_imgs; rdir(wildcard)];
end

%% Getting Random Sample
test_elems = numel(test_imgs);

idx = randperm(numel(test_imgs));
test_imgs = test_imgs(idx(1:test_elems));

fprintf('\t test path: %s \n', test_imgs_path);
num_imgs = size(test_imgs,1);
fprintf('\t %d test images\n', num_imgs);

N= num_imgs*1000;
N_small = 1000;
all_bboxes = zeros(N,4);
all_confidences = zeros(N,1);
img_ids = cell(N,1);

%% Testing SVM after extracting HOGs
for ii = 1: num_imgs
    
    bboxes = zeros(N_small,4);
    confidences = zeros(N_small,1);
    ids = cell(N_small,1);
    
    I = imread(test_imgs(ii).name);
    I = im2single(I);
    assign_count = 1;
     
    % HOG pyramid (100 levels, 1% scaling)
    for level = 1:num_levels
        scale = level* scale_size ;
        img_rescaled = imresize(I, scale);
        
        [one_confidence, one_bboxes, res] = get_HOGpyramid(img_rescaled, W, b, scale);
        if (res == 1)
            num_one_detections = size(one_bboxes,1);
            confidences(assign_count:assign_count+num_one_detections-1,:) = one_confidence;
            bboxes(assign_count:assign_count+num_one_detections-1,:) = one_bboxes;
            assign_count = assign_count+num_one_detections;
        end
    end
    
    bboxes=bboxes(1:assign_count-1,:);
    confidences=confidences(1:assign_count-1);    
    ids(1:size(bboxes,1),1) = {string(erase(test_imgs(ii).name,[test_imgs_path,'\']))};
    
    if (size(bboxes, 1) == 0)
        break;
    end
    
    % Non-maximum suppression
    test_len = size(bboxes, 1);
    if (test_len > 0)
        [is_valid] = non_max_supr_bbox(bboxes, confidences, size(I),false);
        
        confidences = confidences(is_valid,:);
        bboxes = bboxes(is_valid,:);
        ids = ids(is_valid,:);
        
        num_detections = size(bboxes,1);
        all_bboxes(eval_count:eval_count+num_detections-1,:) = bboxes;
        all_confidences(eval_count:eval_count+num_detections-1,:) = confidences;
        img_ids(eval_count:eval_count+num_detections-1,:)   = ids;
        eval_count = eval_count+num_detections;
    end
    
end

all_bboxes=all_bboxes(1:eval_count-1,:);
all_confidences=all_confidences(1:eval_count-1);
img_ids=img_ids(1:eval_count-1);

end
