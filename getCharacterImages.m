function [ imChars ] = getCharacterImages( I, bboxes )
%GETCHARACTERIMAGES Summary of this function goes here
%   Detailed explanation goes here
%% Get character images from bounding boxes
numBoxes = size(bboxes,1);
% imChars = cell(numBoxes);
imChars = {};
for i=1:numBoxes
   bbox = bboxes(i,:);
   char = imcrop(I, bbox);
%    imshow(char);
%    pause;
   imChars = {imChars{1:end} char(:,:)};
end

end

