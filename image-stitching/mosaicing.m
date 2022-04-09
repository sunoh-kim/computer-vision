function [result] = mosaicing(Imgs, H)

Tform1 = maketform('projective', (H{1}*H{2})');
Tform2 = maketform('projective', H{2}'); 
Tform3 = maketform('affine', eye(3)); % Center Image
Tform4 = maketform('projective',  inv(H{3}'));
Tform5 = maketform('projective', inv(H{3}')*inv(H{4}'));

[~, x1, y1] = imtransform(Imgs{1}, Tform1);
[~, x2, y2] = imtransform(Imgs{2}, Tform2);
[~, x4, y4] = imtransform(Imgs{4}, Tform4);
[~, x5, y5] = imtransform(Imgs{5}, Tform5);

% Using Backward Warping (Not forward mapping artifact)
x_data = [min([x1(1), x2(1), 1, x4(1), x5(1)]), max([x1(2), x2(2), size(Imgs{3}, 2), x4(2), x5(2)])];
y_data = [min([y1(1), y2(1), 1, y4(1), y5(1)]), max([y1(2), y2(2), size(Imgs{3}, 1), y4(2), y5(2)])];

imag1 = imtransform(Imgs{1}, Tform1, 'XData', x_data, 'YData', y_data);
imag2 = imtransform(Imgs{2}, Tform2, 'XData', x_data, 'YData', y_data);
imag3 = imtransform(Imgs{3}, Tform3, 'XData', x_data, 'YData', y_data);
imag4 = imtransform(Imgs{4}, Tform4, 'XData', x_data, 'YData', y_data);
imag5 = imtransform(Imgs{5}, Tform5, 'XData', x_data, 'YData', y_data);

result = (max(max(max(max(imag1,imag2), imag3), imag4), imag5));

end

