function [ sizes ] = clusterByArea( bbs, numSizes )

numBoxes = size(bbs, 1);
areas = zeros(numBoxes, 1);

for i=1:numBoxes
   bb = bbs(i, :); 
   areas(i) = bb(3)*bb(4); 
end

model = clusterKppMeans(areas, numSizes);
sizes = model.clusters;

% Order clusters by size
averageAreas = zeros(1, numSizes);
for i=1:numSizes
   averageAreas(i) = mean(areas(find(sizes == i))); 
end

[averageAreas, indices] = sort(averageAreas);

for i=1:numBoxes
    sizes(i) = find(indices == sizes(i));
end
sizes = sizes - 1;
end

