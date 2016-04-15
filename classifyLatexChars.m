function [latexText, indicies] = classifyLatexChars (mdl, imChars)
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