function [H] = DLT(correspondence1, correspondence2)

num = size(correspondence1, 1);
A = zeros(2*num, 9);
    
for idx = 1 : num
    p1 = correspondence1(idx, :);
    p2 = correspondence2(idx, :);
    A(2*idx, :) = [[p1 1] 0 0 0 -p2(1)*([p1 1])];
    A(2*idx-1, :) = [0 0 0 [p1 1] -p2(2)*([p1 1])];
end

[~, ~, V] = svd(A);
X = V(:,end);
X = X / norm(X);
H = reshape(X, 3, 3)';

end

