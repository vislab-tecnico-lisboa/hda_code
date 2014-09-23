function [paddedImage, smallPaddedImage] = smartPadImageToBodyPartMaskSize(image,H,W,bord)
% smartResizeImageToBodyPartMaskSize Resize image to body-part mask size
% 
% function resizedImage = smartResizeImageToBodyPartMaskSize(image,H,W),
% for an image IMAGE, and target 
%
% Load and resize the images from the given directory and list and
% save the dataset in the given namefile and return it
% 
% output:
%  saved file in MAT/_DATASETS_/dataset_ expName _fX.mat
%  - dataset: all dataset images, all same size
%


% if the border to ignore param is not given, then don't use it
if ~exist('bord','var'), bord = 0; end,
if ~exist('W','var'),    W = 64;   end,
if ~exist('H','var'),    H = 128;  end,

targetRatio = H/W;

% check if we need to crop the borders
if bord > 0
    image = image(bord+1:end-bord,bord+1:end-bord,:);
end

%         figure(199);
%         bigsubplot(1,3,1,1); imagesc(img); axis equal; axis off;
%         bigsubplot(1,3,1,2); imagesc(imresize(img,[H,W])); axis equal; axis off;

[hei,wid,chs] = size(image);
thisRatio = hei/wid;

if thisRatio > targetRatio
    % image is short on width, pad width
    pad = hei / targetRatio - wid;
    image = padarray(image,[0 round(pad/2) 0],'replicate','both');
elseif thisRatio < targetRatio
    % too FAT, padding height    
    pad = wid * targetRatio - hei;
    image = padarray(image,[round(pad/2) 0 0],'replicate','both');
end

paddedImage = image;

smallPaddedImage = imresize(image,[H,W]);

