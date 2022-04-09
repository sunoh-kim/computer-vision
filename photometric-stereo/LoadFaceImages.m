function [ambimage, imarray, lightdirs] = LoadFaceImages()

    %% this fucntion load abient and input images with light direction for
    %% each image

    % load ambient images
    filelist = dir('../../images/yalefaceB/*.pgm');
    imname = ['../../images/yalefaceB/' filelist(length(filelist)).name];
    ambimage = im2double(imread(imname));
    
    for i = 1:length(filelist)-1
        imname = ['../../images/yalefaceB/' filelist(i).name];
        imarray(i,:,:) = im2double(imread(imname));
    end
    
    lightdirs = zeros(length(filelist),3);
    
    for i = 1:length(filelist)-1
        imname = ['../../images/yalefaceB/' filelist(i).name];
        % load the direction of light
        cursor = findstr(imname, '.pgm') - 9;        
        azimuth = str2double(imname(cursor+1:cursor+4)) * pi / 180;          
        cursor = cursor + 5;        
        elevation = str2double(imname(cursor+1:cursor+3)) * pi / 180;
        
        lightdirs(i,1) = cos(elevation)*cos(azimuth);
        lightdirs(i,2) = cos(elevation)*sin(azimuth);
        lightdirs(i,3) = sin(elevation);

    end   
    
end