function [positive_images, negative_images] = get_files(pos_elems, neg_elems, paths)
%% Getting image files
IMG_WILDCARDS = {'*.jpg','*.png','*.ppm'};

positive_images_path = paths{1};
negative_images_path = paths{2};

% Getting images (Positive)
positive_images = [];
for i=1:numel(IMG_WILDCARDS)
    wildcard = strcat(positive_images_path,filesep,IMG_WILDCARDS{i});
    positive_images = [positive_images; rdir(wildcard)];
end
fprintf('\t positive path: %s \n', positive_images_path);

% Getting random sample (Positive)
if pos_elems < 0
    pos_elems = numel(positive_images);
end
idx = randperm(numel(positive_images));
positive_images = positive_images(idx(1:pos_elems));
num_pos_images = size(positive_images,1);
fprintf('\t %d positive images\n', num_pos_images);

% Getting images (Negative)
negative_images = [];
for i=1:numel(IMG_WILDCARDS)
    wildcard = strcat(negative_images_path,filesep,IMG_WILDCARDS{i});
    negative_images = [negative_images; rdir(wildcard)];
end
fprintf('\t negative path: %s \n', negative_images_path);

% Getting random sample (Negative)
if neg_elems < 0
    neg_elems = numel(negative_images);
end
idx = randperm(numel(negative_images));
negative_images = negative_images(idx(1:neg_elems));
num_neg_images = size(negative_images,1);
fprintf('\t %d negative images\n', num_neg_images);
