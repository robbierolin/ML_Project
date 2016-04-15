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
model = trainClassifier();
[LatexText, indicies] = classifyLatexChars(model, imChars);
%%
lines = clusterByYCoord(bboxes, numLines);
%%
sizes = clusterByArea(bboxes, numSizes);

