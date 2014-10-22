%% Full pipe-line script
%
% This script implements the full pipe-line described in [1]. 
% 
% This script runs an example re-identification algorithm on the HDA
% dataset and displays evaluation in the form of a CMC and a
% Precision-Recall curve.  
%
% [1] D. Figueira, M. Taiana, A. Nambiar, J. Nascimento and A. Bernardino,
% "The HDA+ data set for research on fully automated re-identification
% systems.", VS-RE-ID Workshop at ECCV 2014.  
  
clearvars
declareGlobalVariables,

%% Computer specific dataset directory
% Edit the sub-script "Computer_Specific_Dataset_Directory.m", and fill in:
%   - "hdaRootDirectory" variable with the location of the 'HDA_Dataset'
% folder, 
%   -'addpath(genpath( ... ))' with the location of the hda_code folder (which
%   need not be inside the HDA_Dataset folder) 

Computer_Specific_Dataset_Directory,

%% User defined parameters
%   Open the 'setUserDefinedExperimentParameters.m' to create an experiment
% name and set the desired parameter values for that experiment (there is
% already a lot of possible combinations filled in).
%   Then fill in the 'experimentVersion' variable below with the experiment name
% that indicates the desired experiment to run.
%
%   If 'recomputeAllCachedInformation' is set to 1, all the files that are
% created during the selected 'experimentVersion' are deleted. 
% If 'recomputeAllCachedInformation' is set to 0, subsequent runnings of
% the code are very fast, since all the cached information is loaded
% instead of re-created. 
%
%   If 'offlineCrop_and_not_OnTheFlyFeatureExtraction' is set to 1, crop.m
% generates the cropped images corresponding to the detections and stores
% them in the FilteredCrops folder for the re-identification classifier to use. 
% If set to 0, no images are stored and the re-identification wrapper
% extracts the detection part of the whole frame images on-the-fly (as
% exemplified in reIdentificationWrapper.m)     

recomputeAllCachedInformation = 1;
offlineCrop_and_not_OnTheFlyFeatureExtraction = 0;
experimentVersion = '001';

setUserDefinedExperimentParameters(experimentVersion); 

%% Verify the existence of the detections and Create experiment_data folders
% and other small pre-computations
Verify_existance_of_detections_and_create_experiment_folders,

%% Pipe-line computation proper

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
GTandDetMatcher();

% Evaluates and plots a CMC curve
evaluatorCMC();

% Evaluates and plots a Precision-Recall curve
evaluatorPrecisionRecall();


return