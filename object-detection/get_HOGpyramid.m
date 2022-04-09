function [confidence, bbox, res] = get_HOGpyramid(img, W, b, scale)
%% Parameters
param = get_params('param');
th = param.threshold;
window_h = param.height;
window_w = param.width;
cell_size =  param.cell_size;

confidence =zeros(0,1);
bbox = zeros(0,4);
res = 1;

[img_h, img_w,~] = size(img);

%% Checking Image Size
if (img_w < window_w || img_h < window_h)
    res = 0;
    return;
end

%% Sliding Window
window_hog_w = window_w/cell_size;
window_hog_h = window_h/cell_size;

HOG = vl_hog(img, cell_size);

HOG_h = size(HOG, 1);
HOG_w = size(HOG, 2);
x = HOG_w - window_hog_w + 1;
y = HOG_h - window_hog_h + 1;

N = 100;
cur_confidences = zeros(N,1);
cur_bboxes = zeros(N,4);
assign_count = 1;

for j = 1:y
    for k = 1:x
        
        one_hog = HOG(j:j+window_hog_h-1, k:k+window_hog_w-1, :);
        one_confidence = W' * one_hog(:) + b;
        if (one_confidence > 0.3 && one_confidence)
            bbox = [(k-1)*cell_size+1, (j-1)*cell_size+1, (k-1)*cell_size+1 + window_w, (j-1)*cell_size+1 + window_h];
            bbox = bbox ./ scale;
            
            cur_confidences(assign_count,:) = one_confidence;
            cur_bboxes(assign_count,:) = bbox;
            assign_count = assign_count+1;
        end
    end
end

bbox=cur_bboxes(1:assign_count-1,:);
confidence=cur_confidences(1:assign_count-1);

if(size(bbox,1)==0)
    res = 0;
end
end

