function setUserDefinedExperimentParameters(experimentVersion) 
% function [trainCameras, testCameras, detectorName, ...
%     useMutualOverlapFilter, maximumOcclusionRate, useDefaultTrainingSetForReId, useFalsePositiveClass, userProvidedTrainingSetDirectoryForReId, ...
%     reIdentifierName, reIdentifierHandle] = setUserDefinedExperimentParameters(experimentVersion) 
% User defined parameters, may be different for each experiment

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
useMutualOverlapFilter= 1;
maximumOcclusionRate = 0.3; % Set it to greater than 1 for disabling the Occlusion filter
useFalsePositiveClass = 1;
useDefaultTrainingSetForReId = 1;
userProvidedTrainingSetDirectoryForReId = '';
reIdentifierHandle = @BhattacharryaNNReIdentifier; % Implemented example of NN classifier with Bhattacharrya distance.
% Other options:
% 	@randomReIdentifier : determines the re-identification classifications randomly from the training class list

 

if strcmp(experimentVersion,'001')
    %use all default parameters
    display('Using default parameters')
    
elseif strcmp(experimentVersion,'test')
    trainCameras = [53]
    testCameras = [50]    
    useFalsePositiveClass = 0;

elseif strcmp(experimentVersion,'MANUALcleanAllTestCameras')
    trainCameras  = []; % Camera sequences where to crop detections, filter and compute re-identification on
    testCameras = [17 18 19 40 50 53 54 56 57 58 59 60]; 
    detectorName = 'GtAnnotationsClean';
    useFalsePositiveClass = 0;
    useMutualOverlapFilter = 0;

elseif strcmp(experimentVersion,'MANUALall_cam17')
    trainCameras  = [18 19 40 50 53 54 56 57 58 59 60]; % Camera sequences where to crop detections, filter and compute re-identification on
    testCameras = [17]; 
    detectorName = 'GtAnnotationsAll';
    useFalsePositiveClass = 0;
    useMutualOverlapFilter = 0;
    reIdentifierHandle = @BhattacharryaNNReIdentifier;

elseif strcmp(experimentVersion,'MANUALall_cam18')
    trainCameras  = [17 19 40 50 53 54 56 57 58 59 60]; % Camera sequences where to crop detections, filter and compute re-identification on
    testCameras = [18]; 
    detectorName = 'GtAnnotationsAll';
    useFalsePositiveClass = 0;
    useMutualOverlapFilter = 0;
    reIdentifierHandle = @BhattacharryaNNReIdentifier;

elseif strcmp(experimentVersion,'MANUALall_cam19')
    trainCameras  = [17 18 40 50 53 54 56 57 58 59 60]; % Camera sequences where to crop detections, filter and compute re-identification on
    testCameras = [19]; 
    detectorName = 'GtAnnotationsAll';
    useFalsePositiveClass = 0;
    useMutualOverlapFilter = 0;
    reIdentifierHandle = @BhattacharryaNNReIdentifier;

elseif strcmp(experimentVersion,'MANUALall_cam40')
    trainCameras  = [17 18 19 50 53 54 56 57 58 59 60]; % Camera sequences where to crop detections, filter and compute re-identification on
    testCameras = [40]; 
    detectorName = 'GtAnnotationsAll';
    useFalsePositiveClass = 0;
    useMutualOverlapFilter = 0;
    reIdentifierHandle = @BhattacharryaNNReIdentifier;

elseif strcmp(experimentVersion,'MANUALall_cam50')
    trainCameras  = [17 18 19 40 53 54 56 57 58 59 60]; % Camera sequences where to crop detections, filter and compute re-identification on
    testCameras = [50]; 
    detectorName = 'GtAnnotationsAll';
    useFalsePositiveClass = 0;
    useMutualOverlapFilter = 0;
    reIdentifierHandle = @BhattacharryaNNReIdentifier;

