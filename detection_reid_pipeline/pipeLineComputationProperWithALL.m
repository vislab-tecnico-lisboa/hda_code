%% Pipe-line computation proper
TSTART = tic;
if isempty(trainCameras) && isempty(testCameras)
    % Run one experiment per test camera with all the
    % other cameras as train, for all test cameras. Then, concatenate all
    % the sample results and compute a global CMC
    [trainingDataStructure, allTrainingDataStructure] = createTrainStructure(0);
    pedNum = length(unique([allTrainingDataStructure.personId]));

    cameras = [17 18 19 40 50 53 54 56 57 58 59 60];
    allGs = [];
    for irun = 1:length(cameras)
        testCameras = cameras(irun);
        trainCameras = cameras(cameras ~= testCameras);
        
        pipelineComputationProper,
        if size(allG,2) < pedNum+3
            % making the allG matrixes the same size for concatenation
            allG(1,pedNum+3) = 0;
        end
        allGs = [allGs; allG];
        
        evaluatorCMC('development');%'development'
    end
        
    evaluatorCMC('all',allGs);
    
else
    % Plot one CMC per test camera specified, assume training cameras don't
    % overlap with test cameras specified.
    pipelineComputationProper,

    evaluationProper,
    
end

elapsedTime = toc(TSTART);
if elapsedTime > 30
    [y,Fs,NBITS]=wavread('Finished.wav'); sound(y,Fs,NBITS);
end