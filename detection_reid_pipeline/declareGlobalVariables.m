%% Declare global variables
% All these variables are experiment information variables, that are not
% supposed to be altered anywhere in the code except in
% "setUserDefinedExperimentParameters"

% variable with the location of the 'HDA_Dataset' folder
global hdaRootDirectory 

% unique experiment name/number that indicates the desired experiment to
% run and are used to name the respective experiment folder where much of
% the cached data is kept.
global experimentVersion 

% Camera sequences from where to extract the False Positives for training
% the False Positive class, and used to filter the 250 images of fully
% visible pedestrians to keep only images from the training cameras if you
% want fully visible training images 
global trainCameras 

% Camera sequences where to extract the detections, that will then be
% filtered and given to the re-identification classifier as test images
global testCameras 

% Name of the Pedestrian Detector algorithm you want to use, or of the manual annotations if you want
% Possible options:
%  'AcfInria'          : provided detector with pre-computed detections  
%  'GtAnnotationsClean': use manual annotations of only fully visible pedestrians as bounding box inputs   
%  'GtAnnotationsAll'  : use manual annotations of all pedestrians as bounding box inputs   
%  'YourOwnDetector'   : Put the detections of your own detector of choice in [hdaRootDirectory 'hda_detections/' detectorName '/camera##/Detections/'] 
global detectorName 

% The folder path where the detections of the Pedestrian Detector detections specified in "detectorName" are stored.
% thisDetectorDetectionsDirectory = [hdaRootDirectory '/hda_detections/' detectorName];
global thisDetectorDetectionsDirectory

% Filter detections by checking overlapping pairs of detections and rejecting the occluded ones as per the "geometric reasoning" described in the paper
global useMutualOverlapFilter

% Maximum overlap threshold over which occluded detections are rejected, if using the occlusion filter (useMutualOverlapFilter == 1)
global maximumOcclusionRate 

% The HDA dataset comes with a subsample of 250 manually picked cropped images (all of fully visible upright pedestrians close to the camera) one per pedestrian for every camera that he appears in (~3 to 5 images per pedestrian). Set this variable to 1 to take training images from it.
global useDefaultTrainingSetForReId 

%As described in the paper, one way to deal with false positives of an automatic pedestrian detector algorithm is training a class of false positives. Set this variable to 1 to train a false positive class with the false positive detections in the training cameras.
global useFalsePositiveClass

% If not using the default training sub-set of images, set this variable with the path where desired training images are.
% NOT CURRENTLY IN USE
global userProvidedTrainingSetDirectoryForReId

% SET "reIdentifierHandle" variable to your re-identification classifier function matlab name
% i.e.: reIdentifierHandle = @yourClassifierName;
global reIdentifierHandle

% Text equivalent of "reIdentifierHandle". Used to define the folder name of the experiment.
% reIdentifierName =  func2str(reIdentifierHandle);
global reIdentifierName 

% Set to 1 to delete all cached information of the experiment being ran. If set to 0, crop generates allC.txt, filtering generates allF.txt, re-identification generates allR.txt, mathing the re-id results with the ground truth generates allG.txt, and the precision and recall evaluation code generates a .mat file with the resulting precision/recall values per rank.
global recomputeAllCachedInformation 

% When set to 1, crop.m generates the cropped images corresponding to the detections and stores them in the FilteredCrops folder for the re-identification classifier to use. If set to 0, no images are stored and the re-identification classifier is expected to extract the detection part of the whole frame images on-the-fly (as exem+plified in randomReIdentifier.m and in BhattacharryaNNReIdentifier.m)
global offlineCrop_and_not_OnTheFlyFeatureExtraction

% Specific experiment folder
% experimentDataDirectory = [hdaRootDirectory '/hda_experiment_data/' detectorName experimentVersion ];
global experimentDataDirectory