elseif strcmp(experimentVersion,'MANUALall_cam53')
    trainCameras  = [17 18 19 40 50 54 56 57 58 59 60]; % Camera sequences where to crop detections, filter and compute re-identification on
    testCameras = [53]; 
    detectorName = 'GtAnnotationsAll';
    useFalsePositiveClass = 0;
    useMutualOverlapFilter = 0;
    reIdentifierHandle = @BhattacharryaNNReIdentifier;

elseif strcmp(experimentVersion,'MANUALall_cam54')
    trainCameras  = [17 18 19 40 50 53 56 57 58 59 60]; % Camera sequences where to crop detections, filter and compute re-identification on
    testCameras = [54]; 
    detectorName = 'GtAnnotationsAll';
    useFalsePositiveClass = 0;
    useMutualOverlapFilter = 0;
    reIdentifierHandle = @BhattacharryaNNReIdentifier;

elseif strcmp(experimentVersion,'MANUALall_cam56')
    trainCameras  = [17 18 19 40 50 53 54 57 58 59 60]; % Camera sequences where to crop detections, filter and compute re-identification on
    testCameras = [56]; 
    detectorName = 'GtAnnotationsAll';
    useFalsePositiveClass = 0;
    useMutualOverlapFilter = 0;
    reIdentifierHandle = @BhattacharryaNNReIdentifier;

elseif strcmp(experimentVersion,'MANUALall_cam57')
    trainCameras  = [17 18 19 40 50 53 54 56 58 59 60]; % Camera sequences where to crop detections, filter and compute re-identification on
    testCameras = [57]; 
    detectorName = 'GtAnnotationsAll';
    useFalsePositiveClass = 0;
    useMutualOverlapFilter = 0;
    reIdentifierHandle = @BhattacharryaNNReIdentifier;

elseif strcmp(experimentVersion,'MANUALall_cam58')
    trainCameras  = [17 18 19 40 50 53 54 56 57 59 60]; % Camera sequences where to crop detections, filter and compute re-identification on
    testCameras = [58]; 
    detectorName = 'GtAnnotationsAll';
    useFalsePositiveClass = 0;
    useMutualOverlapFilter = 0;
    reIdentifierHandle = @BhattacharryaNNReIdentifier;

elseif strcmp(experimentVersion,'MANUALall_cam59')
    trainCameras  = [17 18 19 40 50 53 54 56 57 58 60]; % Camera sequences where to crop detections, filter and compute re-identification on
    testCameras = [59]; 
    detectorName = 'GtAnnotationsAll';
    useFalsePositiveClass = 0;
    useMutualOverlapFilter = 0;
    reIdentifierHandle = @BhattacharryaNNReIdentifier;

elseif strcmp(experimentVersion,'MANUALclean_cam17')
    trainCameras  = [18 19 40 50 53 54 56 57 58 59 60]; % Camera sequences where to crop detections, filter and compute re-identification on
    testCameras = [17]; 
    detectorName = 'GtAnnotationsClean';
    useFalsePositiveClass = 0;
    useMutualOverlapFilter = 0;
    reIdentifierHandle = @BhattacharryaNNReIdentifier;

elseif strcmp(experimentVersion,'MANUALclean_cam18')
    trainCameras  = [17 19 40 50 53 54 56 57 58 59 60]; % Camera sequences where to crop detections, filter and compute re-identification on
    testCameras = [18]; 
    detectorName = 'GtAnnotationsClean';
    useFalsePositiveClass = 0;
    useMutualOverlapFilter = 0;
    reIdentifierHandle = @BhattacharryaNNReIdentifier;

elseif strcmp(experimentVersion,'MANUALclean_cam19')
    trainCameras  = [17 18 40 50 53 54 56 57 58 59 60]; % Camera sequences where to crop detections, filter and compute re-identification on
    testCameras = [19]; 
    detectorName = 'GtAnnotationsClean';
    useFalsePositiveClass = 0;
    useMutualOverlapFilter = 0;
    reIdentifierHandle = @BhattacharryaNNReIdentifier;

elseif strcmp(experimentVersion,'MANUALclean_cam40')
    trainCameras  = [17 18 19 50 53 54 56 57 58 59 60]; % Camera sequences where to crop detections, filter and compute re-identification on
    testCameras = [40]; 
    detectorName = 'GtAnnotationsClean';
    useFalsePositiveClass = 0;
    useMutualOverlapFilter = 0;
    reIdentifierHandle = @BhattacharryaNNReIdentifier;

