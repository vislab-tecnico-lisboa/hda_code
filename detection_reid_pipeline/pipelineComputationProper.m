%% Pipe-line computation proper

% End game:
if ~recomputeAllCachedInformation
    reIdsAndGtDirectory    = [experimentDataDirectory sprintf('/camera%02d', testCameras) '/ReIdsAndGT_' reIdentifierName];
    if exist([reIdsAndGtDirectory '/allG.txt'],'file')
        cprintf('blue',['Camera ' int2str(testCameras) ': allG.txt already exists at ' reIdsAndGtDirectory '\n']),
        allG = GTandDetMatcher();
        return,
    end
end

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


