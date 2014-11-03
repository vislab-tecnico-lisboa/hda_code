function MAP_KRNL = makeBodyKernel(img, Waist, MiddleTorso, MiddleLegs, Neck)

%% Global parameters (PUT THEM SOMEWHERE GLOBAL?)
SUBfac  = 1;    % subsampling factor <==== CHANGE TO 0.5 WHEN USING ETHZ DATASET!!!
H = ceil(128*SUBfac); W = ceil(64*SUBfac); % NORMALIZED dimensions

% symmetries parameters
val    = 4;
delta = [H/val W/val]; % border limit (in order to avoid the local minimums at the image border)
varW    = W/5; % variance of gaussian kernel (torso-legs)
alpha = 0.5;

search_range_H  =   [delta(1),H-delta(1)];
search_range_W  =   [delta(2),W-delta(2)];

%%
img_hsv     =   rgb2hsv(img);
tmp         =   img_hsv(:,:,3);
tmp         =   histeq(tmp); % Color Equalization
img_hsv     =   cat(3,img_hsv(:,:,1),img_hsv(:,:,2),tmp); % eq. HSV


% if ~any(isnan(det_final(i,:))) % NaN = head not found
%     HEAD = img_hsv(1:Neck,:,:);
%     cntr = [det_final(i,1)+det_final(i,3)/2,det_final(i,2)+det_final(i,4)/2];
%     HEADW = radial_gau_kernel(cntr,DIMW*3,size(HEAD,1),W);
% else
    HEADW = zeros(Neck,W);
% end

if (Neck+1 >= Waist)
    Neck = Neck - 2;
end

UP = img_hsv(Neck+1:Waist,:,:);
UPW = gau_kernel(MiddleTorso,varW,size(UP,1),W);

DOWN = img_hsv(Waist+1:end,:,:);
DOWNW = gau_kernel(MiddleLegs,varW,size(DOWN,1),W);

MAP_KRNL = [HEADW/max(HEADW(:));UPW/max(UPW(:));DOWNW/max(DOWNW(:))];
if (H-size(MAP_KRNL)>=0)
    MAP_KRNL = padarray(MAP_KRNL,H-size(MAP_KRNL,1),'replicate','post');
else
    MAP_KRNL = MAP_KRNL(1:H,:);
end
