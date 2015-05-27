function Labfeature = extractLab(paddedImage,maskset)
%
% Extracts Lab histograms from the given images and parts.
%

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
    for partIt = 1:nParts
        resizedMaskSet{partIt} = imresize(maskset{partIt},[hei,wid]);
    end
else
    resizedMaskSet = maskset;
end


Lbins = [0:1/9:1]; % if we equalize, it's easier on histeq() to use domain [0 1]
abins = [-7:(38+7)/9:38];
bbins = [-8:(55+8)/9:55];
% qlevels = [10 10 10]; % parLab.NBINs; 
% qvals = qlevels - 1;
histSize = length(Lbins) + length(abins) + length(bbins);

Labfeature = zeros(1,nParts*histSize);

    [hei,wid,~]  = size(paddedImage);
    area = hei*wid; % it varies from image to image

    A = RGB2Lab(paddedImage);    
    L = histeq(A(:,:,1)/100); % Experimentally? EQ works better than no EQ on brightness
%     L = A(:,:,1)/100; % Experimentally? EQ works better than no EQ on brightness
    a = A(:,:,2); %
    b = A(:,:,3); %
    
    Labfeature = zeros(nParts * histSize,1);
        
    for pp = 1:nParts
        maskLab = resizedMaskSet{pp}; 
        LpartImage = L(maskLab);
        apartImage = a(maskLab);
        bpartImage = b(maskLab);

        Ls =  hist(LpartImage, Lbins);
        as =  hist(apartImage, abins);
        bs =  hist(bpartImage, bbins);
                
        indices = (pp-1)*histSize+1:pp*histSize;
        Labfeature(indices) = [Ls; as; bs] * (128*64/area);
    end

    
%     % expects A belonging to [0 1] interval
%     H = round(A(:,:,1) * qvals(1)); % quantized hue
%     S = round(A(:,:,2) * qvals(2)); % quantized saturation
%     V = round(histeq(A(:,:,3)) * qvals(3)); % quantized brightness  
% %     V = round((A(:,:,3)) * qvals(3)); % quantized brightness  
%     % WHY EQUALIZE? Experimentally? EQ works better than no EQ on brightness
%     
%     Labfeature = zeros(nParts * histSize,1);
%         
%     for pp = 1:nParts
%         maskHSV = resizedMaskSet{pp}; 
%         % mask out black spots
% %         maskHSV(blackspots) = false;
% %         maskB = pmskset{ii,pp} & blackspots;
% %         blacks = sum(maskB(:)) * scaleB;
%         
%         hues =  accumarray([H(:)+1; qlevels(1)],[maskHSV(:); 0]);
%         sats =  accumarray([S(:)+1; qlevels(2)],[maskHSV(:); 0]);
%         vals =  accumarray([V(:)+1; qlevels(3)],[maskHSV(:); 0]);
%         
% %         grays = accumarray([V(:)+1; qlevels(3)],[maskHSV(:); 0]) * scaleV;
% %         colors = accumarray([T(:)+1; chromaarea],[maskHSV(:); 0]);
%         
%         indices = (pp-1)*histSize+1:pp*histSize;
%         Labfeature(indices) = [hues; sats; vals] * (128*64/area); % * weights(pp); default not interesting in HDA
%     end
%     Labfeature = Labfeature;
%     
% %     waitbar(ii/nPed,hwait);
% % end
% % close(hwait); pause(0.0001), % pause because matlab is stupid and won't close the windows sometimes
