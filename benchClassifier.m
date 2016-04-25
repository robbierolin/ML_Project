disp('alpha-beta-lambda baseline');
symbols = csvread('training-sets/alpha-beta-lambda/strokes.mtx');
labels = csvread('training-sets/alpha-beta-lambda/strokes.ind');
[N, ~] = size(symbols);
K = 3;

% Cross Validation here
ind = crossvalind('Kfold', N, K);
predictions = zeros(N,1);
for i = 1:K
    test = (ind == i); train = ~test;
    mdl = trainClassifier(symbols(train,:), labels(train,:));
    predictions(test) = predict(mdl, symbols(test,:));
end

mean(predictions == labels)

disp('alpha-beta-lambda interp')
symbols = csvread('training-sets/alpha-beta-lambda-interp/sample_int.mtx');
labels = csvread('training-sets/alpha-beta-lambda-interp/sample_int.ind');
[N, ~] = size(symbols);

K = 3;

% Cross Validation here
ind = crossvalind('Kfold', N, K);
predictions = zeros(N,1);
for i = 1:K
    test = (ind == i); train = ~test;
    mdl = trainClassifier(symbols(train,:), labels(train,:));
    predictions(test) = predict(mdl, symbols(test,:));
end

mean(predictions == labels)


disp('common baseline');
symbols = csvread('training-sets/common/common.mtx');
labels = csvread('training-sets/common/common.ind');
[N, ~] = size(symbols);

K = 10;

% Cross Validation here
ind = crossvalind('Kfold', N, K);
predictions = zeros(N,1);
for i = 1:K
    test = (ind == i); train = ~test;
    mdl = trainClassifier(symbols(train,:), labels(train,:));
    predictions(test) = predict(mdl, symbols(test,:));
end

mean(predictions == labels)

disp('common interp');
symbols = csvread('training-sets/common-interp/common.mtx');
labels = csvread('training-sets/common-interp/common.ind');
[N, ~] = size(symbols);

K = 10;

% Cross Validation here
ind = crossvalind('Kfold', N, K);
predictions = zeros(N,1);
for i = 1:K
    test = (ind == i); train = ~test;
    mdl = trainClassifier(symbols(train,:), labels(train,:));
    predictions(test) = predict(mdl, symbols(test,:));
end

mean(predictions == labels)

disp('common interp+thicken');
symbols = csvread('training-sets/common-interp-thicken/common.mtx');
labels = csvread('training-sets/common-interp-thicken/common.ind');
[N, ~] = size(symbols);

K = 10;

% Cross Validation here
ind = crossvalind('Kfold', N, K);
predictions = zeros(N,1);
for i = 1:K
    test = (ind == i); train = ~test;
    mdl = trainClassifier(symbols(train,:), labels(train,:));
    predictions(test) = predict(mdl, symbols(test,:));
end

mean(predictions == labels)


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

Xtrain = X(1:floor(N/3),:);
Ytrain = Y(1:floor(N/3));
Xvalid = X(floor(N/3) + 1 : 2 * floor(N/3), :);
Yvalid = Y(floor(N/3) + 1 : 2 * floor(N/3));
Xtest = X(2 * floor(N/3) + 1 : end, :);
Ytest = Y(2 * floor(N/3) + 1 : end);

n = size(Xtrain, 1);
t = size(Xvalid, 1);
t2 = size(Xtest, 1);

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
funObj = @(w,i)MLPclassificationLoss(w,Xtrain(i,:),Ytrain(i,:),nHidden,nLabels);

beta = 0.9;
wprev = w;
for iter = 1:maxIter
    if mod(iter-1,round(maxIter/20)) == 0
        yhat = MLPclassificationPredict(w,Xvalid,nHidden,nLabels);
        fprintf('Training iteration = %d, validation error = %f\n',iter-1,sum(yhat~=Yvalid)/t);
    end
    
    i = ceil(rand*n);
    [f,g] = funObj(w,i);
    wPrevNew = w;
    w = w - stepSize*g + beta*(w - wprev);
    wprev = wPrevNew;
end

% Evaluate Test Error
yhat = MLPclassificationPredict(w,Xtest,nHidden,nLabels);
fprintf('Test error with final model = %f\n',sum(yhat~=Ytest)/t2);