function [bboxes] = getBoundingBoxes(image)

colorImage = imread(image);
I = rgb2gray(colorImage);

% Detect MSER regions.
[mserRegions] = detectMSERFeatures(I, ...
    'RegionAreaRange',[200 8000],'ThresholdDelta',4);

figure
imshow(I)
hold on
plot(mserRegions, 'showPixelList', true,'showEllipses',false)
title('MSER regions')
hold off

%% Remove Non-Text Regions Based on Basic Geometric Properties

% First, convert the x,y pixel location data within mserRegions into linear
% indices as required by regionprops.
sz = size(I);
pixelIdxList = cellfun(@(xy)sub2ind(sz, xy(:,2), xy(:,1)), ...
    mserRegions.PixelList, 'UniformOutput', false);

% Next, pack the data into a connected component struct.
mserConnComp.Connectivity = 8;
mserConnComp.ImageSize = sz;
mserConnComp.NumObjects = mserRegions.Count;
mserConnComp.PixelIdxList = pixelIdxList;

% Use regionprops to measure MSER properties
mserStats = regionprops(mserConnComp, 'BoundingBox', 'Eccentricity', ...
    'Solidity', 'Extent', 'Euler', 'Image');
% 
% % Compute the aspect ratio using bounding box data.
% bbox = vertcat(mserStats.BoundingBox);
% w = bbox(:,3);
% h = bbox(:,4);
% aspectRatio = w./h;
% 
% % Threshold the data to determine which regions to remove. These thresholds
% % may need to be tuned for other images.
% filterIdx = aspectRatio' > 3;
% filterIdx = filterIdx | [mserStats.Eccentricity] > .995 ;
% filterIdx = filterIdx | [mserStats.Solidity] < .3;
% filterIdx = filterIdx | [mserStats.Extent] < 0.2 | [mserStats.Extent] > 0.9;
% filterIdx = filterIdx | [mserStats.EulerNumber] < -4;
% 
% % Remove regions
% mserStats(filterIdx) = [];
% mserRegions(filterIdx) = [];
% 
% % Show remaining regions
% figure
% imshow(I)
% hold on
% plot(mserRegions, 'showPixelList', true,'showEllipses',false)
% title('After Removing Non-Text Regions Based On Geometric Properties')
% hold off
% 
%% Remove Non-Text Regions Based oN Stroke Width Variation
% Get a binary image of the a region, and pad it to avoid boundary effects
% during the stroke width computation.
regionImage = mserStats(6).Image;
regionImage = padarray(regionImage, [1 1]);

% Compute the stroke width image.
distanceImage = bwdist(~regionImage);
skeletonImage = bwmorph(regionImage, 'thin', inf);

strokeWidthImage = distanceImage;
strokeWidthImage(~skeletonImage) = 0;

% Show the region image alongside the stroke width image.
figure
subplot(1,2,1)
imagesc(regionImage)
title('Region Image')

subplot(1,2,2)
imagesc(strokeWidthImage)
title('Stroke Width Image')

% Compute the stroke width variation metric
strokeWidthValues = distanceImage(skeletonImage);
strokeWidthMetric = std(strokeWidthValues)/mean(strokeWidthValues);

% Threshold the stroke width variation metric
strokeWidthThreshold = 0.4;
strokeWidthFilterIdx = strokeWidthMetric > strokeWidthThreshold;

% Process the remaining regions
for j = 1:numel(mserStats)

    regionImage = mserStats(j).Image;
    regionImage = padarray(regionImage, [1 1], 0);

    distanceImage = bwdist(~regionImage);
    skeletonImage = bwmorph(regionImage, 'thin', inf);

    strokeWidthValues = distanceImage(skeletonImage);

    strokeWidthMetric = std(strokeWidthValues)/mean(strokeWidthValues);

    strokeWidthFilterIdx(j) = strokeWidthMetric > strokeWidthThreshold;

end

% Remove regions based on the stroke width variation
mserRegions(strokeWidthFilterIdx) = [];
mserStats(strokeWidthFilterIdx) = [];

% Show remaining regions
figure
imshow(I)
hold on
plot(mserRegions, 'showPixelList', true,'showEllipses',false)
title('After Removing Non-Text Regions Based On Stroke Width Variation')
hold off

%% Merge Text Regions For Final Detection Result
% Get bounding boxes for all the regions
bboxes = vertcat(mserStats.BoundingBox)

% Convert from the [x y width height] bounding box format to the [xmin ymin
% xmax ymax] format for convenience.
xmin = bboxes(:,1);
ymin = bboxes(:,2);
xmax = xmin + bboxes(:,3) - 1;
ymax = ymin + bboxes(:,4) - 1;

% Expand the bounding boxes by a small amount.
expansionAmount = 0.02;
xmin = (1-expansionAmount) * xmin;
ymin = (1-expansionAmount) * ymin;
xmax = (1+expansionAmount) * xmax;
ymax = (1+expansionAmount) * ymax;

% Clip the bounding boxes to be within the image bounds
xmin = max(xmin, 1);
ymin = max(ymin, 1);
xmax = min(xmax, size(I,2));
ymax = min(ymax, size(I,1));

% Show the expanded bounding boxes
expandedBBoxes = [xmin ymin xmax-xmin+1 ymax-ymin+1]
IExpandedBBoxes = insertShape(colorImage,'Rectangle',expandedBBoxes,'LineWidth',3);

figure
imshow(IExpandedBBoxes)
title('Expanded Bounding Boxes Text')

%% Filter out subImages
numBoxes = size(bboxes, 1);
subImages = [];
for i=1:numBoxes
   for j=1:numBoxes
      if i == j 
          continue;
      end
      xmin1 = xmin(i);
      xmax1 = xmax(i);
      ymin1 = ymin(i);
      ymax1 = ymax(i);
      
      xmin2 = xmin(j);
      xmax2 = xmax(j);
      ymin2 = ymin(j);
      ymax2 = ymax(j);
      
      if xmin1 > xmin2 && xmax1 < xmax2
          if ymin1 > ymin2 && ymax1 < ymax2
              subImages = [subImages(1:end) i];
          end
      end 
   end
end

bboxes(subImages,:) = [];
