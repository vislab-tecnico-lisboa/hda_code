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
% visible pedestrians to keep only the images from the training cameras 
global trainCameras 

% Camera sequences where to extract the detections, that will then be cropped, 
% filtered and given to the re-identification classifier as test images
global testCameras 

% Name of the Pedestrian Detector algorithm you want to use, or of the manual annotations if you want
% Possible options:
%  'AcfInria'          : provided detector with pre-computed detections  
%  'GtAnnotationsClean': use manual annotations of only fully visible pedestrians as bounding box inputs   
%  'GtAnnotationsAll'  : use manual annotations of all pedestrians as bounding box inputs   
%  'YourOwnDetector'   : Put the detections of your own detector of choice
%                        in [hdaRootDirectory 'hda_detections/' detectorName '/camera##/Detections/']
%                        with the same format as the others (in an allD.txt file, with one line per detection, with format
%                        [camera frame x y w h detectorConfidence]    
global detectorName 

% The folder path where the detections of the Pedestrian Detector
% detections specified in "detectorName" are stored. 
% thisDetectorDetectionsDirectory = [hdaRootDirectory '/hda_detections/' detectorName];
global thisDetectorDetectionsDirectory

% Filter or not filter detections by checking overlapping pairs of
% detections and rejecting the occluded ones as per the "geometric
% reasoning" described in the paper  
global useMutualOverlapFilter

% Maximum overlap threshold over which occluded detections are rejected, if
% using the occlusion filter (useMutualOverlapFilter == 1) 
global maximumOcclusionRate 

%As described in the paper, one way to deal with false positives of an
%automatic pedestrian detector algorithm is training a class of false
%positives. Set this variable to 1 to train a false positive class with the
%false positive detections in the training cameras.   
global useFalsePositiveClass

% Training set path. Should contain: 
%  - one cropped image per training sample
%  - allT.txt file, with one line per sample with the format [camera frame ID occluded_bit] 
global trainingSetPath

% SET "reIdentifierHandle" variable to your re-identification classifier function matlab name
% i.e.: reIdentifierHandle = @yourClassifierName;
% It will need to conform to:
% EstimatedIDListedByRank = yourClassifierName(TestSampleFeatureVector, trainingDataStructure)
% Where 
%  - "TestSampleFeatureVector" is one test sample feature vector
%  - trainingDataStructure is a structure with all data conserning the training samples (see createTrainStructure.m for more details)
%  - EstimatedIDListedByRank is a list of numbers representing the ranked list of estimated person IDs (first rank is first)
% See BhattacharryaNNReId.m for an example.
global reIdentifierHandle

% Text equivalent of "reIdentifierHandle". Used to define the folder name of the experiment.
% reIdentifierName =  func2str(reIdentifierHandle);
global reIdentifierName 

% SET "featureExtractionHandle" to your feature extraction function. It is
% called in reIdentificationWrapper.m and createTrainStructure.m 
% It will need to conform to: 
% TestSampleFeatureVector = featureExtractionHandle(TestSampleImage, TestSampleBodyPartMasks)
% Where
%  - TestSampleImage is a cropped image, padded to the size of the body-part masks
%  - TestSampleBodyPartMasks is a cell-array, of 4 binary image masks, each a mask of one body part (head / torso / thighs / fore-legs)
%  - "TestSampleFeatureVector" is this test sample feature vector
% See extractHSVfromBodyParts.m for an example.
global featureExtractionHandle

% featureExtractionName =  func2str(featureExtractionName);
global featureExtractionName

% Set to 1 to delete all cached information of the experiment being ran. 
% "crop.m" generates allC.txt, filtering generates allF.txt,
% re-identification generates allR.txt, matching the re-id results with the
% ground truth generates allG.txt, and the precision and recall evaluation
% code generates a .mat file with the resulting precision/recall values per rank.    
global recomputeAllCachedInformation 

% When set to 1, crop.m generates the cropped images corresponding to the
% detections and stores them in the FilteredCrops folder for the
% re-identification classifier to use. If set to 0, no images are stored
% and the re-identification wrapper extracts the detection
% part of the whole frame images on-the-fly (as exemplified in
% reIdentificationWrapper.m)     
global offlineCrop_and_not_OnTheFlyFeatureExtraction

% Specific experiment folder
% experimentDataDirectory = [hdaRootDirectory '/hda_experiment_data/' detectorName '_' experimentVersion ];
global experimentDataDirectory

% Filter out test samples of a same pedestrian with bounding boxes in the
% same position and with the same size
global filterOutRepeatedTestSamples,

% Set feature extraction method from the following choices:
%  - 4parts (default method)
%  - 2parts (automatic waist detection to divide full mask in two)
%  - fullbody (merge the 4 parts into one full body mask)
%  - 6rectangles (6 fixed horizontal stripes)
global featureExtractionMethod,

global waitbarverbose,

% Option to signal reIdentifierWrapper.m to create a structure with all
% test samples 'testDataStructure' and give it to the classifier, instead
% of givibg it only a test single sample at a time
global classifierNeedsAllTestData,



