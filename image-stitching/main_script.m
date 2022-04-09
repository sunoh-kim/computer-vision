%% Clearing

clear all
close all

%% Loading Pictures

Imgs_rgb = cell(5, 1);
imgs_gray = cell(5, 1);
R = cell(5, 1);
G = cell(5, 1);
B = cell(5, 1);

for idx = 1 : 5
    img = imread(char("../../images/img"+idx+".bmp"));
    img = imresize(img, [256, 256]);
    
    Imgs_rgb{idx} = img;
    imgs_gray{idx} = rgb2gray(img);
    R{idx} = img(:, :, 1);
    G{idx} = img(:, :, 2);
    B{idx} = img(:, :, 3);
end
    

%% Extracting Features

descriptors = cell(5, 1);
interestPoints = cell(5, 1);

% Scale Invariant Feature Transform(SIFT)
% for idx = 1 : 5
%     %[InterestPoints{idx}, Descriptors{idx}] = vl_sift(single(imgs_gray{idx}));
%     %[InterestPoints{idx}, Descriptors{idx}] = vl_sift(single(imgs_gray{idx}),'PeakThresh', 5);
%     %[InterestPoints{idx}, Descriptors{idx}] = vl_sift(single(imgs_gray{idx}),'PeakThresh', 10);
%     %[InterestPoints{idx}, Descriptors{idx}] = vl_sift(single(imgs_gray{idx}),'PeakThresh', 0, 'edgethresh', 2);
%     %[InterestPoints{idx}, Descriptors{idx}] = vl_sift(single(imgs_gray{idx}),'PeakThresh', 0, 'edgethresh', 10);
%     [InterestPoints{idx}, Descriptors{idx}] = vl_sift(single(imgs_gray{idx}),'PeakThresh', 0, 'edgethresh', 50);
% end 

for idx = 1 : 5
    edge_thresh = 3;
    points_num = 0;
    while(points_num<250 || points_num>300)
        [interestPoints{idx}, descriptors{idx}] = vl_sift(single(imgs_gray{idx}),'PeakThresh', 0, 'edgethresh', edge_thresh);
        if edge_thresh >100
            break
        elseif points_num<250
            edge_thresh = edge_thresh*2;
        else
            edge_thresh = edge_thresh-1;
        end
        points_num = size(interestPoints{idx}, 2);
    end
    
end

% Visualizing SIFT features

disp_num = 300;

figure() ;
title('Interest Points from SIFT');
for idx = 1 : 5
    max_num = size(interestPoints{idx}, 2);
    subplot(2, 3, idx);
    perm = randperm(max_num);
    sel = perm(1 : min(disp_num, max_num));
    
    imshow(Imgs_rgb{idx});
    hold on
    h1=vl_plotframe(interestPoints{idx}(:, sel));
    h2=vl_plotframe(interestPoints{idx}(:, sel));
    set(h1,'color','k','linewidth',3);
    set(h2,'color','g','linewidth',2);
    title(sprintf('Image%d', idx));
    hold off
end

figure() ;
title('Interest Points from SIFT (Overlaid by the descriptors)');
for idx = 1 : 5
    max_num = size(interestPoints{idx}, 2);
    subplot(2, 3, idx);
    perm = randperm(max_num);
    sel = perm(1 : min(disp_num, max_num));
    
    imshow(Imgs_rgb{idx});
    hold on
    h3=vl_plotsiftdescriptor(descriptors{idx}(:,sel),interestPoints{idx}(:,sel)) ;
    h1=vl_plotframe(interestPoints{idx}(:, sel));
    h2=vl_plotframe(interestPoints{idx}(:, sel));
    set(h1,'color','k','linewidth',3);
    set(h2,'color','g','linewidth',2);
    set(h3,'color','b') ;

    title(sprintf('Image%d', idx));
    hold off
end

%% Feature Matching and Homography Estimation using RANSAC
matches = cell(4, 1);
H = cell(4, 1);
H_re_estimated = cell(4, 1);

