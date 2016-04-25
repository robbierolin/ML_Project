function [ imCharsNorm ] = normalizeCharacterImages( imChars )

numImages = size(imChars, 2);
% Size of training data images is 16 x 16 [not really]
imSize = 16;

imCharsNorm = zeros(numImages, imSize, imSize);

for i=1:numImages
    % Get image of character.
    im = imChars{i};
    % Resize.
    im = imresize(im, [imSize imSize]);
    % Convert to binary image, higher threshold results in more black.
    level = graythresh(im);
    im = im2bw(im, level);
    imCharsNorm(i, :, :) = im;
end

end