elseif strcmp(experimentVersion,'MANUALclean_cam50')
    trainCameras  = [17 18 19 40 53 54 56 57 58 59 60]; % Camera sequences where to crop detections, filter and compute re-identification on
    testCameras = [50]; 
    detectorName = 'GtAnnotationsClean';
    useFalsePositiveClass = 0;
    useMutualOverlapFilter = 0;
    reIdentifierHandle = @BhattacharryaNNReIdentifier;

elseif strcmp(experimentVersion,'MANUALclean_cam53')
    trainCameras  = [17 18 19 40 50 54 56 57 58 59 60]; % Camera sequences where to crop detections, filter and compute re-identification on
    testCameras = [53]; 
    detectorName = 'GtAnnotationsClean';
    useFalsePositiveClass = 0;
    useMutualOverlapFilter = 0;
    reIdentifierHandle = @BhattacharryaNNReIdentifier;

elseif strcmp(experimentVersion,'MANUALclean_cam54')
    trainCameras  = [17 18 19 40 50 53 56 57 58 59 60]; % Camera sequences where to crop detections, filter and compute re-identification on
    testCameras = [54]; 
    detectorName = 'GtAnnotationsClean';
    useFalsePositiveClass = 0;
    useMutualOverlapFilter = 0;
    reIdentifierHandle = @BhattacharryaNNReIdentifier;

elseif strcmp(experimentVersion,'MANUALclean_cam56')
    trainCameras  = [17 18 19 40 50 53 54 57 58 59 60]; % Camera sequences where to crop detections, filter and compute re-identification on
    testCameras = [56]; 
    detectorName = 'GtAnnotationsClean';
    useFalsePositiveClass = 0;
    useMutualOverlapFilter = 0;
    reIdentifierHandle = @BhattacharryaNNReIdentifier;

elseif strcmp(experimentVersion,'MANUALclean_cam57')
    trainCameras  = [17 18 19 40 50 53 54 56 58 59 60]; % Camera sequences where to crop detections, filter and compute re-identification on
    testCameras = [57]; 
    detectorName = 'GtAnnotationsClean';
    useFalsePositiveClass = 0;
    useMutualOverlapFilter = 0;
    reIdentifierHandle = @BhattacharryaNNReIdentifier;

elseif strcmp(experimentVersion,'MANUALclean_cam58')
    trainCameras  = [17 18 19 40 50 53 54 56 57 59 60]; % Camera sequences where to crop detections, filter and compute re-identification on
    testCameras = [58]; 
    detectorName = 'GtAnnotationsClean';
    useFalsePositiveClass = 0;
    useMutualOverlapFilter = 0;
    reIdentifierHandle = @BhattacharryaNNReIdentifier;

elseif strcmp(experimentVersion,'MANUALclean_cam59')
    trainCameras  = [17 18 19 40 50 53 54 56 57 58 60]; % Camera sequences where to crop detections, filter and compute re-identification on
    testCameras = [59]; 
    detectorName = 'GtAnnotationsClean';
    useFalsePositiveClass = 0;
    useMutualOverlapFilter = 0;
    reIdentifierHandle = @BhattacharryaNNReIdentifier;

elseif strcmp(experimentVersion,'FPoffOCCoff_cam17')
    trainCameras  = [18 19 40 50 53 54 56 57 58 59 60]; % Camera sequences where to crop detections, filter and compute re-identification on
    testCameras = [17]; 
    useFalsePositiveClass = 0;
    useMutualOverlapFilter = 0;
    reIdentifierHandle = @BhattacharryaNNReIdentifier;
elseif strcmp(experimentVersion,'FPoffOCCoff_cam18')
    trainCameras  = [17 19 40 50 53 54 56 57 58 59 60]; % Camera sequences where to crop detections, filter and compute re-identification on
    testCameras = [18]; 
    useFalsePositiveClass = 0;
    useMutualOverlapFilter = 0;
    reIdentifierHandle = @BhattacharryaNNReIdentifier;