for idx = 1 : 4
    % Feature Matching
    %[matches{idx}, ~] = vl_ubcmatch(descriptors{idx}, descriptors{idx+1},0);
    %[matches{idx}, ~] = vl_ubcmatch(descriptors{idx}, descriptors{idx+1}, 2);
    %[matches{idx}, ~] = vl_ubcmatch(descriptors{idx}, descriptors{idx+1},10);
    [matches{idx}, ~] = vl_ubcmatch(descriptors{idx}, descriptors{idx+1},2);
    
    adjacent_imgs = [Imgs_rgb{idx}, Imgs_rgb{idx+1}];
    correspondence1 = interestPoints{idx}(1:2, matches{idx}(1,:));
    correspondence2 = interestPoints{idx+1}(1:2, matches{idx}(2,:));
    
    % Visualizing Feature Matching
    figure();
    imshow(adjacent_imgs);
    hold on
    plot(correspondence1(1, :), correspondence1(2, :), 'or');
    plot(correspondence2(1, :) + 256, correspondence2(2, :), 'ob');
    line([correspondence1(1, :) ; correspondence2(1, :) + 256], [correspondence1(2, :) ; correspondence2(2, :)], 'color', 'g');
    hold off
    title(sprintf('Matched points between Image %d and %d', idx, idx+1));
    
    % Homography Estimation using RANSAC
    [H{idx}, symmetric_transfer_error] = HbyRANSAC(correspondence1, correspondence2, matches{idx});  
    fprintf(sprintf('\n Homography between Image %d and %d \n', idx, idx+1));
    H{idx}
    fprintf(sprintf('\n Total Symmetric Transfer Error for Homography between Image %d and %d \n', idx, idx+1));
    loss = sum(symmetric_transfer_error)
    
