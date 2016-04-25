function [ model ] = trainNNClassifier(  )
%TRAINNNMODEL Summary of this function goes here
%   Detailed explanation goes here
%% Neural Network Classifier
symbols = csvread('training-sets/common-interp-thicken-small/common.mtx');
labels = csvread('training-sets/common-interp-thicken-small/common.ind');
[N, d] = size(symbols);
nLabels = max(labels);
X = symbols;
Y = labels;
% Standardize columns
% X = standardizeCols(X);

% Add bias
X = [ones(N,1) X];
d = d + 1;
% Split into training, validation and test sets
perm = randperm(N);
X(:,:) = X(perm, :);
Y(:) = Y(perm);

% Xtrain = X(1:floor(N/3),:);
% Ytrain = Y(1:floor(N/3));
% Xvalid = X(floor(N/3) + 1 : 2 * floor(N/3), :);
% Yvalid = Y(floor(N/3) + 1 : 2 * floor(N/3));
% Xtest = X(2 * floor(N/3) + 1 : end, :);
% Ytest = Y(2 * floor(N/3) + 1 : end);

n = size(X,1);
% n = size(Xtrain, 1);
% t = size(Xvalid, 1);
% t2 = size(Xtest, 1);

% Choose network stucture
nHidden = [20 20 20 20 20 20 20 20 20 20];

% Count number of parameters and initialize weights
nParams = d*nHidden(1);
for h = 2:length(nHidden)
    nParams = nParams+nHidden(h-1)*nHidden(h);
end
nParams = nParams+nHidden(end)*nLabels;
w = randn(nParams,1);

% Train
maxIter = 100000;
stepSize = 1e-3;
funObj = @(w,i)MLPclassificationLoss(w,X(i,:),Y(i,:),nHidden,nLabels);

beta = 0.9;
wprev = w;
for iter = 1:maxIter
    if mod(iter-1,round(maxIter/20)) == 0
%         yhat = MLPclassificationPredict(w,Xvalid,nHidden,nLabels);
        fprintf('Training iteration = %d\n',iter-1);
    end
    
    i = ceil(rand*n);
    [f,g] = funObj(w,i);
    wPrevNew = w;
    w = w - stepSize*g + beta*(w - wprev);
    wprev = wPrevNew;
end

% Evaluate Test Error
% yhat = MLPclassificationPredict(w,Xtest,nHidden,nLabels);
% fprintf('Test error with final model = %f\n',sum(yhat~=Ytest)/t2);

model.w = w;
model.nHidden = nHidden;
model.nLabels = nLabels;
model.predict = @predict;

end

function yhat = predict(model, Xtest)
    w = model.w;
    nHidden = model.nHidden;
    nLabels = model.nLabels;
    yhat = MLPclassificationPredict(w, Xtest, nHidden, nLabels);
end

