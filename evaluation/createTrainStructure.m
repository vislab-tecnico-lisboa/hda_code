function trainingDataStructure = createTrainStructure(loadImages)
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
            
    nameList = dir([trainingSetPath '/*.png']);
    % Loading pre-computed body-part masks
    masks = load([trainingSetPath '/pmskset4_128x64.mat']);
    masks = masks.pmskset;
    if size(masks,1) ~= size(nameList,1)
        error(['Number of masks (' int2str(size(masks,1)) ') not equal to number of training crops (' int2str(size(nameList,1)) ').'])
    end
        
    TrainMat=dlmread([trainingSetPath '/allT.txt']);
    cprintf('*blue',['Loaded allT.txt from ' trainingSetPath '\n'])
    
    allTrainingDataStructure_path = [trainingSetPath '/allTrainingDataStructure_' featureExtractionName '.mat'];
    if recomputeAllCachedInformation && loadImages
        warning('off','MATLAB:DELETE:FileNotFound')
        delete(allTrainingDataStructure_path),
        warning('on','MATLAB:DELETE:FileNotFound')
    end
    if loadImages && exist(allTrainingDataStructure_path,'file')
        load(allTrainingDataStructure_path),
        cprintf('*blue',['Loaded allTtrainingDataStructure from ' allTrainingDataStructure_path '\n'])
        assert(isfield(allTrainingDataStructure, 'camera'))
        assert(isfield(allTrainingDataStructure, 'frame'))
        assert(isfield(allTrainingDataStructure, 'personId'))
        assert(isfield(allTrainingDataStructure, 'image'),'SEEMS like the cached allTraining file was saved without the images :P...')
        assert(isfield(allTrainingDataStructure, 'mask'))
        assert(isfield(allTrainingDataStructure, 'feature'))
   else
        
        dividerWaitbar=10^(floor(log10(size(TrainMat,1)))-1); % Limiting the access to waitbar
        wbr = waitbar(0, ['Loading training data, image 0/' int2str(size(TrainMat,1))]);
        for i=1:size(TrainMat,1)
            if (round(i/dividerWaitbar)==i/dividerWaitbar) % Limiting the access to waitbar
                waitbar(i/size(TrainMat,1), wbr, ['Loading training data, image ' int2str(i) '/' int2str(size(TrainMat,1))]);
            end
            % trainSample = load([trainingSetPath '/' nameList(i).name]);
            trainSample = TrainMat(i,:);
            allTrainingDataStructure(i).camera      = trainSample(1);
            allTrainingDataStructure(i).frame       = trainSample(2);
            allTrainingDataStructure(i).personId    = trainSample(3);
            % trainingDataStructure(i).fullyVisible= trainSample(4); % not useful
            if loadImages
                allTrainingDataStructure(i).image       = imread([trainingSetPath '/' nameList(i).name]);
                assert( i==sscanf(nameList(i).name,'T%06d.png') , 'Bitch.. ''dir'' is not returning an ordered list of files..')
                
                allTrainingDataStructure(i).mask       = masks(i,:);
                % imshow(trainSampleImage)
                paddedImage = smartPadImageToBodyPartMaskSize(allTrainingDataStructure(i).image);
                feature = featureExtractionHandle(paddedImage,masks(i,:));
                allTrainingDataStructure(i).feature         = feature;
                %         % VISUALIZATION DEBUG
                %         figure(23434),
                %         subplot(1,5,1)
                %         imshow(trainingDataStructure(i).image),     title('Training Sample'),
                %         subplot(1,5,3)
                %         imshow(paddedImage), title('Padded'),
                %         subplot(1,5,4)
                %         imshow(paddedImage), title('Masked')
                %         hold on
                %         plotBodyPartMasks(paddedImage,masks(i,:));
                %         hold off,
                %         subplot(1,5,5)
                %         bar(HSV),
                %         in(HSV - trainFeatures.F(i,:)')
            end
            
        end
        close(wbr);
        
        if loadImages % time saving measure
            save(allTrainingDataStructure_path,'allTrainingDataStructure'),
            cprintf('*[1,0,1]',['Saved allTtrainingDataStructure to ' allTrainingDataStructure_path '\n'])
        end

    end
        
    % display('createTrainStructure.m : Not loading training images at the moment (for speed concerns)')
        
    %     if exist('testCamera','var')
    %     % No need to filter for test camera, the trainCameras list is user defined, and we follow the user's wishes
    %         trainingDataStructure = trainingDataStructure([trainingDataStructure.camera] ~= testCamera);
    %     end

    %Load false positive samples to concatenate with the training data structure
    if exist('useFalsePositiveClass','var') && useFalsePositiveClass
                
        falsePositiveClassDirectory = [thisDetectorDetectionsDirectory '/FPClass' ];
        %FPfeatures = load([falsePositiveClassDirectory '/featHSV(4 Parts)[10,10,10]eq.mat']);
        FPMat = dlmread([falsePositiveClassDirectory '/allUniqueFP.txt']);
        
        FPmasks = load([falsePositiveClassDirectory '/pmskset4_128x64.mat']);
        FPmasks = FPmasks.pmskset4;
        if size(FPmasks,1) ~= size(FPMat,1)
            error(['Number of masks (' int2str(size(masks,1)) ') not equal to number of training crops (' int2str(nDetections) ').'])
        end

        allFPDataStructure_path = [trainingSetPath '/allFPDataStructure_' featureExtractionName '.mat'];
        if loadImages && exist(allFPDataStructure_path,'file')
            load(allFPDataStructure_path),
            cprintf('*blue',['Loaded allFPDataStructure from ' allFPDataStructure_path '\n'])
            assert(isfield(allFPDataStructure, 'camera'))
            assert(isfield(allFPDataStructure, 'frame'))
            assert(isfield(allFPDataStructure, 'personId'))
            assert(isfield(allFPDataStructure, 'image'),'SEEMS like the cached allFP file was saved without the images :P...')
            assert(isfield(allFPDataStructure, 'mask'))
            assert(isfield(allFPDataStructure, 'feature'))
        else
            
            for i=1:size(FPMat,1)
                FPSample = FPMat(i,:);
                camera                            = FPSample(1);
                frame                             = FPSample(2);
                bb                                = FPSample(3:6);
                allFPDataStructure(i).camera      = camera;
                allFPDataStructure(i).frame       = frame;
                allFPDataStructure(i).personId    = 999;
                if loadImages
                    % TODO: IMPLEMENT CROPPING ON THE FLY HERE
                    if ~offlineCrop_and_not_OnTheFlyFeatureExtraction
                        % ON-THE-FLY IMAGE CROPPING
                        subImage = getFrameAndCrop(camera, frame, bb);
                    else % if cropped offline
                        subImage = imread([falsePositiveClassDirectory sprintf('/FP%06d.png',i)]);
                    end
                    
                    allFPDataStructure(i).image   = subImage;
                    allFPDataStructure(i).mask       = FPmasks(i,:);
                    
                    % imshow(trainSampleImage)
                    paddedImage = smartPadImageToBodyPartMaskSize(subImage);
                    feature = featureExtractionHandle(paddedImage,FPmasks(i,:));
                    allFPDataStructure(i).feature     = feature;
                    
                    % DEBUG visualization
                    %figure(234),
                    %subplot(1,5,1)
                    %imshow( getFrameAndCrop(camera, frame, bb) ), title('Online Crop'),
                    %
                    %FPXXXpng = [falsePositiveClassDirectory '/' sprintf('F%06d.png',i)];
                    %if exist(FPXXXpng,'file')
                    %    subplot(1,4,2)
                    %    imshow(imread(FPXXXpng))
                    %    title('Cropped offline')
                    %end
                    %
                    % subplot(1,5,3)
                    % imshow(paddedImage), title('Padded'),
                    %
                    %subplot(1,5,4)
                    %imshow(paddedImage), title('Masked')
                    %hold on
                    %plotBodyPartMasks(paddedImage,FPmasks(i,:));
                    %hold off,
                    %
                    %subplot(1,5,5)
                    %bar(feature),
                    % END DEBUG visualization
                    
                end
            end
            %         SAVE HERE
            if loadImages % time saving measure
                save(allFPDataStructure_path,'allFPDataStructure'),
                cprintf('*[1,0,1]',['Saved allFPDataStructure to ' allFPDataStructure_path '\n'])
            end

        end
            
        allTrainingDataStructure = [allTrainingDataStructure allFPDataStructure];
        % trainingDataStructure = [trainingDataStructure allFPDataStructure];
    end

    % Keep only the training samples from specified training cameras
    if exist('trainCameras','var')
        trainingDataStructure = [];
        for trainCamera = trainCameras
            trainingDataStructure = [trainingDataStructure allTrainingDataStructure([allTrainingDataStructure.camera] == trainCamera)];
        end
    else
        trainingDataStructure = allTrainingDataStructure;
    end
    
return    
