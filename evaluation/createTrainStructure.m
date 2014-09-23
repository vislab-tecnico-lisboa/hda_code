function trainingDataStructure = createTrainStructure()

    declareGlobalVariables,
    %TODO: insert online cropping code here, 
    %   todo: needs allT.txt to include BB data

    trainingDataDirectory = [hdaRootDirectory '/hda_sample_train_data'];
    trainFeatures = load([trainingDataDirectory '/featHSV(4 Parts)[10,10,10]eq.mat']);
        
    TrainMat=dlmread([trainingDataDirectory '/allT.txt']);
    cprintf('*blue',['Loaded allT.txt from ' trainingDataDirectory '\n'])
    
    for i=1:size(TrainMat,1)
        % trainSample = load([trainingDataDirectory '/' nameList(i).name]);
        trainSample = TrainMat(i,:);
        allTrainingDataStructure(i).camera      = trainSample(1);
        allTrainingDataStructure(i).frame       = trainSample(2);
        allTrainingDataStructure(i).personId    = trainSample(3);
        % trainingDataStructure(i).fullyVisible= trainSample(4); % not useful 
        % trainingDataStructure(i).image       = imread([trainingDataDirectory '/' nameList(i).name(1:end-3) 'png']);
        % imshow(trainSampleImage)
        allTrainingDataStructure(i).F           = trainFeatures.F(i,:)';
    end
    display('createTrainStructure.m : Not loading training images at the moment (for speed concerns)')

    %     if exist('testCamera','var')
    %     % No need to filter for test camera, the trainCameras list is user defined, and we follow the user's wishes
    %         trainingDataStructure = trainingDataStructure([trainingDataStructure.camera] ~= testCamera);
    %     end

    %Load false positive samples to concatenate with the training data structure
    if exist('useFalsePositiveClass','var') && useFalsePositiveClass
        falsePositiveClassDirectory = [thisDetectorDetectionsDirectory '/FPClass' ];
        FPfeatures = load([falsePositiveClassDirectory '/featHSV(4 Parts)[10,10,10]eq.mat']);
        FPMat = dlmread([falsePositiveClassDirectory '/allUniqueFP.txt']);
        for i=1:size(FPMat,1)
            % trainSample = load([trainingDataDirectory '/' nameList(i).name]);
            FPSample = FPMat(i,:);
            allFPDataStructure(i).camera      = FPSample(1);
            allFPDataStructure(i).frame       = FPSample(2);
            allFPDataStructure(i).personId    = 999;
            % trainingDataStructure(i).fullyVisible= trainSample(4); % not useful
            % trainingFPStructure(i).image       = imread([falsePositiveClassDirectory '/' nameList(i).name(1:end-3) 'png']);
            % imshow(trainSampleImage)
            allFPDataStructure(i).F           = FPfeatures.F(i,:)';
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
