function BVTfeature = extractBVT(paddedImage,maskset)
%
% Extracts BVT histograms from the given images and parts.
%

[nParts] = size(maskset,2);

% Resizing maskset from 128x64 to image size
[hei,wid,chs] = size(paddedImage);
[heiM, widM] = size(maskset{1});
if max([heiM, widM] ~= [hei, wid])
    assert(heiM==128 && widM==64, ' Something''s wrong, body-part masks are not same size as padded image, nor are they 128x64 size.')
    %warning(['Body-part masks of original size do not exist, probably because they would be too large (several GB).' ...
    %    ' Using sub-sampled masks (128x64) instead.'])
    % and Resizing masks to original image size
    clear thisMaskSet,
    for partIt = 1:nParts
        resizedMaskSet{partIt} = imresize(maskset{partIt},[hei,wid]);
    end
else
    resizedMaskSet = maskset;
end

% Default histogram feature paramethers
% display('TODO: check if part weights improves results')
parVT = struct('NBINs', [10 10 10],'quantMinval',1,'scaleV',36,'scaleB',232,...
    'partWeights', [0.44 0.42 0.42 0.44 0.06 1]); %leg thigh thigh leg head body
weights = parVT.partWeights;


scaleB = parVT.scaleB / 100;
scaleV = parVT.scaleV / 100;
weights = parVT.partWeights;
qlevels = parVT.NBINs; qvals = qlevels - 1;
qminval = parVT.quantMinval;
chromaarea = qlevels(1)*qlevels(2);
histSize = chromaarea + qlevels(3);


[hei,wid,trash]  = size(paddedImage);
area = hei*wid; % it varies from image to image

A = rgb2hsv(paddedImage);
H = round(A(:,:,1) * qvals(1)); % quantized hue
S = round(A(:,:,2) * qvals(2)); % quantized saturation
V = round(histeq(A(:,:,3)) * qvals(3)); % quantized brightness
T = reshape(H + (S * qlevels(1)),[area 1]); % tint = combined hue + sat

% remove hue+sat from black pixels
blackspots = (V < qminval);

hist = zeros(nParts * histSize,1);

for pp = 1:nParts
    
    % mask out black spots
    maskVT = resizedMaskSet{pp};
    maskVT(blackspots) = false;
    %maskB = pmskset{ii,pp} & blackspots;
    maskB = resizedMaskSet{pp} & blackspots;
    blacks = sum(maskB(:)) * scaleB;
    
    grays = accumarray([V(:)+1; qlevels(3)],[maskVT(:); 0]) * scaleV;
    colors = accumarray([T(:)+1; chromaarea],[maskVT(:); 0]);
    
    indices = (pp-1)*histSize+1:pp*histSize;
    hist(indices) = [blacks; grays(2:end); colors] * (128*64/area); % * weights(pp)
    % dividing by area to normalize the histograms
    % multiplying by 128*64 for historical reasons (didn't divide by area before)
end
BVTfeature = hist;
