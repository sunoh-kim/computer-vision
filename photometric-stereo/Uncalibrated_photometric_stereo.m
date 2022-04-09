function [ ] = Uncalibrated_photometric_stereo(img)

[height,width,Img_num] = size(img);
img_length = height*width;

% Initializing variables.
surface_normal = zeros(height, width, 3);
p_val = zeros(height,width);
q_val = zeros(height,width);
E_tot = [];

% Fiding albedos, surface normals, p and q values and light source directions using SVD
for ii = 1 : Img_num
    E = reshape(double(img(:, :, ii)), [img_length, 1]);
    E_tot = [E_tot, E];
end

[U, sig, V] = svds(E_tot, 3);
albedo_ast = U*sig;
s_ast = V';

albedo(:, :, 1) = reshape(albedo_ast(:,1), [height, width]);
albedo(:, :, 2) = reshape(albedo_ast(:,2), [height, width]);
albedo(:, :, 3) = reshape(albedo_ast(:,3), [height, width]);
alb = zeros(3, 1);

for x = 1:width
    for y = 1:height
        for ii = 1:3
            alb(ii) = albedo(y, x, ii);
        end
        p_val(y, x) = alb(2)/alb(1);
        q_val(y, x) = alb(3)/alb(1);
        b_norm = norm(alb);
        
        surface_normal(y, x, 1) = albedo(y, x, 1)/b_norm;
        surface_normal(y, x, 2) = albedo(y, x, 2)/b_norm;
        surface_normal(y, x, 3) = albedo(y, x, 3)/b_norm;
    end
end

% Reconstructing
img_r = img(:,:,end);

rx = zeros(height,width); 
ry = zeros(height,width);
jj = 1:height-1; 
ii = 1:width-1;

ry(jj+1,ii) = q_val(jj+1,ii) - q_val(jj,ii); 
rx(jj,ii+1) = p_val(jj,ii+1) - p_val(jj,ii);
f1 = rx + ry; 
img_r(2:end-1,2:end-1) = 0;
jj2 = 2:height-1; ii2 = 2:width-1; fb = zeros(height,width);
fb(jj2,ii2) = -4*img_r(jj2,ii2) + img_r(jj2,ii2+1) + ...
img_r(jj2,ii2-1) + img_r(jj2-1,ii2) + img_r(jj2+1,ii2);
f2 = f1 - reshape(fb,height,width);
f3 = f2(2:end-1,2:end-1);
tt = trans(f3); 
f3sin = trans(tt')';
[x1,y1] = meshgrid(1:width-2,1:height-2); 
denom = (2*cos(pi*x1/(width-1))-2) + (2*cos(pi*y1/(height-1)) - 2) ;
f4 = f3sin./denom;


if (min(size(f4))==1)
    n=length(f4);
else
    n=size(f4,1);
end
nn=n+1;
tt=2/nn*trans(f4);
tt=tt';
if min(size(tt))==1
    n=length(tt);
else
    n=size(tt,1);
end
nn=n+1;
img_t=2/nn*trans(tt);

img_rc = img_r;
img_rc(2:end-1,2:end-1) = 0;
img_rc(2:end-1,2:end-1) = img_t'; 


%% Plotting
xx = 1:width;
yy = 1:height;
[X,Y] = meshgrid(xx,yy);

% Albedo
figure();
subplot(1,3,1);
colormap('hsv')
imagesc(albedo(:,:,1), [-1 1]); colorbar; axis equal; axis tight; axis off;
title('Albedo X');
subplot(1,3,2);
imagesc(albedo(:,:,2), [-1 1]); colorbar; axis equal; axis tight; axis off;
title('Albedo Y');
subplot(1,3,3);
imagesc(albedo(:,:,3), [-1 1]); colorbar; axis equal; axis tight; axis off; 
title('Albedo Z');

% Surface normal
figure();
subplot(1,4,1);
qui=quiver3(X,Y,img_rc, surface_normal(:,:,1), surface_normal(:,:,2), surface_normal(:,:,3));
qui.Color = 'green';
title('Surface Normal (Uncalibrated Photometric Stereo)');
view(-35,45);

colormap('hsv')
subplot(1,4,2);
imagesc(surface_normal(:,:,1), [-1 1]); colorbar; axis equal; axis tight; axis off;
title('Surface Normal X');
subplot(1,4,3);
imagesc(surface_normal(:,:,2), [-1 1]); colorbar; axis equal; axis tight; axis off;
title('Surface Normal Y');
subplot(1,4,4);
imagesc(surface_normal(:,:,3), [-1 1]); colorbar; axis equal; axis tight; axis off; 
title('Surface Normal Z');

% Height map
figure();
subplot(1,2,1);
surf(X,Y,img_rc);
colormap(spring);
title('3D Height Map (Uncalibrated Photometric Stereo)');
view(-35,45);
subplot(1,2,2);
imagesc(img_rc);colormap(spring);
title('2D Height Map (Uncalibrated Photometric Stereo)');

% P-Q maps
figure();
subplot(1, 2, 1);
mesh(p_val);
title('P Maps (Uncalibrated Photometric Stereo)')
subplot(1, 2, 2);
mesh(q_val);
title('Q Maps (Uncalibrated Photometric Stereo)');

%Visualizing Reconstructed Images
s = s_ast(:, 11);
[xx,yy,zz] = surfnorm(img_rc);
k = xx*s(1,1)+yy*s(2,1)+zz*s(3,1);

figure();
surface(1:width,1:height,img_rc,albedo(:,:,3).*k); shading interp; rotate3d on; colormap(pink);
title('Face Image (Uncalibrated Photometric Stereo)');
view(-35,45);






