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