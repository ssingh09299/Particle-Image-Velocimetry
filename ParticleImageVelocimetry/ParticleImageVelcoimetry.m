function [colDisp,rowDisp] = ParticleImageVelcoimetry(f,g,gridSize,winSize,lCutoff,uCutoff,mask)
% This is the soul of the whole process, actual PIV happens here

% Below is used for post processing (Not very important for understanding
% the algorithm)
NeighborhoodDataValidation = 2;

% The images to be processed (displacement field is to be calculated between these two)
f = double(f); g = double(g);

% Number of grids in rwo and column of image based on the grid size
numRowGrid = floor(size(f,1)/gridSize);
numColGrid = floor(size(f,2)/gridSize);

% padding the images with window size from surrounding
fp = padarray(f,[winSize,winSize]);
gp = padarray(g,[winSize,winSize]);

% initialize the displacement field
rowDisp = zeros(numRowGrid,numColGrid);
colDisp = zeros(numRowGrid,numColGrid);

% loop over each grid point (center of the grid is considered as grid point)
for i=1:numRowGrid
    for j=1:numColGrid
        % coordinates of ith grid point
        rGrid = (i-1)*gridSize+floor(gridSize/2);
        cGrid = (j-1)*gridSize+floor(gridSize/2);
        
        % if intensity of grid point is of no interest or grid point lies
        % on the unmasked region --- then continue to next grid point
        if (f(rGrid,cGrid)>uCutoff)||(f(rGrid,cGrid)<lCutoff)||(~mask(rGrid,cGrid))
            continue
        end
        
        % else get a window around the grid point in the padded images
        fWindow = fp(rGrid+floor(winSize/2)+1:rGrid+3*floor(winSize/2),...
            cGrid+floor(winSize/2)+1:cGrid+3*floor(winSize/2));
        
        gWindow = gp(rGrid+floor(winSize/2)+1:rGrid+3*floor(winSize/2),...
            cGrid+floor(winSize/2)+1:cGrid+3*floor(winSize/2));
        
        % if any on of the padded image window is all zero (completely
        % black) continue to next grid point
        if all(~fWindow(:))||all(~gWindow(:))
            continue
        else
            % else get the cross correlation result between two padded
            % image windows
            result = ZeroNormalizedCrossCorrelation2(fWindow,gWindow);
            
            % if result contain all not a number (nan) then continue to
            % next grid point
            if all(isnan(result(:)))
                continue
            end
            
            
            % get the location of peak in cross correlation
            [m,n] = find(result==max(result(:)));
            m = round(mean(m)); n = round(mean(n));
            
            
            % computing component of displacement along row and column
            if (m<=1)||(n<=1)||(m>=size(result,1))||(n>=size(result,2))
                rowDisp(i,j) = winSize-m;
                colDisp(i,j) = winSize-n;
            else
                % further finding subpixel values (refer to the book)
                m1 = m+(log(result(m-1,n))-log(result(m+1,n)))/...
                    (2*log(result(m-1,n))-4*log(result(m,n))+2*log(result(m+1,n)));
                n1 = n+(log(result(m,n-1))-log(result(m,n+1)))/...
                    (2*log(result(m,n-1))-4*log(result(m,n))+2*log(result(m,n+1)));
                
                % computing component of displacement along row and column
                rowDisp(i,j) = winSize-m1;
                colDisp(i,j) = winSize-n1;
            end
        end
    end
end
[colDisp,rowDisp] = dataValidation(colDisp,rowDisp,NeighborhoodDataValidation);
