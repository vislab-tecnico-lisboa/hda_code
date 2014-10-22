function HSV = extractHSVfromBodyParts(paddedImage,maskset)
% HSV = TextractHSV(dataset,pmskset,ped,parHSV,tt)
%
% Extracts HSV histograms from the given images and parts.
%
% input:
%  - dataset
%  - pmskset
%  - parHSV struct
%     - .quantMinval 
%     - .NBINS 
%  - tt - currently unused
%
% output:
%  - HSV hist divided by total number of pixels (area) multiplied by 128*64

[nParts] = size(maskset,2);
% globals = [ped.global];

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


% scaleB = parHSV.scaleB / 100;
% scaleV = parHSV.scaleV / 100;

% weights = parHSV.partWeights;
% cprintf('*err','ADDED PART WEIGHTS, DELETE SAVED F AND CHECK IF BENEFIT'),

% qlevels = parHSV.NBINs;% [10 10 10]; % parHSV.NBINs; 
qlevels = [10 10 10]; % parHSV.NBINs; 
qvals = qlevels - 1;
qminval = 1; % parHSV.quantMinval;
% chromaarea = qlevels(1)*qlevels(2);
% histSize = chromaarea + qlevels(3);
histSize = qlevels(1) + qlevels(2) + qlevels(3);

HSV = zeros(1,nParts*histSize);

% hwait = waitbar(0,'Extracting HSV histograms..');
% for ii = 1:nPed
    [hei,wid,~]  = size(paddedImage);
    area = hei*wid; % it varies from image to image

    A = rgb2hsv(paddedImage);
    % expects A belonging to [0 1] interval
    H = round(A(:,:,1) * qvals(1)); % quantized hue
    S = round(A(:,:,2) * qvals(2)); % quantized saturation
    V = round(histeq(A(:,:,3)) * qvals(3)); % quantized brightness  
%     V = round((A(:,:,3)) * qvals(3)); % quantized brightness  
    % WHY EQUALIZE? Experimentally? EQ works better than no EQ on brightness
    
    Hist = zeros(nParts * histSize,1);
        
    for pp = 1:nParts
        maskHSV = resizedMaskSet{pp}; 
        % mask out black spots
%         maskHSV(blackspots) = false;
%         maskB = pmskset{ii,pp} & blackspots;
%         blacks = sum(maskB(:)) * scaleB;
        
        hues =  accumarray([H(:)+1; qlevels(1)],[maskHSV(:); 0]);
        sats =  accumarray([S(:)+1; qlevels(2)],[maskHSV(:); 0]);
        vals =  accumarray([V(:)+1; qlevels(3)],[maskHSV(:); 0]);
        
%         grays = accumarray([V(:)+1; qlevels(3)],[maskHSV(:); 0]) * scaleV;
%         colors = accumarray([T(:)+1; chromaarea],[maskHSV(:); 0]);
        
        indices = (pp-1)*histSize+1:pp*histSize;
        Hist(indices) = [hues; sats; vals] * (128*64/area); % * weights(pp); default not interesting in HDA
    end
    HSV = Hist;
    
%     waitbar(ii/nPed,hwait);
% end
% close(hwait); pause(0.0001), % pause because matlab is stupid and won't close the windows sometimes
