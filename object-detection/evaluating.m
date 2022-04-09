function evaluating(all_bboxes, all_confidences, img_ids,label_path)
%% Evaluating
fprintf('6. Testing Starts!\n')

threshold = 1;

draw_graph =1;

%% Filtering
range = 1:size(img_ids,1);
all_id = cell(size(img_ids,1),1);
pos_indxs = range(all_confidences(:,1) >= threshold);

all_confidences = all_confidences(pos_indxs,:);
all_bboxes = all_bboxes(pos_indxs,:);
img_ids =  img_ids(pos_indxs,:);

all_pos_indxs_2 =[];
for id=1:size(img_ids,1)
    all_id{id} = char(img_ids{id});
end

for id=1:size(img_ids,1)
    curr_id = all_id{id};
    
    cmp_res=strcmp(all_id,curr_id);
    
    if sum(cmp_res) > 20
        threshold_2 = 1.3; 
        pos_indxs_2 = cmp_res'.*range;
        range2 = nonzeros(pos_indxs_2);
        all_pos_indxs_2 = [all_pos_indxs_2;range2(all_confidences(range2) >= threshold_2)];
        
    elseif sum(cmp_res) > 15
        threshold_2 = 1.2;
        pos_indxs_2 = cmp_res'.*range;
        range2 = nonzeros(pos_indxs_2);
        all_pos_indxs_2 = [all_pos_indxs_2;range2(all_confidences(range2) >= threshold_2)];
        
    elseif sum(cmp_res) > 10
        threshold_2 = 1.1;
        pos_indxs_2 = cmp_res'.*range;
        range2 = nonzeros(pos_indxs_2);
        all_pos_indxs_2 = [all_pos_indxs_2;range2(all_confidences(range2) >= threshold_2)];
        
    else
        pos_indxs_2 = cmp_res'.*range;
        range2 = nonzeros(pos_indxs_2);
        all_pos_indxs_2 = [all_pos_indxs_2;range2];
    end
end

all_pos_indxs_2 = unique(all_pos_indxs_2);
all_confidences = all_confidences(all_pos_indxs_2,:);
all_bboxes = all_bboxes(all_pos_indxs_2,:);
img_ids =  img_ids(all_pos_indxs_2,:);

%% Visualizing
[gt_ids, gt_bboxes, gt_isclaimed, tp, fp, duplicate_detections] = evaluate_detections(all_bboxes, all_confidences, img_ids, label_path, draw_graph);
%visualize_detections_by_image(all_bboxes, all_confidences, img_ids, tp, fp, test_imgs_path, label_path);
%visualize_detections_by_confidence(all_bboxes, all_confidences, img_ids,test_imgs_path, label_path, false);
%visualize_detections_by_image_no_gt(all_bboxes, all_confidences, img_ids,test_imgs_path);


fprintf('7. Testing Ends!\n')

end
