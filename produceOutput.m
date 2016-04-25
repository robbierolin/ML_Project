function [ output ] = produceOutput(labels, bboxes, lines, Sizes )

% State 0: Subscript
% State 1: Normal Size
% State 2: Superscript

output = '';
numLines = max(lines);

for line = 1:numLines
    state = 1;
    lineInd = find(lines == line);
    lineBB = bboxes(lineInd,:);
    [lineBB, indices] = sortrows(lineBB, 1);
    % avg y coordinate for line
    avgY = mean(lineBB(:, 2));
    % If box is small, check if it is above or below the midline
    for i=1:size(indices)
        index = indices(i);
        Size = Sizes(lineInd(index));
        if Size == 0
%             y = lineBB(i, 2);
            y = bboxes(lineInd(index), 2);
            if y > avgY
                Sizes(lineInd(index)) = 2;
            end
        end
    end
    
    indices = reorderForSubscripts(indices, Sizes(lineInd));
    
    for i=1:size(indices)
        index = indices(i);
        label = labels{lineInd(index)};
        Size = Sizes(lineInd(index));
       
%         if Size == 0
%             y = lineBB(i, 2);
%             if y > avgY
%                 Size = 2;
%             end
%         end
        if state == 1
            % Normal -> Normal
            if Size == 1
                output = strcat(output, label, {' '});
            % Normal -> small
            elseif Size == 0
                output = strcat(output, '_{', label, {' '});
            % Normal -> big    
            elseif Size == 2
                output = strcat(output, '^{', label, {' '});
            end
            
        elseif state == 0
            % small -> Normal
            if Size == 1
                output = strcat(output, '}', label, {' '});
            % small -> small
            elseif Size == 0
                output = strcat(output, label, {' '});
            % small -> big    
            elseif Size == 2
                output = strcat(output, '}^{', label, {' '});
            end    
            
        elseif state == 2
            % big -> Normal
            if Size == 1
                output = strcat(output, '}', label, {' '});
            % big -> small
            elseif Size == 0
                output = strcat(output, '}_{', label, {' '});
            % small -> big
            elseif Size == 2
                output = strcat(output, label, {' '});
            end 
            
        end
        state = Size;
    end
    if state ~= 1
        output = strcat(output, '}');
    end
    output = strcat(output, '\\');   
end

beginning = '\documentclass[fleqn]{article}\begin{document} $';

ending = '$ \end{document}';

output = strcat(beginning, output, ending);

str = output{1};
indToDelete = [];
for i=1:size(str, 2) - 1;
    if str(i) == ' '
        if str(i+1) == '_' || str(i+1) == '^'
            indToDelete = [indToDelete i];
        end
    end
end
str(indToDelete) = [];
output = str;
end

function indices = reorderForSubscripts(indices, sizes)
    for i=1:max(size(indices))
       index = indices(i);
       if sizes(index) == 1
          smallIndices = [];
          bigIndices = [];
%           sizes = [];
          for j = i+1 : max(size(indices))
              futIndex = indices(j);
              if sizes(futIndex) == 1
                  break;
              
              elseif sizes(futIndex) == 0
                  smallIndices = [smallIndices j];
              
              elseif sizes(futIndex) == 2
                  bigIndices = [bigIndices j];
              end
%               sizes = [sizes sizes(futIndex)];
          end
          numSmall = max(size(smallIndices));
          numBig = max(size(bigIndices));
          if numSmall ~= 0 && numBig ~= 0
            indices(i+1:i+numSmall) = smallIndices;
            indices(i+numSmall+1 : i+numSmall+numBig) = bigIndices;
          end
       end
        
    end
end

