function [ lines ] = clusterByYCoord( bbs, numLines )

% Get all ycoordinates
ys = bbs(:,2);
% Cluster
model = clusterKppMeans(ys, numLines);
lines = model.clusters;

% Order clusters by height
averages = zeros(1, numLines);
for i = 1:numLines
   averages(i) = mean(bbs(find(lines == i), 2));
end

[averages, indices] = sort(averages);

numBoxes = size(lines, 1);
for i=1:numBoxes
   lines(i) = find(indices == lines(i)); 
end
end

