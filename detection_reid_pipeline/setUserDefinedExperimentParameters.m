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
% 	@randomReId : determines the re-identification classifications randomly from the training class list
featureExtractionHandle =  @extractHSVfromBodyParts; % Implemented example of HSV histogram extraction
 

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

else
    error(['Unrecognized experimentVersion: ' experimentVersion])
end

reIdentifierName =  func2str(reIdentifierHandle);
featureExtractionName = func2str(featureExtractionHandle);

%% Error checking

% There are no False Positives if the "detector" is the manual annotations,
% so if set to 1, resetting it to 0
if strcmp(detectorName, 'GtAnnotationsClean') || strcmp(detectorName, 'GtAnnotationsAll')
    if useFalsePositiveClass
        warning(['setUserDefinedExperimentParameters: There are no False Positives in the ' detectorName ' annotations. Setting useFalsePositiveClass to 0.'])
        useFalsePositiveClass = 0;
    end
end

% Check if train and test set are non-overlapping
if ~isempty(intersect(trainCameras,testCameras))
    warning(['Training set and testing set cameras overlap, are you sure you want to do this?' ...
        ' (cameras ' int2str(intersect(trainCameras,testCameras)) ')'])
end
