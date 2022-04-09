function [HOGs,labels] = compute_HOGs(pos_imgs,neg_imgs)

% Parameters
param = get_params('param');
block_size = param.block_size;
n_bins = param.n_bins;
width = param.width;
height = param.height;
hog_size =param.hog_size;
cell_size = param.cell_size;
variant = param.variant;

if (exist('HOGs_saved.mat') >= 1)
    load('HOGs_saved.mat');
    return;
end

num_pos_imgs = numel(pos_imgs);
num_neg_imgs = numel(neg_imgs);
total_imgs = num_pos_imgs + num_neg_imgs*100;

pos_hogs = zeros(total_imgs,hog_size);
neg_hogs = zeros(total_imgs,hog_size);

for ii = 1:num_pos_imgs
    
    I = imread(pos_imgs(ii).name);
    I = im2single(I);
    
    tot_HOG = vl_hog(I, cell_size);

    if isempty(tot_HOG)
        continue;
    end
    
    HOG = tot_HOG(5:16, 4:7, :);

    pos_hogs(ii,:) = HOG(:)';
    
end

pos_hogs=pos_hogs(1:num_pos_imgs,:);

window_w = 32/cell_size;
window_h = 96/cell_size;
idx = 1;
for ii = 1:num_neg_imgs
    
    win_hogs = [];
    I = imread(neg_imgs(ii).name);
    I = im2single(I);
    
    HOG = vl_hog(I, cell_size);
    
    if isempty(HOG)
        continue;
    end
    
    hog_h = size(HOG, 1);
    hog_w = size(HOG, 2);
    
    hor_cnt = floor(hog_w/window_w);
    vert_cnt = floor(hog_h/window_h);
    
    for jj = 0:hor_cnt - 2
        for k = 0:vert_cnt - 2
            j1 = jj*window_w + 1;
            j2 = (jj+1)*window_w;
            k1 = k*window_h + 1;
            k2 = (k+1)*window_h;
            
            temp_hog = HOG(k1:k2, j1:j2, :);
            hori_hog = temp_hog(:)';
            win_hogs = [win_hogs; hori_hog];
        end
    end
    neg_hogs(idx:idx+size(win_hogs,1)-1,:) = win_hogs;
    idx = idx+size(win_hogs,1);
end

neg_hogs=neg_hogs(1:idx-1,:);


labels = [ones(size(pos_hogs, 1), 1); -ones(size(neg_hogs, 1), 1)];
HOGs = [double(pos_hogs); double(neg_hogs)];
% save('HOGs_saved.mat', 'HOGs','labels');

end
