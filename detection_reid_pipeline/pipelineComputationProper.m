%% Pipe-line computation proper

% Just to print how many active test samples per camera
% if ~exist('rabo','var')
%     rabo = [];
% end
% [ActiveTestSamples, ActiveTrainSamples, ActivePeds] = filterOccluded();
% rabo(end+1,1:3) = [ActiveTestSamples, ActiveTrainSamples, ActivePeds];

% End game:
if ~recomputeAllCachedInformation
    reIdsAndGtDirectory    = [experimentDataDirectory sprintf('/camera%02d', testCameras) '/ReIdsAndGT_' reIdentifierName];
    if exist([reIdsAndGtDirectory '/allG.txt'],'file')
        cprintf('blue',['Camera ' int2str(testCameras) ': allG.txt already exists at ' reIdsAndGtDirectory '\n']),
        allG = GTandDetMatcher();
        return,
    end
end

% if ~recomputeAllCachedInformation && exist('cameras','var')
%     filteredCropsDirectory = [experimentDataDirectory sprintf('/camera%02d',testCameras) '/FilteredCrops'];
%     if exist([filteredCropsDirectory '/allF.txt'],'file')
%         cprintf('blue',['allF.txt already exists at ' filteredCropsDirectory '\n']),
%         cprintf('blue',['some other MATLAB must be working in this camera ' int2str(testCameras) ' right now, skipping it..\n']),
%         return,
%     end
% end

if useFalsePositiveClass
    % Crops detections that don't match any Ground-Truth Bounding Box in
    % all the train cameras.
    FPClassCreator(),
end

% Crops detections from video images of test camera
crop();

% Filters out the occluded pedestrians
filterOccluded();

% Re-identification proper
reIdentificationWrapper();

% Matches the re-identified detections with the Ground Truth for evaluation
allG = GTandDetMatcher();


