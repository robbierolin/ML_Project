function [latexText, indicies] = classifyLatexChars (imChars)
    symbols = csvread('strokes.mtx');
    labels = csvread('strokes.ind');
    mdl = fitcknn(symbols, labels, 'Distance', 'euclidean');
    N = size(imChars,1);
    predicted = zeros(N, 1);
    for i=1:N
        img = imChars(i,:,:);
        predicted(i) = predict(mdl, img(:)');
    end
    % Right now just give a prediction for everything.
    latexText = predicted;
    indicies = 1:length(imChars);
end