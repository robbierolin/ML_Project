function [latexText, indicies] = classifyLatexChars (imChars)
    symbols = csvread('strokes.mtx');
    labels = csvread('strokes.ind');
    mdl = fitcknn(symbols, labels, 'Distance', 'euclidean');
    latexText = predict(mdl, imChars);
    % Right now just give a prediction for everything.
    indicies = 1:length(imChars);
end