%     % (Option)Optimal Estimation
%     syms h0 h1 h2 h3 h4 h5 h6 h7 h8
%     total_point = size(matches{idx}, 2);
%     H_sys = [h0, h3, h6; h1, h4, h7; h2, h5, h8];
%     P1 = [correspondence1; ones(1, total_point)];
%     P2 = [correspondence2; ones(1, total_point)];
%     tol=0.5e-8; % 0.5e-8
%     n=30; % 30
%     lambda=1000;
%     
% %     diff = H_sys * P1;
% %     diff = diff ./ repmat(diff(3,:), 3, 1);
% %     symmetric_transfer_error = sum( sum( (P2 - diff).^2));
%     
%     diff_1 = H_sys^(-1) * P2;    
%     diff_1 = diff_1 ./ repmat(diff_1(3,:), 3, 1);
%     diff_2 = H_sys * P1;    
%     diff_2 = diff_2 ./ repmat(diff_2(3,:), 3, 1);
%     symmetric_transfer_error = sum( (P1 - diff_1).*(P1 - diff_1) ) + sum( (P2 - diff_2) .* (P2 - diff_2));
% 
%     H_re_estimated{idx} = LevenbergMarquardt(sum(symmetric_transfer_error),H_sys,H{idx},tol,n,lambda);
%     
%     H_re_estimated{idx} = [H_re_estimated{idx}(1), H_re_estimated{idx}(4), H_re_estimated{idx}(7); 
%         H_re_estimated{idx}(2), H_re_estimated{idx}(5), H_re_estimated{idx}(8); 
%         H_re_estimated{idx}(3), H_re_estimated{idx}(6), H_re_estimated{idx}(9)];
%     diff_1 = H_re_estimated{idx}^(-1) * P2;    
%     diff_1 = diff_1 ./ repmat(diff_1(3,:), 3, 1);
%     diff_2 = H_re_estimated{idx} * P1;    
%     diff_2 = diff_2 ./ repmat(diff_2(3,:), 3, 1);
%     symmetric_transfer_error = sum( (P1 - diff_1).*(P1 - diff_1) ) + sum( (P2 - diff_2) .* (P2 - diff_2));
%     
%     fprintf(sprintf('\n (Optimal) Homography between Image %d and %d \n', idx, idx+1));
%     H_re_estimated{idx}
%     fprintf(sprintf('\n (Optimal) Total Symmetric Transfer Error for Homography between Image %d and %d \n', idx, idx+1));
%     loss = sum(symmetric_transfer_error)
    
    
    % Warping Image 1 to Image 2
    Tform = maketform('projective',  H{idx}');
    [img_transformed, x, y]= imtransform(imgs_gray{idx}, Tform);
    x_data=[min(1,x(1)), max(size(imgs_gray{idx+1}, 2),x(2))];
    y_data=[min(1,y(1)), max(size(imgs_gray{idx+1},1),y(2))];
    img_1 = imtransform(imgs_gray{idx}, Tform,'XData',x_data,'YData',y_data);
    img_2 = imtransform(imgs_gray{idx+1}, maketform('affine',eye(3)),'XData',x_data,'YData',y_data);
    img_grey_warped=max(img_1, img_2);
    
    figure();
    imshow(uint8(img_grey_warped));
    title(sprintf('Warped Grey Image between Image %d and %d', idx, idx + 1));
    
    [img_transformed, x, y]= imtransform(R{idx}, Tform);
    x_data=[min(1,x(1)), max(size(R{idx+1}, 2),x(2))];
    y_data=[min(1,y(1)), max(size(R{idx+1},1),y(2))];
    img_1 = imtransform(R{idx}, Tform,'XData',x_data,'YData',y_data);
    img_2 = imtransform(R{idx+1}, maketform('affine',eye(3)),'XData',x_data,'YData',y_data);
    img_R_warped=max(img_1, img_2);
    
    [img_transformed, x, y]= imtransform(G{idx}, Tform);
    x_data=[min(1,x(1)), max(size(G{idx+1}, 2),x(2))];
    y_data=[min(1,y(1)), max(size(G{idx+1},1),y(2))];
    img_1 = imtransform(G{idx}, Tform,'XData',x_data,'YData',y_data);
    img_2 = imtransform(G{idx+1}, maketform('affine',eye(3)),'XData',x_data,'YData',y_data);
    img_G_warped=max(img_1, img_2);
    
    [img_transformed, x, y]= imtransform(B{idx}, Tform);
    x_data=[min(1,x(1)), max(size(B{idx+1}, 2),x(2))];
    y_data=[min(1,y(1)), max(size(B{idx+1},1),y(2))];
    img_1 = imtransform(B{idx}, Tform,'XData',x_data,'YData',y_data);
    img_2 = imtransform(B{idx+1}, maketform('affine',eye(3)),'XData',x_data,'YData',y_data);
    img_B_warped=max(img_1, img_2);
    
    img_color_warped = zeros(size(img_R_warped, 1), size(img_R_warped, 2), 3);
    img_color_warped(:, :, 1) = img_R_warped;
    img_color_warped(:, :, 2) = img_G_warped;
    img_color_warped(:, :, 3) = img_B_warped;
    
    figure();
    imshow(uint8(img_color_warped));
    title(sprintf('Warped Color Image between Image %d and %d', idx, idx + 1));
   
end

%% Mosaicing the Images
R_ = mosaicing(R, H);
G_ = mosaicing(G, H);
B_ = mosaicing(B, H);

% Final paranomic Image
img_panoramic = zeros(size(R_, 1), size(R_, 2), 3);
img_panoramic(:, :, 1) = R_;
img_panoramic(:, :, 2) = G_;
img_panoramic(:, :, 3) = B_;
figure();
imshow(uint8(img_panoramic));
title('Panoramic Image');

% % (Optimal)Final paranomic Image
% R_ = mosaicing(R, H_re_estimated);
% G_ = mosaicing(G, H_re_estimated);
% B_ = mosaicing(B, H_re_estimated);
% img_panoramic = zeros(size(R_, 1), size(R_, 2), 3);
% img_panoramic(:, :, 1) = R_;
% img_panoramic(:, :, 2) = G_;
% img_panoramic(:, :, 3) = B_;
% figure();
% imshow(uint8(img_panoramic));
% title('Panoramic Image(Optimal Estimation)');





