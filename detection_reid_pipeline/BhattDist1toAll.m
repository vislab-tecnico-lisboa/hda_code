function  distVT1 =  BhattDist1toAll(F97testIm, F96)
% function  distVT1 =  BhattDist1toAll(F97(testIm,:), F96)
% Compute distances of test sample to all train samples

avoid0 = realmin;

% VTd = double([F96; F97(testIm,:)]);
VTd = double([F96; F97testIm]);
[nImages,histLen] = size(VTd); % VT should be nImages x histLen
normVec = avoid0 + sum(VTd,2); % vector with sum of each ped hist
hists_i = sqrt(VTd ./ normVec(:,ones(1,histLen))); % each hist normalized to 1, sqrt'ed
norm1 = avoid0 + sum(F97testIm);
hist_test = sqrt(F97testIm/norm1);
distVT1 = real(sqrt(1 - hists_i * hist_test')); % each element squared, 1 - , sqrt'ed
