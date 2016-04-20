function [preds] = KNNDTWPrediction(training, labels, test)
    % Find DTW distance from each test example to each training example
    % Find the largest 3
    % return mode of those labels.
    preds = zeros(length(test), 1);
    for i=1:length(test)
        t = test{i};
        N = length(training);
        D = zeros(N,1);
        for j=1:N 
            D(j) = dtw(training{j}, t);
        end
    
        [~, ind] = sort(D, 'ascend');
        best_match_idx = ind(1:3);
        preds(i) = mode(labels(best_match_idx)); 
end

