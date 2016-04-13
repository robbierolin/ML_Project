function [ sizes ] = clusterByArea( bbs, numSizes )

numBoxes = size(bbs, 1);
areas = zeros(numBoxes, 1);

for i=1:numBoxes
   bb = bbs(i, :); 
   areas(i) = bb(3)*bb(4); 
end

model = clusterKppMeans(areas, numSizes);
sizes = model.clusters;

end

