%% Beginner's code for Particle image velocimetry
% This code is written to introduce and show working of the particle image
% velocimetry. There are several codes available which are much advance in
% their processing but it becomes difficult to follow them. This code is
% developed from Particle Image Velocimetry - A Practical Guide by authors
% Raffel, M., Willert, C.E., Wereley, S., Kompenhans, J. 
% Book link - <https://www.springer.com/gp/book/9783642431661>
% If you find any error in the code please mail to saurabhhbti08@gmail.com
close all
%% Extract the list of image files
% code expects that you have saved all the image file in a separate
% subfolder under the folder where the current code is saved

% get the name of current folder
currentDirectory = pwd;
% go to image file folder
folder = uigetdir('','Get the image folder');
% change directory for getting the list of files
cd(folder)
% get the list of files and their details 
List = dir('*.bmp'); 
% Go back to main directory
cd(currentDirectory)

%% Inputs
% Input fot grid and search window
gridSize = 16; % The grid size should always be smaller than window size
winSize = 32;  % Window size is based maximum displacement between two 
               % images consecutive or otherwise

% image intensity cutoff for objects under the consideration
lCutoff = 20; uCutoff = 210; % areas in the image beyond this intensity 
                             % bound is set to be stagnant

% velocity calculated from frames at an interval of step
step = 4; % skip (step) frames for displacement calculation e.g. if step = 
          % 4; 1st and 5th image; 2nd and 6th image
loop = 1:(size(List,1)-step);

%% Create the grid

% reading the first image to get the details on the image frame
file1 = [List(1).folder,'\',List(1).name];
% read the image
f = imread(file1);
% get the number of grid in row and column direction based on the grid size
numRowGrid = floor(size(f,1)/gridSize);
numColGrid = floor(size(f,2)/gridSize);

% initialize the displacements
colDisp = zeros(numRowGrid,numColGrid,numel(loop));
rowDisp = zeros(numRowGrid,numColGrid,numel(loop));

% clear the redundant variables
clear('file1','f')

% Grid is created below
row = floor(gridSize/2):gridSize:((numRowGrid-1)*gridSize+...
    floor(gridSize/2));
col = floor(gridSize/2):gridSize:((numColGrid-1)*gridSize+...
    floor(gridSize/2));
[col,row] = meshgrid(col,row);

%% Mask the redundant part of image
% Use of mask to limit the area of cross correlation if not issue a warning
try
    mask = logical(imread('mask.bmp'));
catch
    warning('Mask does not exist in the current directory, No masking will be done performing whole image operation')
    mask = true(size(f));
end

%% Do PIV and obtain the displacement fields
Folder = List(1).folder; fileName = cat(1,List(:).name);
Time = tic;
for i=loop
    % pick two images from the set for analysis at a difference of step
    file1 = [Folder,'\',fileName(i,:)];
    file2 = [Folder,'\',fileName(i+step,:)]; %#ok<PFBNS>
    
    % read the images
    f = imread(file1); g = imread(file2);
    
    % USE PIV TO GET THE DISPLACEMENTS
    [colDisp(:,:,i),rowDisp(:,:,i)] = ParticleImageVelcoimetry(f,g,gridSize,winSize,lCutoff,uCutoff,mask);
end
disp(['The PIV process took: ',num2str(toc(Time)),' seconds'])
%% Plot the results
for i=1:size(rowDisp,3)
    hf = figure(); ha = axes(hf,'YDir','Reverse'); hold on
    quiver(ha,col,row,colDisp(:,:,i),rowDisp(:,:,i),2)
    %%% Uncomment below to save the files
%     saveas(hf,List(i).name)
    pause(1)
    close(hf)
end

