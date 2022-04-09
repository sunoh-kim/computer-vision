clear
close all

%% Preprocessing

% Loading images and light source directions
[ambimage, imarray2, lightdirs2] = LoadFaceImages;
[img_num,~, ~] = size(imarray2);

% Changing Dimension for easy reshaping (Using 11x480x640 requires squeezing dimensions)
imarray = zeros(480,640,11);
lightdirs = zeros(3,11);

% given LoadFaceImages have problem in lightdirs variable (uploaded file from ETL)
lightdirs2 = lightdirs2(1:11,:) ;

for i=1:img_num
    imarray(:,:,i) = squeeze(imarray2(i,:,:));
    lightdirs(1,:) = lightdirs2(:,2)';
    lightdirs(2,:) = lightdirs2(:,3)';
    lightdirs(3,:) = lightdirs2(:,1)';
end

% Subtracting
for i=1:img_num
    imarray(:,:,i) = imarray(:,:,i) - ambimage;
    imarray(imarray<0) = 0;
end

% Cropping
xmin = 250;
ymin = 50;
width = 210;
height = 320;

img_croped = zeros(height, width,img_num);

for i=1:img_num    
    img_croped(:,:,i) = imcrop(imarray(:,:,i),[xmin,ymin,width-1,height-1]);
end

%% Photometric stereo

%% First part: Calibrated photometric stereo

disp("Calibrated photometric stereo")

% % Using only 3 images
% 3 10 8, 1 2 3, 3 7 11
disp("Using only 3 images")
imgs3 = zeros(height,width,3);
imgs3(:,:,1) = img_croped(:,:,3);
imgs3(:,:,2) = img_croped(:,:,10);
imgs3(:,:,3) = img_croped(:,:,8);
s1 = [lightdirs(:,3)';lightdirs(:,10)';lightdirs(:,8)'];
Calibrated_photometric_stereo(imgs3, s1);
% If using differentlight sources.
%Calibrated_photometric_stereo(imgs3, lightdirs); 

% Using only 5 images
% 3 4 10 1 8
disp("Using only 5 images")
imgs5 = zeros(height,width,5);
imgs5(:,:,1) = img_croped(:,:,3);
imgs5(:,:,2) = img_croped(:,:,4);
imgs5(:,:,3) = img_croped(:,:,10);
imgs5(:,:,4) = img_croped(:,:,1);
imgs5(:,:,5) = img_croped(:,:,8);
s2 = [lightdirs(:,3)';lightdirs(:,4)';lightdirs(:,10)'; lightdirs(:,1)'; lightdirs(:,8)'];
Calibrated_photometric_stereo(imgs5, s2);

% Using only 8 images
% 3 4 10 1 8 2 6 11
disp("Using only 8 images")
imgs8 = zeros(height,width,8);
imgs8(:,:,1) = img_croped(:,:,3);
imgs8(:,:,2) = img_croped(:,:,4);
imgs8(:,:,3) = img_croped(:,:,10);
imgs8(:,:,4) = img_croped(:,:,1);
imgs8(:,:,5) = img_croped(:,:,8);
imgs8(:,:,5) = img_croped(:,:,2);
imgs8(:,:,5) = img_croped(:,:,6);
imgs8(:,:,5) = img_croped(:,:,11);
s3 = [lightdirs(:,3)';lightdirs(:,4)';lightdirs(:,10)'; ... 
    lightdirs(:,1)'; lightdirs(:,8)'; lightdirs(:,2)'; lightdirs(:,6)'; lightdirs(:,11)'];
Calibrated_photometric_stereo(imgs8, s3);

% Using all images
disp("Using only all(11) images")
Calibrated_photometric_stereo(img_croped, lightdirs');

disp("  ")
%% Second part: Uncalibrated photometric stereo

disp("Uncalibrated photometric stereo")

% Using all(11) images.

Uncalibrated_photometric_stereo(img_croped);

