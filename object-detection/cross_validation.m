function svm_params = cross_validation(cost_range, HOGs, labels)

% Linear SVM
cross_val = zeros(1,numel(cost_range));
best_cross_val = 0;
best_cost = 0;

fold = 3;

for i=1:numel(cost_range)
    c = cost_range(i);
    svm_params = ...
        ['-q -v ', num2str(fold),' -t ',num2str(0) ,' -c ', num2str(c)];
    cv = svmtrain(labels, HOGs, svm_params);
    cross_val(1,i) = cv;
    fprintf('\t Cost=%d \n\n',c);
    
    % Updating
    if (cv >= best_cross_val)
        best_cross_val = cv;
        best_cost = c;
    end
end

fprintf('\t Best cross value: %d \t best cost= %d\n\n', best_cross_val, best_cost);
svm_params = ['-q -t ',num2str(0) ,' -c ', num2str(best_cost),' -b 1'];

end
