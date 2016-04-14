function [ imCharsNorm ] = normalizeCharacterImages( imChars )

numImages = size(imChars, 2);
% Size of training data images is 256 x 256 [not really]
imSize = 100;

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

