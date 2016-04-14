image = 'test1.jpg'; % Name of image to translate
colorImage = imread(image);
I = rgb2gray(colorImage);
numLines = 2;
numSizes = 3;
%%
bboxes = getBoundingBoxes(I, colorImage);
%%
imChars = getCharacterImages(I,bboxes);
%%
imChars = normalizeCharacterImages(imChars);
%%
[nonLatexText, nonLatexIndices] = detectCharactersAndDigits(imChars);
%%
[LatexText, indicies] = detectLatex(imChars);
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
