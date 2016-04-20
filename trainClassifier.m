function [model] = trainClassifier (X,y) 
    model = fitcknn(X, y, 'Distance', 'euclidean');
end