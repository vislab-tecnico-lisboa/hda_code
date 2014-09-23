%% Full pipe-line script
%
% This script implements the full pipe-line described in [1], First a set
% of detections are processed to crop each detection from the respective
% video images, producing cropped images and detection files containing .
%
%
% [1] Matteo Taiana, Dario Figueira, Athira Nambiar, Jacinto Nascimento,
% Alexandre Bernardino, "Towards Fully Automated Person Re-Identification",
% at VISAPP 2014  

clearvars
declareGlobalVariables,

%% Computer specific dataset directory
%   Edit below and fill in the "hdaRootDirectory" variable with the location
% of the 'HDA_Dataset' folder, and fill in the 'addpath(genpath( ))' with
% the location of the hda_code folder (which you may place outside the
% HDA_Dataset folder if you wish to place only it inside a dropbox folder, e.g.)

% Code for allowing several computers to run the same script
[~,systemName] = system('hostname');
if strcmp(systemName(1:end-1),'Dario-Laptop')
    hdaRootDirectory ='C:/Users/Dario/Desktop/WorkNoSync/HDA_Dataset';
    addpath(genpath('C:/Users/Dario/Dropbox/Work/hda_code'));
    
elseif strcmp(systemName(1:end-1),'vislab7')
    hdaRootDirectory ='/home/dario/Desktop/WorkNoSync/HDA_Dataset';
    addpath(genpath('/home/dario/Desktop/Dropbox/Work/hda_code'));
        
elseif strcmp(systemName(1:end-1),'NetVis-PC') % Asus Eee PC do Vislab
    hdaRootDirectory ='C:/Users/Dario/Dropbox/Work/HDA_Dataset';
    addpath(genpath('C:/Users/Dario/Dropbox/Work/hda_code'));
        
elseif strcmp(systemName(1:end-1),'rocoto')
    hdaRootDirectory ='~/PhD/MyCode/ReId/HdaRoot';
    addpath(genpath(['~/PhD/MyCode/ReId/Svn/']));
end

% hdaRootDirectory = ...;
% addpath(genpath( ... ));

%% User defined parameters
%   Open the 'setUserDefinedExperimentParameters.m' to create an experiment
% name and set the desired parameter values for that experiment (there is
% already a lot of possible combinations filled in).
%   Then fill in the 'experimentVersion' variable with the experiment name
% that indicates the desired experiment to run.
%   If 'recomputeAllCachedInformation' is set to 1, all the files that are
% created during the selected 'experimentVersion' are deleted when runnin
% the respective parts of the code. If 'recomputeAllCachedInformation' is
% set to 0, subsequent runnings of the code are very fast, since all the
% cached information is loaded instead of re-created.

recomputeAllCachedInformation = 0;
offlineCrop_and_not_OnTheFlyFeatureExtraction = 1;
experimentVersion = 'FPoffOCCoff_cam56';
setUserDefinedExperimentParameters(experimentVersion); 

if ~isempty(intersect(trainCameras,testCameras))
    warning(['Training set and testing set cameras overlap, are you sure you want to do this?' ...
        ' (cameras ' int2str(intersect(trainCameras,testCameras)) ')'])
end

%% Verify the existence of the detections
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
experimentDataDirectory = [allExperimentDataDirectory '/' detectorName experimentVersion ];
if ~exist(experimentDataDirectory,'dir'), mkdir(experimentDataDirectory), end,
% Create test camera folders
for camId = testCameras
    cameraDirectory = [experimentDataDirectory '/camera' int2str(camId) '/'];
    if ~exist(cameraDirectory,'dir'), mkdir(cameraDirectory), end,
end
% Write down experiment parameters in text file
writeExpermentParametersTxt(),

%% Pipe-line computation proper

% If you wish to ignore detections that would be associated to the 'crowd'
% annotation, then uncomment the following line.
% createallDetections_plusGT_and_NoCrowds(testCameras, hdaRootDirectory, thisDetectorDetectionsDirectory, recomputeAllCachedInformation),

if useFalsePositiveClass
    FPClassCreator(trainCameras, hdaRootDirectory, thisDetectorDetectionsDirectory, experimentDataDirectory, recomputeAllCachedInformation, offlineCrop_and_not_OnTheFlyFeatureExtraction)
end

% Crops detections from video images of test camera
crop();

filterOccluded();

reIdentifierHandle();

gtAndDetMatcher();

evaluatorCMC();

evaluatorPrecisionRecall();


return