function plotBodyPartMasks(paddedImage,maskset)
%
% Plots body-part masks onto the pedestrian image
%
% paddedImage must be a detection image smartly padded to 2/1 ratio (height = 2*width)
% by smartPadImageToBodyPartMaskSize.m
%
% maskset must be a 4x1 cell array, each cell containing a binary image of
% the same height and width as paddedImage, that masks the respective
% body-part.
% If masks aren't the same size as padded image (supposedly 

[hei,wid,chs] = size(paddedImage);
[heiM, widM] = size(maskset{1});
if max([heiM, widM] ~= [hei, wid])
    assert(heiM==128 && widM==64, ' Something''s wrong, body-part masks are not same size as padded image, nor are they 128x64 size.')
    %warning(['Body-part masks of original size do not exist, probably because they would be too large (several GB).' ...
    %    ' Using sub-sampled masks (128x64) instead.'])
    % and Resizing masks to original image size
    clear thisMaskSet,
    for partIt = 1:4
        resizedMaskSet{partIt} = imresize(maskset{partIt},[hei,wid]);
    end
else
    resizedMaskSet = maskset;
end
for partIt = 1:4
    %B = bwboundaries(masks{count,partIt});
    B = bwboundaries(resizedMaskSet{partIt});
    switch partIt
        case 1 %head
            color = 'b';
        case 2 %torso
            color = 'w';
        case 3 %thighs
            color = 'm';
        case 4 %fore-legs
            color = 'r';
    end
    for k = 1:length(B)
        boundary = B{k};
        plot(boundary(:,2), boundary(:,1), color, 'LineWidth', 3)
    end
end
