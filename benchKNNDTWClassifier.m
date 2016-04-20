disp('alpha-beta-lambda interp')
symbols = csvread('training-sets/alpha-beta-lambda-interp/sample_int.mtx');
labels = csvread('training-sets/alpha-beta-lambda-interp/sample_int.ind');
[N, ~] = size(symbols);
K = 3;

% Cross Validation here
disp('Normal KNN');
ind = crossvalind('Kfold', N, K);
predictions = zeros(N,1);
for i = 1:K
    test = (ind == i); train = ~test;
    mdl = trainClassifier(symbols(train,:), labels(train,:));
    predictions(test) = predict(mdl, symbols(test,:));
end
mean(predictions == labels)

% Convert to x,y coords and linearize.
xy_symbols = cell(N);
for i = 1:N 
    x = symbols(i,:);
    t = find(reshape(x, 100,100) == 0);
    cols = mod(t, 100);
    rows = floor(t/100) + 1;
    idx = [rows cols];
    xy_symbols{i} = idx;
end

for i = 1:N
    dtw(xy_symbols{2}, xy_symbols{i})
end

disp('DTW KNN');
% Cross Validation here
ind = crossvalind('Kfold', N, K);
predictions = zeros(N,1);
for i = 1:K
    test = (ind == i); train = ~test;
    predictions(test) = KNNDTWPrediction(xy_symbols(train), labels(train), xy_symbols(test)); 
end

mean(predictions == labels)