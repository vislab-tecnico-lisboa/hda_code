function iih = integral_image_histogram(I, dBox, nbins)
% iih = integral_image_histogram(I, dBox, nbins)
%
% Input:
%  - I: masked image (blacks where dBox is zero)
%  - dBox is optional, and if not present, the histogram is of the whole image I;
%  - nbins is optional and defaults to 256;

if nargin == 2
    nbins = 256;
end
%iih = zeros(nbins, size(I,1),size(I,3));
if nargin == 2 || nargin == 3
    for c=1:size(I,3)
        iih(:,c,1) = imhist(I(1,:,c), nbins);
        iih(1,c,1) = iih(1,c,1) - sum(dBox(1,:)==0);
        for i=2:size(I,1)
            iih(:,c,i) = iih(:,c,i-1) + imhist(I(i,:,c), nbins);
            iih(1,c,i) = iih(1,c,i) - sum(dBox(i,:)==0);
        end
    end
elseif nargin == 1
    for c=1:size(I,3)
        iih(:,1,c) = imhist(I(1,:,c), nbins);
        for i=2:size(I,1)
            iih(:,i,c) = iih(:,i-1,c) + imhist(I(i,:,c), nbins);
        end
    end    
end
