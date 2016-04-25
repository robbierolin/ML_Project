function [ Xhat ] = createTestSet( imChars )

[numImages, dimension, ~] = size(imChars);
Xhat = zeros(numImages, dimension*dimension);

for i=1:numImages
   image = imChars(i, :, :);
   Xhat(i, :) = image(:);
end


end

