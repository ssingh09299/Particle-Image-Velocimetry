function [colDisp,rowDisp] = dataValidation(colDisp,rowDisp,NeighborhoodDataValidation)
% performed normalized meadian test on a neighborhood
% This is as per the referenced book

% data validation is based on the smoothness of the displacement field i.e.
% we do not expect an unreasonably high jump in the displacement field in a
% given neighborhood size
n = NeighborhoodDataValidation; epsNod = 0.2; epsThresh = 5;

[numRowGrid,numColGrid] = size(colDisp);
colDispPadded = padarray(colDisp,[n,n],'symmetric');
rowDispPadded = padarray(rowDisp,[n,n],'symmetric');

rMed = [];
for i=1:numRowGrid
    for j=1:numColGrid
        rowDispWindow = rowDispPadded(i:i+2*n,j:j+2*n);
        colDispWindow = colDispPadded(i:i+2*n,j:j+2*n);
        
        rowDispMed = median(rowDispWindow(:)); colDispMed = median(colDispWindow(:));
        rowDispDiff = rowDispWindow-rowDispMed; 
        colDispDiff = colDispWindow-colDispMed;
        residuals = sqrt(rowDispDiff.^2+colDispDiff.^2);
        
        indCenter = sub2ind(size(rowDispWindow),n+1,n+1);
        residualMed = median(residuals([1:indCenter-1,indCenter+1:end]));
        
        residualElement = residuals(n+1,n+1);
        Threshold = (residualElement)/(residualMed+epsNod);
        
        if Threshold<epsThresh
            continue
        else
           colDisp(i,j) = colDispMed;
           rowDisp(i,j) = rowDispMed;
        end
        rMed = [rMed;residualMed];
    end
end
hf = figure();
plot(rMed)
close(hf)