function [dist1toPedsPIDsI, sortedDist1toPeds] = BhattacharryaNNReId(HSV,trainingDataStructure)
%BhattacharryaNNReId Nearest Neighbor classification with Bhattacharrya distance
% 
%   dist1toPedsPIDsI = BhattacharryaNNReId(HSV,trainingDataStructure)
%   
%   Receive feature vector "HSV" and structure vector "trainingDataStructure" 
%   with these fields for each training sample:
%       - camera      : camera number
%       - frame       : frame number
%       - personId    : person ground truth ID
%       - image       : cropped image
%       - mask        : cell array with four binary masks, each for a body-part [head | torso | thighs | fore-legs] 
%       - paddedImage : image padded to size of masks (2 to 1 size ratio)
%       - feature     : feature vector, output of featureExtractionHandle(paddedImage,mask)
% 
%   OUTPUTs ranked list of estimated person IDs for test sample HSV


trainSpidVector = [trainingDataStructure.personId];
unique_trainSpid = unique([trainingDataStructure.personId]);

dist1toAll = BhattDist1toAll(HSV', [trainingDataStructure.feature]');
[M,I]=min(dist1toAll);
% assert(I == 1,'The test sample should be in the last position of the dist1toAll (concatenating the training sample features with the test sample feature, with it in the end)')
assert(I == 1,'The test sample should be in the first position of the dist1toAll (concatenating the training sample features with the test sample feature, with it in the beginning)') % the code below asks for it to be n the beginiing
dist1toAll = dist1toAll(2:end);
assert(length(dist1toAll)==length(trainSpidVector),'The code below assumes dist1toAll has only the distances of the test feature to all train samples')
%dist1toAllF = BhattDist1toAll(testFeatures.F(count,:), [trainingDataStructure.F]');
% in(HSV' - testFeatures.F(count,:))

% Compute minimum of distances for each train ped (not sample)
nPed = length(unique_trainSpid);
dist1toPeds = zeros(1,nPed);
dist1toPedsPIDs = zeros(1,nPed);
for trainPed = 1:nPed
    % indTped = trainSpidVector == dsetTrain(trainPed).pid;
    indTped = trainSpidVector == unique_trainSpid(trainPed);
    if ~isempty(min(dist1toAll(indTped)))
        dist1toPeds(trainPed) = min(dist1toAll(indTped));
    else
        % Since the purging, there is no instances of this ped
        dist1toPeds(trainPed) = Inf;
    end
    
    % dist1toPedsPIDs(trainPed) = dsetTrain(trainPed).pid;
    dist1toPedsPIDs(trainPed) = unique_trainSpid(trainPed);
end

% Sort the distances to all peds, and find index of ground truth
[sortedDist1toPeds, I] = sort(dist1toPeds);
dist1toPedsPIDsI = dist1toPedsPIDs(I);

