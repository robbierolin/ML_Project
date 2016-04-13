function [model] = clusterKmeans(X,K)
% K++ means clustering.
[N,D] = size(X);


means(1, :) = X(ceil(rand*N), :);
for k=2:K
    % Compute shortest distance from each point to a mean
    distances = zeros(N,1);
    for i=1:N
       distances(i) = 100000;
       
       for j=1:k-1
           % Compute distance to each mean
           meanCur = means(j, :);
           distanceToMean = dist(X(i, :), meanCur(:))^2;
           
           % Store min
           if distanceToMean < distances(i) 
               distances(i) = distanceToMean;
           end
       end
    end
    % Convert distances to probabilities
    sumDistance = sum(distances);
    for i=1:N
        distances(i) = distances(i) / sumDistance;
    end
    % Sample points with given probabilities
    means(k,:) = X(sampleDiscrete(distances), :);
end

X2 = X.^2*ones(D,K);
while 1
    means_old = means;
    
    % Compute Euclidean distance between each data point and each mean
    distances = sqrt(X2 + ones(N,D)*(means').^2 - 2*X*means');
    
    % Assign each data point to closest mean
    [~,clusters] = min(distances,[],2);
    
    % Compute mean of each cluster
    means = zeros(K,D);
    for k = 1:K
        means(k,:) = mean(X(clusters==k,:),1);
    end
    
    % If we only have two features, make a colored scatterplot
    if D == 2
        clf;hold on;
        colors = getColors;
        for k = 1:K
            h = plot(X(clusters==k,1),X(clusters==k,2),'.');
            set(h,'Color',colors{k});
        end
        pause(.25);
    end
    
    fprintf('Running K-means, difference = %f\n',max(max(abs(means-means_old))));
    
    if max(max(abs(means-means_old))) < 1e-5
        break;
    end
end

model.means = means;
model.clusters = clusters;


