function [ ] = Calibrated_photometric_stereo(img, s)

[height,width,img_num] = size(img);

% If using differentlight sources.
% lightdirs=s;
% s = [lightdirs(:,3)';lightdirs(:,10)';lightdirs(:,8)'];
% lightdirs=lightdirs';

% Initializing variables.
albedo = zeros(height,width);
surface_normal = zeros(height,width,3);
p_val = zeros(height,width);
q_val = zeros(height,width);

% Fiding albedos, surface normals, p and q values. 
for x = 1:width
    for y = 1:height
        img_v = squeeze(img(y,x,:));
        imag_mat = diag(img_v);
        
        % s is nonsingular. 
        % We can easily determine both albedo and normal.
        b = (pinv(imag_mat*s))*(imag_mat*img_v);
        rho=norm(b);
        albedo(y,x) = rho;
        if(rho==0)
            disp("albedo is zero.")
            
        else
            surface_normal(y,x,:) = b/rho;
            if(surface_normal(y,x,3)==0)
                disp("p-q values are zero.")
                
            else
                p_val(y,x) = surface_normal(y,x,1)/surface_normal(y,x,3);
                q_val(y,x) = surface_normal(y,x,2)/surface_normal(y,x,3);
                
            end
        end
    end
end

p_val(p_val>10)=10;
p_val(p_val<-10)=-10;
q_val(q_val>10)=10;
q_val(q_val<-10)=-10;

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
surface(X,Y,albedo);
colormap(parula);
title('Albedo (Calibrated Photometric Stereo)');
view(-35,45);

% Surface normal
figure();
subplot(1,4,1);
qui=quiver3(X,Y,img_rc, surface_normal(:,:,1), surface_normal(:,:,2), surface_normal(:,:,3));
qui.Color = 'green';
title('Surface Normal (Calibrated Photometric Stereo)');
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
title('3D Height Map (Calibrated Photometric Stereo)');
view(-35,45);
subplot(1,2,2);
imagesc(img_rc);colormap(spring);
title('2D Height Map (Calibrated Photometric Stereo)');

% P-Q maps
figure();
subplot(1, 2, 1);
mesh(p_val);
title('P Maps (Calibrated Photometric Stereo)')
subplot(1, 2, 2);
mesh(q_val);
title('Q Maps (Calibrated Photometric Stereo)');

% Visualizing Reconstructed Images
[xx,yy,zz] = surfnorm(img_rc);
k = xx*s(1,1)+yy*s(1,2)+zz*s(1,3);

% If using differentlight sources.
%k = xx*lightdirs(5,1)+yy*lightdirs(5,2)+zz*lightdirs(5,3);


figure();
surface(1:width,1:height,img_rc,albedo.*k); shading interp; rotate3d on; colormap(pink);
title('Face Image (Calibrated Photometric Stereo)');
view(-35,45);


