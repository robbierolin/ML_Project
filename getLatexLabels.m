function [ labels ] = getLatexLabels( intLabels )
labels = {};
numLabels = size(intLabels);
legend = {'\alpha' '\beta' '\lambda'};
for i=1:numLabels
   labels{i} = legend(intLabels(i)); 
end

end

