% function plotAllFPs

FPclassDirectory         = [experimentDataDirectory '/FPClass'];
allFPs = dlmread([FPclassDirectory '/allFP.txt']);

seqFilesDirectory = [hdaRootDirectory '/hda_image_sequences_matlab'];


for trainCamera = trainCameras
    
    thisCameraFPsInd = allFPs(:,1) == trainCamera;
    thisCameraFPs = allFPs(thisCameraFPsInd,:);
    numFPs = size(thisCameraFPs,1);
    
    %Set up image reading stuff
    seqName = sprintf('%s/camera%02d.seq',seqFilesDirectory, trainCamera); %MATTEO TODO CHANGE CAM TO CAMERA
    seqReader = seqIo( seqName, 'reader'); % Open the input image sequence
    seqReader.seek(0);
    image = seqReader.getframe();

    uniqueThisCameraFPsTemp = thisCameraFPs;
    uniqueThisCameraFPs = [];
    while ~isempty(uniqueThisCameraFPsTemp)        
        FP = uniqueThisCameraFPsTemp(1,:);
        duplicateFPsi = sum(uniqueThisCameraFPsTemp(:,3:end) == repmat(FP(3:end),size(uniqueThisCameraFPsTemp,1),1),2) == 4;
        uniqueThisCameraFPsTemp = uniqueThisCameraFPsTemp(~duplicateFPsi,:);
        uniqueThisCameraFPs = [uniqueThisCameraFPs; FP;];
    end
    
    figure('name', ['Camera ' int2str(trainCamera) ', ' int2str(size(uniqueThisCameraFPs,1)) ' unique FPs']), imshow(image), 
    hold on,    
    for FPi = 1:size(uniqueThisCameraFPs,1)
        FP = uniqueThisCameraFPs(FPi,:);
        rectangle('Position',FP(3:end),'EdgeColor','r')
    end
    hold off,
    title(['Camera ' int2str(trainCamera) ', ' int2str(size(uniqueThisCameraFPs,1)) 'unique FPs']),

    
    
end
    