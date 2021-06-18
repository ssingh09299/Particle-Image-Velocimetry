function result = CrossCorrelation2(f,g)
[rowG,colG] = size(g);
[rowF,colF] = size(f);
fpadded = padarray(f,[rowG-1,colG-1]);
result = zeros(rowG+rowF-1,colG+colF-1);
for i=1:size(result,1)
    for j=1:size(result,2)
        result(i,j) = sum(sum(fpadded(i:i+rowG-1,j:j+colG-1).*g));        
    end
end