image = 'test2.jpg'; % Name of image to translate
colorImage = imread(image);
I = rgb2gray(colorImage);
numLines = 2;
numSizes = 2;
%%
bboxes = getBoundingBoxes(I, colorImage);
%%
imChars = getCharacterImages(I,bboxes);
%%
imChars = normalizeCharacterImages(imChars);
%%
[nonLatexText, nonLatexIndices] = detectCharactersAndDigits(imChars);
%%
% symbols = csvread('training-sets/alpha-beta-lambda/strokes.mtx');
% labels = csvread('training-sets/alpha-beta-lambda/strokes.ind');
% model = trainClassifier(symbols(train,:), labels(train,:));
% [LatexText, indices] = classifyLatexChars(model, imChars);

%% 
% model = trainNNClassifier();
%%
% Xtest = createTestSet(imChars);
% yhat = model.predict(model, Xtest);
%%
lines = clusterByYCoord(bboxes, numLines);
%%
sizes = clusterByArea(bboxes, numSizes);
%%
symbols = csvread('training-sets/alpha_beta_lambda-interp-thicken-small/alpha_beta_lambda.mtx');
labels = csvread('training-sets/alpha_beta_lambda-interp-thicken-small/alpha_beta_lambda.ind');
[N, ~] = size(symbols);

% Convert to x,y coords and linearize.
xy_symbols = cell(N);
for i = 1:N 
    x = symbols(i,:);
    t = find(reshape(x, 16,16) == 0);
    cols = mod(t, 16);
    rows = floor(t/16) + 1;
    idx = [rows cols];
    xy_symbols{i} = idx;
end

test_symbols = cell(length(imChars));
for i = 1:length(imChars) 
    x = imChars(i,:);
    t = find(reshape(x, 16,16) == 0);
    cols = mod(t, 16);
    rows = floor(t/16) + 1;
    idx = [rows cols];
    test_symbols{i} = idx;
end

disp('DTW KNN');
yhat = KNNDTWPrediction(xy_symbols, labels, test_symbols)
% mean(predictions == labels)





%%
labels = {};
LatexText = getLatexLabels(yhat);
labels(1:size(imChars, 1)) = LatexText;
% for i=1:size(nonLatexIndices, 2)
%    labels{nonLatexIndices(i)} = nonLatexText(i); 
% end
% labels{nonLatexIndices} = nonLatexText;
% for i=1:length(imChars)
%    labels{i}
%    imshow(squeeze(imChars(i, :, :)));
%    pause
% end
tex = produceOutput(labels, bboxes, lines, sizes)


