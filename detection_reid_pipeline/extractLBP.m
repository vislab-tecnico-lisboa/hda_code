function LBPfeature = extractLBP(paddedImage,maskset)
% 
% Extracts LBP histograms from the given images and parts.
% 
% 

N = 8; % N samples around each pixel
R = 2; % of radius R
TYPE = 'u2'; % uniform LBP, all non-uniform tossed into a single bin
% OUTPUT = 'nh'; % 'h' : output histogram; 'nh : normalized histogram
histSize = 59; % 'u2', R=2, N=8 : 58 bins for uniform patterns, 1 bin for rest
% TODO: AUTOMATE histSize COMPUTATION SOMEHOW (MAYBE A TABLE FOR ALL
% COMMON COMBINATIONS OF N, R AND TYPE
mapping=getmapping(N,TYPE);

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
area = size(A,1)*size(A,2);
LBPcodeI =lbp(A,R,N,mapping, ''); % outputs LBP code image
LBPcodeIpadded = padarray(LBPcodeI,[R R],0,'both'); % LBP code image is

LBPfeature = zeros(nParts * histSize,1);
for pp = 1:nParts
    partMask = resizedMaskSet{pp};
    
    LBPhist =  accumarray([LBPcodeIpadded(:)+1; histSize], [partMask(:); 0]);
    % TODO: CORRECT FOR THE PADDED PART!! (MAYBE CHECK IF MASK FALLS IN
    % PADDED PART AND REMOVE THAT NUMBER OF ELEMENTS IN THE FIRST BIN
    % (LBP PATTERN 57 (58th bin))
    
    indices = (pp-1)*histSize+1:pp*histSize;
    LBPfeature(indices) = LBPhist * (128*64/area);
end

% MR8partHist = zeros(nParts,size(bins,1),size(bins,2));
% for pp = 1:nParts
%     mask = resizedMaskSet{pp};
%     for i=1:8
%         MR8part = MR8I(i,:);
%         MR8part = MR8part(mask);
%         MR8partHist(pp,i,:) = hist(MR8part, bins(i,:));
%         % the order should be switched here so it is more MATlab
%         % elegant, i.e., should be (:,pp,i)
%     end
% end
% area = size(A,1)*size(A,2);
% LBPfeature = MR8partHist(:) * (128*64 / area);
%unroll it, don't know exactly the
% order of the parts in the vector, or of the 8 filters, but unroll it
% in a consistent way, so when we compare, it's always comparing the
% same part to the same part, and the same filter response with the
% same
