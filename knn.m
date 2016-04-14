function [model] = knn(X,y,K)
% [model] = knn(X,y,k)
%
% Implementation of k-nearest neighbour classifer

model.X = X;
model.y = y;
model.K = K;
model.C = max(y);
model.predict = @predict;
end

function [yhat] = predict(model,Xtest)

[N,D] = size(model.X);
[T,D] = size(Xtest);
D = model.X.^2*ones(D,T) + ones(N,D)*(Xtest').^2 - 2*model.X*Xtest';
yhat = ones(T,1);

for i=1:T
   distances = D(:, i);
   [dist, indeces] = sort(distances);
   lowestKindeces = indeces(1:model.K);
   labelsOfLowestK = model.y(lowestKindeces);
   yhat(i) = mode(labelsOfLowestK); 
end
end