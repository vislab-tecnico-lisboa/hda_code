function [Waist, MiddleTorso, MiddleLegs, Neck] = neckWaist_and_middle_Detector(Image,mask)
%
%

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

reg  	=   makecform('srgb2lab');

%%


% feature extraction
img_hsv     =   rgb2hsv(Image);
img_cielab  =   applycform(Image, reg); % eq. CIELAB

%     TLanti(i)   = uint16(fminbnd(@(x) sym_dissimilar_MSK(x,img_hsv,mask,NBINs,30*SUBfac,0.5),search_range_H(1),search_range_H(2)));
%     BUsim(i)    = uint16(fminbnd(@(x) sym_similar_MSKLR(x,img_hsv(1:TLanti(i),:,:),mask(1:TLanti(i),:),NBINs,20*SUBfac,0.7),search_range_W(1),search_range_W(2)));
%     LEGsim(i)   = uint16(fminbnd(@(x) sym_similar_MSKLR(x,img_hsv(TLanti(i)+1:end,:,:),mask(TLanti(i)+1:end,:),NBINs,20*SUBfac,0.7),search_range_W(1),search_range_W(2)));
% 	if maskon
% 		HDanti(i)   = uint16(fminbnd(@(x) sym_dissimilar_MSKH(x,img_hsv,mask,20),5,double(TLanti(i))));
% 	else
% 		HDanti(i)   = uint16(fminbnd(@(x) sym_dissimilar_MSKH2(x,BUsim(i),TLanti(i),img_hsv,mask,NBINs,20*SUBfac,30*SUBfac),bord,double(TLanti(i))-bord));
% 	end

Waist   = uint16(fminbnd(@(x) dissym_div(x,img_hsv,mask,delta(1),alpha),search_range_H(1),search_range_H(2)));
MiddleTorso    = uint16(fminbnd(@(x) sym_div(x,img_hsv(1:Waist,:,:),mask(1:Waist,:),delta(2),alpha),search_range_W(1),search_range_W(2)));
MiddleLegs   = uint16(fminbnd(@(x) sym_div(x,img_hsv(Waist+1:end,:,:),mask(Waist+1:end,:),delta(2),alpha),search_range_W(1),search_range_W(2)));
Neck   = uint16(fminbnd(@(x) sym_dissimilar_MSKH(x,img_hsv,mask,delta(1)),5,double(Waist)));