elseif strcmp(experimentVersion,'FPoffOCCoff_cam19')
    trainCameras  = [17 18 40 50 53 54 56 57 58 59 60]; % Camera sequences where to crop detections, filter and compute re-identification on
    testCameras = [19]; 
    useFalsePositiveClass = 0;
    useMutualOverlapFilter = 0;
    reIdentifierHandle = @BhattacharryaNNReIdentifier;
elseif strcmp(experimentVersion,'FPoffOCCoff_cam40')
    trainCameras  = [17 18 19 50 53 54 56 57 58 59 60]; % Camera sequences where to crop detections, filter and compute re-identification on
    testCameras = [40]; 
    useFalsePositiveClass = 0;
    useMutualOverlapFilter = 0;
    reIdentifierHandle = @BhattacharryaNNReIdentifier;
elseif strcmp(experimentVersion,'FPoffOCCoff_cam50')
    trainCameras  = [17 18 19 40 53 54 56 57 58 59 60]; % Camera sequences where to crop detections, filter and compute re-identification on
    testCameras = [50]; 
    useFalsePositiveClass = 0;
    useMutualOverlapFilter = 0;
    reIdentifierHandle = @BhattacharryaNNReIdentifier;
elseif strcmp(experimentVersion,'FPoffOCCoff_cam53')
    trainCameras  = [17 18 19 40 50 54 56 57 58 59 60]; % Camera sequences where to crop detections, filter and compute re-identification on
    testCameras = [53]; 
    useFalsePositiveClass = 0;
    useMutualOverlapFilter = 0;
    reIdentifierHandle = @BhattacharryaNNReIdentifier;
elseif strcmp(experimentVersion,'FPoffOCCoff_cam54')
    trainCameras  = [17 18 19 40 50 53 56 57 58 59 60]; % Camera sequences where to crop detections, filter and compute re-identification on
    testCameras = [54]; 
    useFalsePositiveClass = 0;
    useMutualOverlapFilter = 0;
    reIdentifierHandle = @BhattacharryaNNReIdentifier;
elseif strcmp(experimentVersion,'FPoffOCCoff_cam56')
    trainCameras  = [17 18 19 40 50 53 54 57 58 59 60]; % Camera sequences where to crop detections, filter and compute re-identification on
    testCameras = [56]; 
    useFalsePositiveClass = 0;
    useMutualOverlapFilter = 0;
    reIdentifierHandle = @BhattacharryaNNReIdentifier;
    
elseif strcmp(experimentVersion,'002')
    detectorName = 'GtAnnotationsAll';

elseif strcmp(experimentVersion,'003')
    detectorName = 'GtAnnotationsClean';

elseif strcmp(experimentVersion,'004')
    trainCameras = [17 18 19 40 50 53 54 56 57 58 59];

elseif strcmp(experimentVersion,'AllTrainCameras')
    trainCameras = [17 18 19 40 50 53 54 56 57 58 59 60]; 
    testCameras  = []; % Camera sequences where to crop detections, filter and compute re-identification on

elseif strcmp(experimentVersion,'005')
    trainCameras = [50 53 54 56 57 58 59];
    testCameras  = [60];
    detectorName = 'GtAnnotationsClean';
    useMutualOverlapFilter = 0;
    useDefaultTrainingSetForReId = 1;
    reIdentifierHandle = @myReIdentifier;

elseif strcmp(experimentVersion,'006')
    trainCameras = [50 53 54 56 57 58 59];
    testCameras  = [60];
    detectorName = 'MyDetector';
    useMutualOverlapFilter = 1;
    maximumOcclusionRate = 0.3;
    useDefaultTrainingSetForReId = 1;
    reIdentifierHandle = @myReIdentifier;

elseif strcmp(experimentVersion,'MANUALclean')
    detectorName = 'GtAnnotationsClean';
    useFalsePositiveClass = 0;
    useMutualOverlapFilter = 0;
    maximumOcclusionRate = 99;
    reIdentifierHandle = @BhattacharryaNNReIdentifier;
