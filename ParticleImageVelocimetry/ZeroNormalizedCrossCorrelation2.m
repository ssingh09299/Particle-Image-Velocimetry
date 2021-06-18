function result = ZeroNormalizedCrossCorrelation2(f,g)
%{
%%% uncomment if you are interested in using user function for cross
%%% correlation (this might be slower than matlab inbuilt function)
[rowG,colG] = size(g);
[rowF,colF] = size(f);
fpadded = padarray(f,[rowG-1,colG-1]);
result = zeros(rowG+rowF-1,colG+colF-1);

gError = g-mean(g(:));
for i=1:size(result,1)
    for j=1:size(result,2)
        fpaddedError = fpadded(i:i+rowG-1,j:j+colG-1);
        fpaddedError = fpaddedError-mean(fpaddedError(:));
        result(i,j) = sum(sum(fpaddedError.*gError))/...
            sqrt((sum(sum(fpaddedError.*fpaddedError))*sum(sum(gError.*gError))));
    end
end
%}

% using matlab function xcorr2
fError = f-mean(f(:));
gError = g-mean(g(:));
result = xcorr2(fError,gError)/sqrt(sum(fError(:).^2)*...
    sum(gError(:).^2));