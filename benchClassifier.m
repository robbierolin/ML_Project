symbols = csvread('strokes.mtx');
labels = csvread('strokes.ind');
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
