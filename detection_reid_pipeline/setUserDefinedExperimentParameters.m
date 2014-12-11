function setUserDefinedExperimentParameters(experimentVersion) 
% Here we provide three sample sets of experiment parameters:
%
% 1) The default experiment (named '001') which uses the Acf pedestrian
% detector, the occlusion filter and the False Positice class. It takes
% camera 60 as the test camera, and all the others as train cameras,  
%
% 2) A sample experiment (named 'MANUALclean_cam18') using the manual
% annotations of fully visible pedestrians. Taking camera 18 as test, and
% all the others as train.  
% For the manual case, there are no False Positives, and for this case  
% there are also no occlusions.
%
% 3) Another sample experiment (named 'MANUALall_cam17'), using all manual
% annotations as input, and camera 17 as test, while all the others as
% train. For the manual case, there are no False Positives, and we choose
% to filter out the overly occluded samples. 


declareGlobalVariables,


% Default parameters
trainCameras = [17 18 19 40 50 53 54 56 57 58 59]; % Camera sequences where to crop 
                                                   % False Positives, and used to
                                                   % filter the fully visible training images
testCameras  = [60]; % Camera sequences where to crop detections, filter and compute re-identification on
detectorName = 'AcfInria';% Possible options
                          % 'AcfInria'          : provided detector with pre-computed detections  
                          % 'GtAnnotationsClean': use manual annotations of only fully visible pedestrians as bounding box inputs   
                          % 'GtAnnotationsAll'  : use manual annotations of all pedestrians as bounding box inputs   
                          % YourOwnDetector     : Put your detections in [hdaRootDirectory 'hda_detections/' detectorName '/camera##/Detections/'] 
useMutualOverlapFilter  = 1;
maximumOcclusionRate    = 0.3; % Set it to greater than 1 for disabling the Occlusion filter
useFalsePositiveClass   = 1;
trainingSetPath         = [hdaRootDirectory '/hda_sample_train_data'];
reIdentifierHandle      = @BhattacharryaNNReId; % Implemented example of NN classifier with Bhattacharrya distance.
% Other options:
%    @randomReId : determines the re-identification classifications randomly from the training class list
%    @MSCR_NN_ReId : MSCR feature nearest neighbor computation
featureExtractionHandle =  @extractHSVfromBodyParts; % Implemented example of HSV histogram extraction
% Other options:
%    @extractMSCR 

if strcmp(experimentVersion,'001')
    %use all default parameters
    display('Using default parameters')
    
% Sample experiment, using the manual annotations of fully visible
% pedestrians. Taking camera 18 as test, and all the others as train. 
% For the manual case, there are no False Positives, and for this case ('GtAnnotationsClean') 
% there are also no occlusions.
elseif strcmp(experimentVersion,'MANUALclean_cam18')
    trainCameras  = [17 19 40 50 53 54 56 57 58 59 60]; % Camera sequences where to crop detections, filter and compute re-identification on
    testCameras = [18]; 
    detectorName = 'GtAnnotationsClean';
    useFalsePositiveClass = 0;
    useMutualOverlapFilter = 0;
    reIdentifierHandle = @BhattacharryaNNReId;
    
% Sample experiment, using all manual annotations as input, and camera 17
% as test, while all the others as train. For the manual case, there are no
% False Positives, and we choose to filter out overly occluded samples.
elseif strcmp(experimentVersion,'MANUALall_cam17')
    trainCameras  = [18 19 40 50 53 54 56 57 58 59 60]; % Camera sequences where to crop detections, filter and compute re-identification on
    testCameras = [17]; 
    detectorName = 'GtAnnotationsAll';
    useFalsePositiveClass = 0;
    useMutualOverlapFilter = 1;
    reIdentifierHandle = @BhattacharryaNNReId;

% Example usage of the toy dataset with only 3 people, one training and one
% testing image each. Nearest-neighbor with HSV histograms only reaches 66% first rank in
% this dataset, but BVT (a variant of HSV) reaches 100%
elseif strcmp(experimentVersion,'Toy3_BVT')
    trainCameras  = [17 18 19 40 50 53 54 56 57 58 59]; 
    testCameras = [60]; 
    detectorName = 'Toy3';
    useFalsePositiveClass = 0;
    useMutualOverlapFilter = 0;
    reIdentifierHandle = @BhattacharryaNNReId;
    featureExtractionHandle =  @extractBVT; 
    trainingSetPath         = [hdaRootDirectory '/hda_sample_train_data_toy3'];    

% A bit tougher toy dataset with 4 people, and two training and two
% testing image each. 
elseif strcmp(experimentVersion,'Toy8_BVT')
    trainCameras  = [17 18 19 40 50 53 54 56 57 58 59]; 
    testCameras = [60]; 
    detectorName = 'Toy8';
    useFalsePositiveClass = 0;
    useMutualOverlapFilter = 0;
    reIdentifierHandle = @BhattacharryaNNReId;
    featureExtractionHandle =  @extractBVT; 
    trainingSetPath         = [hdaRootDirectory '/hda_sample_train_data_toy8'];    
        
else
    error(['Unrecognized experimentVersion: ' experimentVersion])
end

%% Error checking

userDefinedExperimentParametersErrorChecking,

