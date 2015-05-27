function allTestDataStructure = createTestStructure(testCamera,loadImages)
%createTrainStructure  Creates structure with training data.
%   function trainingDataStructure = createTrainStructure(loadImages)
% 
%   Creates a structure array, with one structure per training sample, with
%   all the information pertinent to the training data with these fields:
%       - camera      : camera number
%       - frame       : frame number
%       - personId    : person ground truth ID
%       and if loadImages is equal to 1
%       - image       : cropped image
%       - mask        : cell array with four binary masks, each for a body-part [head | torso | thighs | fore-legs] 
%       - paddedImage : image padded to size of masks (2 to 1 size ratio)
%       - feature     : feature vector, output of featureExtractionHandle(paddedImage,mask)
% 
%   Loads data from folder defined in global var "trainingSetPath", which should contain: 
%       - one cropped image per training sample
%       - allT.txt file, with one line per sample with the format [camera frame personID occluded_bit] 
%       - pmskset4_128x64.mat: body-part mask file 


    declareGlobalVariables,
    if ~exist('loadImages','var')
        loadImages = 1;
    end

    
    localDetectionsDirectory = [thisDetectorDetectionsDirectory '/camera' num2str(testCamera,'%02d') '/Detections'];
    DetMat=dlmread([localDetectionsDirectory '/allD.txt']);
    
    filteredCropsDirectory = [experimentDataDirectory sprintf('/camera%02d',testCamera) '/FilteredCrops'];
    filteredCropsMat = dlmread([filteredCropsDirectory '/allF.txt']);
    nFiles=size(filteredCropsMat,1);    

    % Loading pre-computed body-part masks
    bodypartmaksksDirectory      = [thisDetectorDetectionsDirectory sprintf('/camera%02d',testCamera) '/Detections'];
%     masks = load([bodypartmaksksDirectory '/pmskset4_128x64.mat']);
%     masks = masks.pmskset;
%     if size(masks,1) ~= nFiles
%         error(['Number of masks (' int2str(size(masks,1)) ') not equal to number of filtered crops (' int2str(nDetections) '). Maybe they were computed with crowd detections?'])
%     end
    masks = load_pre_computed_body_part_masks(bodypartmaksksDirectory,nFiles);
    
    allTestDataStructure_path = [localDetectionsDirectory '/allTestDataStructure_' featureExtractionName '_' featureExtractionMethod '.mat'];
    % Backwards compatibility
    if strcmp(featureExtractionMethod,'4parts')
        allTestDataStructure_path_old = [localDetectionsDirectory '/allTestDataStructure_' featureExtractionName '.mat'];
        if ~exist(allTestDataStructure_path,'file') && exist(allTestDataStructure_path_old,'file')
            copyfile(allTestDataStructure_path_old,allTestDataStructure_path)
            warning(['BACKWARDS COMPATIBILITY: Copied original allTestDataStructure to ' allTestDataStructure_path])
        end
    end

    if recomputeAllCachedInformation && loadImages
        warning('off','MATLAB:DELETE:FileNotFound')
        delete(allTestDataStructure_path),
        warning('on','MATLAB:DELETE:FileNotFound')
    end
    if loadImages && exist(allTestDataStructure_path,'file')
        load(allTestDataStructure_path),
        cprintf('*blue',['Loaded allTestDataStructure from ' allTestDataStructure_path '\n'])
        assert(isfield(allTestDataStructure, 'camera'))
        assert(isfield(allTestDataStructure, 'frame'))
        assert(isfield(allTestDataStructure, 'bb'))
        %assert(isfield(allTestDataStructure, 'image'),'SEEMS like the cached allTraining file was saved without the images :P...')
        %assert(isfield(allTestDataStructure, 'mask'))
        assert(isfield(allTestDataStructure, 'feature'),'SEEMS like the cached allTraining file was saved without the images :P...')
    else
        if waitbarverbose
            dividerWaitbar=10^(floor(log10(size(DetMat,1)))-1); % Limiting the access to waitbar
            wbr = waitbar(0, ['Loading test data, image 0/' int2str(size(DetMat,1))]);
        end
        for i=1:size(DetMat,1)
            if waitbarverbose
                if loadImages
                    % Loading images and computing features takes long enough
                    % that you don't need to limit access to waitbar
                    waitbar(i/size(DetMat,1), wbr, ['Loading test data, image ' int2str(i) '/' int2str(size(DetMat,1))]);
                else
                    if (round(i/dividerWaitbar)==i/dividerWaitbar) % Limiting the access to waitbar
                        waitbar(i/size(DetMat,1), wbr, ['Loading test data, image ' int2str(i) '/' int2str(size(DetMat,1))]);
                    end
                end
            end
            % trainSample = load([trainingSetPath '/' nameList(i).name]);
            testSample = DetMat(i,:);
            allTestDataStructure(i).camera      = testSample(1);
            allTestDataStructure(i).frame       = testSample(2);
            allTestDataStructure(i).bb          = testSample(3:6);
            % trainingDataStructure(i).fullyVisible= trainSample(4); % not useful
            if loadImages                
                % allTestDataStructure(i).mask       = masks(i,:);
                if ~offlineCrop_and_not_OnTheFlyFeatureExtraction
                    subImage = getFrameAndCrop(allTestDataStructure(i).camera, allTestDataStructure(i).frame, allTestDataStructure(i).bb);
                else % if cropped offline
                    subImage = imread([filteredCropsDirectory sprintf('/F%06d.png',i)]);
                end
                paddedImage = smartPadImageToBodyPartMaskSize(subImage);            
                feature = featureExtractionHandle(paddedImage,masks(i,:));
                allTestDataStructure(i).feature         = feature;
            end
            
        end
        if waitbarverbose
            close(wbr);
        end
        
        if loadImages % time saving measure
            save(allTestDataStructure_path,'allTestDataStructure'),
            cprintf('*[1,0,1]',['Saved allTestDataStructure to ' allTestDataStructure_path '\n'])
        end

    end
        
    
return    
