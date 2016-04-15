function [model] = trainClassifier (X,y) 
    symbols = csvread('strokes.mtx');
    labels = csvread('strokes.ind');
    model = fitcknn(X, y, 'Distance', 'euclidean');
end