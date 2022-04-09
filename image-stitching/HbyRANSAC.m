function [H, symmetric_transfer_error] = HbyRANSAC(correspondence1, correspondence2, match)

sample_num = 4;
N = inf;
t = 1.25;
p = 0.99;
sample_count = 0;

total_point = size(match, 2);
P1 = [correspondence1; ones(1, total_point)];
P2 = [correspondence2; ones(1, total_point)];

% RANSAC
while N > sample_count
    
    % DLT
    perm = randsample(total_point, sample_num); % randomly sampled correspondences
    H = DLT(correspondence1(:, perm)', correspondence2(:, perm)'); % compute H using DLT method
    
    diff_1 = H^(-1) * P2;    
    diff_1 = diff_1 ./ repmat(diff_1(3,:), 3, 1);
    diff_2 = H * P1;    
    diff_2 = diff_2 ./ repmat(diff_2(3,:), 3, 1);
    symmetric_transfer_error = sum( (P1 - diff_1).*(P1 - diff_1) ) + sum( (P2 - diff_2) .* (P2 - diff_2));
    
    Inlier_check = symmetric_transfer_error < t;
    Inlier_num = sum(Inlier_check);
    
    if(Inlier_num == 0) 
        continue;
    end
        
    outlier_ratio = 1-(Inlier_num/total_point);
    inliners = find(Inlier_check);
    
    N = log(1-p)/log(1 - (1-outlier_ratio)^sample_num);
    sample_count = sample_count + 1;
end    

H = DLT(correspondence1(:, inliners)', correspondence2(:, inliners)');
symmetric_transfer_error = sum(symmetric_transfer_error);

end

