function [mvec, pvec, MSCRblob] = ExtractMSCR_oneImage(Image,mask,posNeck,posWaist)
%
%
%

%% Global parameters (PUT THEM SOMEWHERE GLOBAL?)
reg  	=   makecform('srgb2lab');

% MSCR parameters
parMSCR.min_margin	= 0.003; %  0.0015;  % Set margin parameter
parMSCR.ainc		= 1.05;
parMSCR.min_size	= 15;
parMSCR.filter_size	= 3;
parMSCR.verbosefl	= 0;  % Uncomment this line to suppress text output

%%
if max(size(Image) ~= [128 64 3])
    warning('image not 128x64, should we resize here?')
end

% Illuminance normalization
[Image] = illuminant_normalization(Image);

% masking
B = double(mask);
Image = double(Image).*cat(3,B,B,B); % mask application

% Equalization
[Ha,S,V] = rgb2hsv(uint8(Image));
Ve = histeq(V(B==1)); Veq = V; Veq(B == 1) = Ve;
Image = cat(3, Ha,S,Veq);
Image = hsv2rgb(Image);

% part-based MSCR computation + outliers elimination
[mah, pah] = detection(Image,B,[1:posNeck],parMSCR,1,0);
[mab, pab] = detection(Image,B,[posNeck+1:posWaist],parMSCR,1,0);
[mal, pal] = detection(Image,B,[posWaist+1:size(Image,1)],parMSCR,1,0);

mab(3,:) = mab(3,:)+double(posNeck);
mal(3,:) = mal(3,:)+double(posWaist);

mvec = [mah mab mal];
pvec = [pah pab pal];

% MSCRblob.mvec = mvec;
% MSCRblob.pvec = pvec;

% DON'T UNDERSTAND WHAT THIS "MSE ANALYSIS" IS FOR
% mser    =   MSCRblob;
A = permute(pvec, [3,2,1]);
C = applycform(A, reg);
colour = permute(C,[3,2,1]);

MSCRblob.Mmvec=mvec;
MSCRblob.Mpvec=colour;

