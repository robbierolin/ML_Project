function [ labels, indeces ] = detectCharactersAndDigits( imChars )
%DETECTCHARACTERSANDDIGITS Summary of this function goes here
%   Detailed explanation goes here
numChars = size(imChars,1);
imSize = size(imChars,2);
ConfidenceThreshold = 0.7;
labels = [];
indeces = [];
for i=1:numChars
    im = reshape(imChars(i,:,:), [imSize imSize]);
    
%     results = ocr(im);
    results = ocr(im, 'CharacterSet', '0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ().=,', 'TextLayout','Word');
    results.Text
    
    % Sort the character confidences
    [sortedConf, sortedIndex] = sort(results.CharacterConfidences, 'descend');

    % Keep indices associated with non-NaN confidences values
    indexesNaNsRemoved = sortedIndex( ~isnan(sortedConf) );
    confNaNsRemoved = sortedConf(~isnan(sortedConf)) 
    
    numAnswers = size(confNaNsRemoved, 1);
    if numAnswers ~= 0 
        if confNaNsRemoved(1) > ConfidenceThreshold
            labels = [labels results.Text];
            indeces = [indeces i];
            confNaNsRemoved(1)
        end
    end
    
    %imshow(im)
    %pause;
end
end

