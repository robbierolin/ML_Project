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
