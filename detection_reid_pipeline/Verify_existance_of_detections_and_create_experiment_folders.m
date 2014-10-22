%% Verify the existence of the detections' folder
detectionsDirectory = [hdaRootDirectory '/hda_detections'];
thisDetectorDetectionsDirectory = [detectionsDirectory '/' detectorName];
if(~exist(detectionsDirectory,'dir') || ~exist(thisDetectorDetectionsDirectory,'dir'))
    error(['The directory containing the detections: "' thisDetectorDetectionsDirectory '" does not exist.' ... 
        ' 1) Have you set the ''hdaRootDirectory'' variable?' ... 
        ' 2) Have you put the detections of ''' detectorName ''' detector into the "hda_detections" folder?' ...
        ' Exiting..'])
end

%% Create experiment_data folders
allExperimentDataDirectory = [hdaRootDirectory '/hda_experiment_data'];
if ~exist(allExperimentDataDirectory,'dir'), mkdir(allExperimentDataDirectory), end,
% Create specific experiment folder
experimentDataDirectory = [allExperimentDataDirectory '/' detectorName '_' experimentVersion ];
if ~exist(experimentDataDirectory,'dir'), mkdir(experimentDataDirectory), end,
% Create test camera folders
for camId = testCameras
    cameraDirectory = [experimentDataDirectory '/camera' int2str(camId) '/'];
    if ~exist(cameraDirectory,'dir'), mkdir(cameraDirectory), end,
end

%% Write down experiment parameters in text file
writeExpermentParametersTxt(),