elseif strcmp(experimentVersion,'MANUALall')
    detectorName = 'GtAnnotationsAll';
    useFalsePositiveClass = 0;
    useMutualOverlapFilter = 0;
    maximumOcclusionRate = 99;
    reIdentifierHandle = @BhattacharryaNNReIdentifier;
elseif strcmp(experimentVersion,'FPoffOCCoff')
    useFalsePositiveClass = 0;
    useMutualOverlapFilter = 0;
    maximumOcclusionRate = 99;
    reIdentifierHandle = @BhattacharryaNNReIdentifier;
elseif strcmp(experimentVersion,'FPoffOCCon')
    useFalsePositiveClass = 0;
    useMutualOverlapFilter = 1;
    maximumOcclusionRate = 0.3;
    reIdentifierHandle = @BhattacharryaNNReIdentifier;
elseif strcmp(experimentVersion,'FPonOCCoff')
    useFalsePositiveClass = 1;
    useMutualOverlapFilter = 0;
    maximumOcclusionRate = 99;
    reIdentifierHandle = @BhattacharryaNNReIdentifier;
elseif strcmp(experimentVersion,'FPonOCCon')
    useFalsePositiveClass = 1;
    useMutualOverlapFilter = 1;
    maximumOcclusionRate = 0.3;
    reIdentifierHandle = @BhattacharryaNNReIdentifier;

elseif strcmp(experimentVersion,'FPonOCCon_cam59')
    useFalsePositiveClass = 1;
    useMutualOverlapFilter = 1;
    maximumOcclusionRate = 0.3;
    reIdentifierHandle = @BhattacharryaNNReIdentifier;    
    trainCameras = [17 18 19 40 50 53 54 56 57 58 60];
    testCameras  = [59]; % Camera sequences where to crop detections, 
    
elseif strcmp(experimentVersion,'FPoffOCCoff_17to59TrainCameras')
    trainCameras = [17 18 19 40 50 53 54 56 57 58 59]; % Not used yet
    useFalsePositiveClass = 0;
    useMutualOverlapFilter = 0;
    maximumOcclusionRate = 99;
    reIdentifierHandle = @BhattacharryaNNReIdentifier;
elseif strcmp(experimentVersion,'FPoffOCCon_17to59TrainCameras')
    trainCameras = [17 18 19 40 50 53 54 56 57 58 59]; % Not used yet
    useFalsePositiveClass = 0;
    useMutualOverlapFilter = 1;
    maximumOcclusionRate = 0.3;
    reIdentifierHandle = @BhattacharryaNNReIdentifier;
elseif strcmp(experimentVersion,'FPonOCCoff_17to59TrainCameras')
    trainCameras = [17 18 19 40 50 53 54 56 57 58 59]; % Not used yet
    useFalsePositiveClass = 1;
    useMutualOverlapFilter = 0;
    maximumOcclusionRate = 99;
    reIdentifierHandle = @BhattacharryaNNReIdentifier;
elseif strcmp(experimentVersion,'FPonOCCon_17to59TrainCameras')
    trainCameras = [17 18 19 40 50 53 54 56 57 58 59]; % Not used yet
    useFalsePositiveClass = 1;
    useMutualOverlapFilter = 1;
    maximumOcclusionRate = 0.3;
    reIdentifierHandle = @BhattacharryaNNReIdentifier;

elseif strcmp(experimentVersion,'FPonOCCoff_hack')
    useFalsePositiveClass = 1;
    useMutualOverlapFilter = 0;
    maximumOcclusionRate = 99;
    reIdentifierHandle = @BhattacharryaNNReIdentifier;
elseif strcmp(experimentVersion,'FPonOCCon_hack')
    useFalsePositiveClass = 1;
    useMutualOverlapFilter = 1;
    maximumOcclusionRate = 0.3;
    reIdentifierHandle = @BhattacharryaNNReIdentifier;

else
    error(['Unrecognized experimentVersion: ' experimentVersion])
end

reIdentifierName =  func2str(reIdentifierHandle);
