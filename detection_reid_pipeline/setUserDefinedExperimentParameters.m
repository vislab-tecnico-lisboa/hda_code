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
%    @SDALF_ReId : SDALF's nearest neighbor combination of MSCR, EpiTexture and weighted HSV histogram 
%    @MultiViewold_BVT_HSV_Lab_MR8_LBP : MutliView classifier that combines those 5 features 

featureExtractionHandle =  @extractHSVfromBodyParts; % Implemented example of HSV histogram extraction
% Other options:
%    @extractMSCR 
%    @extractBVT - a variant of HSV (2D H and S histogram, 1D V histogram, and 1 bin for the near-black pixels) 
%    @extractLab
%    @extractLBP
%    @extractMR8
%    @extractSDALF
%    @extractBVT_HSV_Lab_MR8_LBP - to be used with MultiView classifier (extracts the 5 features and puts them in a structure) 

% Feature extraction method, default '4parts', that uses Pictorial
% Structures to detect 6 body parts [head | torso | thigh | shin | shin | foreleg]
% and joints together the shins in one area, and the thighs in one area:
% [head | torso | thighs | shins]
featureExtractionMethod = '4parts';
% Other options:
%    'fullbody' - joining into one masks all the body-part masks
%    '2parts'   - does a search in the fullmask for the point that
%               maximizes the bhattacharyya distance between the upper and lower color
%               histogram (BVT feature), and divide the fullbody mask in two at that point.   
%    '6parts'


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

% Set trainCameras and testCameras to [] to run 12 experiments and
% display an average CMC for all samples in all experiments. Each
% experiment with one camera as test and all the others as train. 
% (Note that what is displayed is not an CMC that is the average of 12
% CMCs, but an CMC computed from the sum of all the re-identifications for
% all samples in all 12 experiments)
elseif strcmp(experimentVersion,'MANUALclean_allcam_HSV_2parts')
    trainCameras  = [];
    testCameras = []; 
    detectorName = 'GtAnnotationsClean';
    useFalsePositiveClass = 0;
    useMutualOverlapFilter = 0;
    featureExtractionMethod = '2parts';
    
    
else
    error(['Unrecognized experimentVersion: ' experimentVersion])
end

%% Error checking

userDefinedExperimentParametersErrorChecking,

