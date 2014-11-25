function MR8 = extractMR8(paddedImage,maskset)
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

Min(1) = -1.5;      Max(1) = 1.92;      Step(1) = (Max(1)-Min(1))/9; 
Min(2) = -0.022;    Max(2) = 0.0158;    Step(2) = (Max(2)-Min(2))/9; 
Min(3) = 0.857/10;  Max(3) = 0.857;     Step(3) = (Max(3)-Min(3))/9; 
Min(4) = 0.477/10;  Max(4) = 0.477;     Step(4) = (Max(4)-Min(4))/9; 
Min(5) = 0.237/10;  Max(5) = 0.237;     Step(5) = (Max(5)-Min(5))/9; 
Min(6) = -0.102;    Max(6) = 0.402;     Step(6) = (Max(6)-Min(6))/9; 
Min(7) = -0.0402;   Max(7) = 0.144;     Step(7) = (Max(7)-Min(7))/9; 
Min(8) = -0.0163;   Max(8) = 0.0471;    Step(8) = (Max(8)-Min(8))/9; 
for i=1:8
    bins(i,:) = [Min(i):Step(i):Max(i)];    
end

[nParts] = size(maskset,2);

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

A = rgb2gray(paddedImage);
MR8I =MR8fast(A); % outputs MR8 feature vectors

MR8partHist = zeros(nParts,size(bins,1),size(bins,2));
for pp = 1:nParts
    mask = resizedMaskSet{pp};
    for i=1:8
        MR8part = MR8I(i,:);
        MR8part = MR8part(mask);
        MR8partHist(pp,i,:) = hist(MR8part, bins(i,:));
        % the order should be switched here so it is more MATlab
        % elegant, i.e., should be (:,pp,i)
    end
end
area = size(A,1)*size(A,2);
MR8 = MR8partHist(:) * (128*64 / area);
%unroll it, don't know exactly the
% order of the parts in the vector, or of the 8 filters, but unroll it
% in a consistent way, so when we compare, it's always comparing the
% same part to the same part, and the same filter response with the
% same
