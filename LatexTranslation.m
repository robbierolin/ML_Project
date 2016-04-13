image = 'test1.jpg'; % Name of image to translate
numLines = 2;
numSizes = 3;
%%
bboxes = getBoundingBoxes(image);
%%
imChars = getCharacterImages(bboxes);
%%
imChars = normalizeCharacterImages(imChars);
%%
[nonLatexText, indeces] = detectCharactersAndDigits(imChars);
%%
lines = clusterByYCoord(bboxes, numLines);
%%
sizes = clusterByArea(bboxes, numSizes);

%%
line1 = imChars(lines == 2, :,:);
c1 = size(line1, 1);
for i=1:c1
   imshow(squeeze(line1(i,:,:)))
   pause
end
