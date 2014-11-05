function TxPatch = extractTxPatch(paddedImage,mask)

% Merge body-part masks into full-body mask
[nImg,nParts] = size(mask);
if nParts == 6
    fullmask = mask{1,1} | mask{1,2} | mask{1,3} | mask{1,4} | mask{1,5} | mask{1,6};
elseif nParts == 4
    fullmask = mask{1,1} | mask{1,2} | mask{1,3} | mask{1,4};
end

% Resize image to 128x64
[hei,wid,chs] = size(paddedImage);
[heiM, widM] = size(fullmask);
if max([heiM, widM] ~= [hei, wid])
    assert(heiM==128 && widM==64, ' Something''s wrong, body-part masks are not same size as padded image, nor are they 128x64 size.')
    resizedImage = imresize(paddedImage,[heiM,widM]);
end


DEBUGplot = 0;
[Waist, MiddleTorso, MiddleLegs, Neck] = neckWaist_and_middle_Detector(resizedImage,fullmask);
if DEBUGplot
    figure,
    subplot(1,2,1),
    imagesc(resizedImage), axis image,axis off,hold on;
    plot([1,widM],[Waist,Waist],'r','LineWidth',3);
    plot([1,widM],[Neck,Neck],'r','LineWidth',3);
    plot([MiddleTorso,MiddleTorso],[Neck,Waist],'r','LineWidth',3);
    plot([MiddleLegs,MiddleLegs],[Waist+1,heiM],'r','LineWidth',3);hold off;
end

KernelMap = makeBodyKernel(resizedImage, Waist, MiddleTorso, MiddleLegs, Neck);
if DEBUGplot
    subplot(1,2,2),
    imagesc(KernelMap), axis image
end

% [mvec, pvec, MSCRblob] = ExtractMSCR_oneImage(resizedImage,fullmask,Neck,Waist);
% 
% wHSV = ExtractwHSV_oneImage(resizedImage,KernelMap,Neck,Waist);

TxPatch = ExtractTxPatch_oneImage(resizedImage, KernelMap, fullmask, MiddleTorso,Waist);


