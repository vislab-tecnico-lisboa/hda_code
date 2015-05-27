function HSV = extractHSVfromBodyParts(paddedImage,maskset)
% HSV = TextractHSV(dataset,pmskset,ped,parHSV,tt)
%
% Extracts HSV histograms from the given images and parts.
%
% input:
%  - paddedImage: cropped image of a pedestrian, padded to 2x1 height/width
%  ratio.
%  - maskset: mask binary images, one per body part, of same size as
%  paddedImage or of 128x64 size. In cell array.
%
% output:
%  - HSV hist divided by total number of pixels (area) multiplied by 128*64

% Number of bins for H, S and V
qlevels = [10 10 10]; 

histSize = qlevels(1) + qlevels(2) + qlevels(3);
qvals = qlevels - 1;

[nParts] = size(maskset,2);

[hei,wid,chs] = size(paddedImage);
[heiM, widM] = size(maskset{1});
if max([heiM, widM] ~= [hei, wid])
    assert(heiM==128 && widM==64, ' Something''s wrong, body-part masks are not same size as padded image, nor are they 128x64 size.')
    % resizing masks to original image size
    clear thisMaskSet,
    for partIt = 1:nParts
        resizedMaskSet{partIt} = imresize(maskset{partIt},[hei,wid]);
    end
else
    resizedMaskSet = maskset;
end

[hei,wid,~]  = size(paddedImage);
area = hei*wid; % it varies from image to image

A = rgb2hsv(paddedImage); % expects A belonging to [0 1] interval
H = round(A(:,:,1) * qvals(1)); % quantized hue
S = round(A(:,:,2) * qvals(2)); % quantized saturation
V = round(histeq(A(:,:,3)) * qvals(3)); % quantized brightness
% Why equalize? Experimentally equalization works better than no equalization on brightness

HSV = zeros(nParts * histSize,1);        
for pp = 1:nParts
    maskHSV = resizedMaskSet{pp};
    
    hues =  accumarray([H(:)+1; qlevels(1)],[maskHSV(:); 0]);
    sats =  accumarray([S(:)+1; qlevels(2)],[maskHSV(:); 0]);
    vals =  accumarray([V(:)+1; qlevels(3)],[maskHSV(:); 0]);
    
    indices = (pp-1)*histSize+1:pp*histSize;
    HSV(indices) = [hues; sats; vals] * (128*64/area); 
end
    
