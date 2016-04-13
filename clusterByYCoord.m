function [ lines ] = clusterByYCoord( bbs, numLines )

% Get all ycoordinates
ys = bbs(:,2);
% Cluster
model = clusterKppMeans(ys, numLines);
lines = model.clusters;

end

