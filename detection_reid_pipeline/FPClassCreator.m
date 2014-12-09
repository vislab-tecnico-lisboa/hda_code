function FPClassCreator()
%
% Makes a list of all false positives in the training cameras and stores it
% under the experiment folder inside a FPClass folder (i.e.,
% HDA_Dataset/hda_experiment_data/DetectorName_ExperimentName/FPClass )
%
% If this list (named allFP.txt and allUniqueFP.txt) already exists for all
% cameras in the general detections folder (i.e., HDA_Dataset/hda_detections/AcfInria/FPClass)
% then create allFP.txt and allUniqueFP.txt with the false positives of
% only the specified training camera by extracting from those general files
% the lines with respect to only the specified training cameras.
%
% This filtering and storing of the list in the experiment folder is
% somewhat redundant at the moment because in createTrainStructure.m it is
% loading the false positives from the general detections folder, and
% filtering there to keep only the ones relative to the specified training
% cameras.
%
% The image loading or cropping-on-the-fly plus the feature extraction is
% done in createTrainStructure.m

declareGlobalVariables,

FPclassDirectory         = [experimentDataDirectory '/FPClass'];
if ~exist(FPclassDirectory,'dir'), mkdir(FPclassDirectory); end;

if(recomputeAllCachedInformation)
    warning('off','MATLAB:DELETE:FileNotFound')
    delete([FPclassDirectory '/info.txt']);
    delete([FPclassDirectory '/allFP.txt']);
    delete([FPclassDirectory '/allUniqueFP.txt']);
    warning('on','MATLAB:DELETE:FileNotFound')
end
if exist([FPclassDirectory '/allUniqueFP.txt'],'file')
    cprintf('blue',['allUniqueFP.txt already exists at ' FPclassDirectory '\n']),
    return,
end

fid = fopen([FPclassDirectory '/info.txt'],'w');
fprintf(fid,'List of False Positive detections in the training cameras to create a FP class in the RE-ID classifier.\n');
fprintf(fid,'Format: \n');
fprintf(fid,'camera#, frame#, x, y, w, h. \n');
fclose(fid);

%% Compute all detections with zero overlap with GT
allFPs_folder = [hdaRootDirectory '/hda_detections/' detectorName '/FPClass'];
allFPs_allCameras_txt  = [allFPs_folder '/allUniqueFP.txt'];
allUniqueFPs_allCameras_txt = [allFPs_folder '/allUniqueFP.txt'];
if exist(allUniqueFPs_allCameras_txt,'file') && exist(allFPs_allCameras_txt,'file')
    % copy from pre-computed files in the detectors folder
    allFPs_allCameras = dlmread(allFPs_allCameras_txt);
    allUniqueFPs_allCameras = dlmread(allUniqueFPs_allCameras_txt);
    
    % Keep only the FPs from specified training cameras
    allFPs = [];
    allUniqueFPs = [];
    for trainCamera = trainCameras
        allFPs       = [allFPs;                   allFPs_allCameras(allFPs_allCameras(:,1) == trainCamera,:)];
        allUniqueFPs = [allUniqueFPs; allUniqueFPs_allCameras(allUniqueFPs_allCameras(:,1) == trainCamera,:)];
    end
    dlmwrite([FPclassDirectory '/allFP.txt'],allFPs);
    cprintf('*[1,0,1]',['Saved allFP.txt to ' FPclassDirectory '\n'])
    dlmwrite([FPclassDirectory '/allUniqueFP.txt'],allUniqueFPs);
    cprintf('*[1,0,1]',['Saved allUniqueFP.txt to ' FPclassDirectory '\n'])

else
    MatToSave = [];
    for trainCamera = trainCameras
        fprintf('FPClassCreator: Working on camera: %d\n',trainCamera);
        
        localDetectionsDirectory = [thisDetectorDetectionsDirectory sprintf('/camera%02d',trainCamera) '/Detections'];
        
        %Read GT file (VBB)
        GTName = [hdaRootDirectory '/hda_annotations' sprintf('/cam%02d.txt',trainCamera)];
        GTMat = vbb('vbbLoadTxt',GTName);
        
        %Load all-detections matrix
        DetMat=dlmread([localDetectionsDirectory '/allD.txt']);
        nDets=size(DetMat,1);
        
        %Work on one detectition file at a time
        wbr = waitbar(0, ['FPClassCreator on camera ' int2str(trainCamera) ', image 0/' int2str(nDets)]);
        dividerWaitbar=10^(floor(log10(nDets))-1); % Limiting the access to waitbar
        for det=1:nDets
            if (round(det/dividerWaitbar)==det/dividerWaitbar) % Limiting the access to waitbar
                waitbar(det/nDets, wbr, ['FPClassCreator on camera ' int2str(trainCamera) ', image ' int2str(det) '/' int2str(nDets)]);
            end
            dataLine = DetMat(det,:);
            frame = dataLine(2);
            %Select the GT data for this image
            try
                % For camera 54 frames begin at 0 and end at 3424
                % objLists for camera 54 has 3424 cells
                % so wtf?
                gt=GTMat.objLists{1,frame+1};
            catch me
                warning(['FPClassCreator: warning at ' int2str(det) ' detection of camera ' int2str(trainCamera) '  ' me.message])
                continue,
            end
            
            % Detections with zero overlap with ground truth annotations
            % are considered false positives to be inserted in the false
            % positive class
            isFalsePositive = 1;
            overlap =[];
            for gtId=1:size(gt,2)
                %match = 0 if overlap < threshold, 1 otherwise
                [match, cost] = computeBbMatch( gt(1,gtId).pos, dataLine(3:6), 0);
                overlap(gtId) = 1-cost;
                if(match),
                    isFalsePositive = 0;
                end
            end
            if(isFalsePositive)
                label=999;
                MatToSave(end+1,:) = [dataLine(1:end-1)];
            end
            
        end
        close(wbr);
        
    end
    dlmwrite([FPclassDirectory '/allFP.txt'],MatToSave);
    cprintf('*[1,0,1]',['Saved allFP.txt to ' FPclassDirectory '\n'])
    
    
    %% From all FPs select only the unique ones (with different [x y w h])
    % and crop them
    uniqueFPs = [];
    allFPs = dlmread([FPclassDirectory '/allFP.txt']);
    seqFilesDirectory = [hdaRootDirectory '/hda_image_sequences_matlab'];
    for trainCamera = trainCameras
        
        thisCameraFPsInd = allFPs(:,1) == trainCamera;
        thisCameraFPs = allFPs(thisCameraFPsInd,:);
        numFPs = size(thisCameraFPs,1);
        
        % Retain only the unique FPs bounding boxes in the image (many FPs
        % are repetitions, e.g., several images of the same fire extinguisher)
        uniqueThisCameraFPsTemp = thisCameraFPs;
        uniqueThisCameraFPs = [];
        while ~isempty(uniqueThisCameraFPsTemp)
            FP = uniqueThisCameraFPsTemp(1,:);
            duplicateFPsi = sum(uniqueThisCameraFPsTemp(:,3:end) == repmat(FP(3:end),size(uniqueThisCameraFPsTemp,1),1),2) == 4;
            uniqueThisCameraFPsTemp = uniqueThisCameraFPsTemp(~duplicateFPsi,:);
            uniqueThisCameraFPs = [uniqueThisCameraFPs; FP;];
        end
        
        % Crop all the unique FPs
        if offlineCrop_and_not_OnTheFlyFeatureExtraction
            %Set up image reading stuff
            seqName = sprintf('%s/camera%02d.seq',seqFilesDirectory, trainCamera); %MATTEO TODO CHANGE CAM TO CAMERA
            seqReader = seqIo( seqName, 'reader'); % Open the input image sequence
            seqReader.seek(0);
            image = seqReader.getframe();
            [nRows,nCols,nPags] = size(image);
            for FPi = 1:size(uniqueThisCameraFPs,1)
                FP = uniqueThisCameraFPs(FPi,3:end);
                frame = uniqueThisCameraFPs(FPi,2);
                
                %Write cropped images and text files with information
                %Get the image associated with the detection
                hOuter  = FP(4) * 1;%(128/96); 1 means no border
                wOuter  = hOuter * 0.4062;
                uMiddle = FP(1) + FP(3)/2; %xMiddle = x0+width/2
                u0      = round(uMiddle - wOuter/2);
                u1      = round(uMiddle + wOuter/2);
                vMiddle = FP(2) + FP(4)/2; %xMiddle = x0+width/2
                v0      = round(vMiddle - hOuter/2);
                v1      = round(vMiddle + hOuter/2);
                leftPad   = 0;
                rightPad  = 0;
                bottomPad = 0;
                topPad    = 0;
                if(u0<1)
                    leftPad = 1 - u0;
                    u0      = 1;
                end
                if(u1>nCols)
                    rightPad = u1 - nCols;
                    u1       = nCols;
                end
                if(v0<1)
                    topPad = 1 - v0;
                    v0      = 1;
                end
                if(v1>nRows)
                    bottomPad = v1 - nRows;
                    v1       = nRows;
                end
                
                %             % DEBUG show images
                %             seqReader.seek(frame);
                %             image = seqReader.getframe();
                %             figure(1),imagesc(image);
                %             hold on,
                %             rectangle('Position', [u0 v0 u1-u0 v1-v0], 'EdgeColor','r','LineWidth',5),
                %             hold off,
                %             waitforbuttonpress,
                
                subImage=image( v0:v1, u0:u1 , : );
                subImage=padarray(subImage,[topPad,leftPad],'replicate','pre');
                subImage=padarray(subImage,[bottomPad,rightPad],'replicate','post');
                
                imageName = [FPclassDirectory sprintf('/FP%06d.png',size(uniqueFPs,1)+FPi)];
                try
                    imwrite(subImage,imageName);
                catch me
                    % This is randomply giving this error on plinio's PC:
                    %??? Error using ==> png
                    %Could not open file.
                    %
                    %Error in ==> writepng at 429
                    %png('write', data, map, filename, colortype, bitdepth, ...
                    %
                    %Error in ==> imwrite at 477
                    %        feval(fmt_s.write, data, map, filename, paramPairs{:});
                    warning([me.message])
                    display(['         when trying to save image ' imageName '... '])
                    display(['         Trying again.'])
                    imwrite(subImage,imageName);
                end
                
            end
        end
        
        % Debug, plot all FPs in each camera image
        %         figure('name', ['Camera ' int2str(trainCamera) ', ' int2str(size(uniqueThisCameraFPs,1)) ' unique FPs']),
        %         imshow(image),
        %         hold on,
        %         for FPi = 1:size(uniqueThisCameraFPs,1)
        %             FP = uniqueThisCameraFPs(FPi,:);
        %             rectangle('Position',FP(3:end),'EdgeColor','r')
        %         end
        %         hold off,
        %         title(['Camera ' int2str(trainCamera) ', ' int2str(size(uniqueThisCameraFPs,1)) ' unique FPs']),
        
        uniqueFPs = [uniqueFPs; uniqueThisCameraFPs];
    end
    dlmwrite([FPclassDirectory '/allUniqueFP.txt'],uniqueFPs);
    cprintf('*[1,0,1]',['Saved allUniqueFP.txt to ' FPclassDirectory '\n'])
end

return

%% Debug: inspect all FPs
allFPs = dlmread([FPclassDirectory '/allFP.txt']);
seqFilesDirectory = [hdaRootDirectory '/hda_image_sequences_matlab'];
trainCamera=17;
localDetectionsDirectory = [thisDetectorDetectionsDirectory sprintf('/camera%02d',trainCamera) '/Detections'];
DetMat=dlmread([localDetectionsDirectory '/allD.txt']);
%Set up image reading stuff
seqName = sprintf('%s/camera%02d.seq',seqFilesDirectory, trainCamera); %MATTEO TODO CHANGE CAM TO CAMERA
seqReader = seqIo( seqName, 'reader'); % Open the input image sequence

thisCameraFPsInd = allFPs(:,1) == trainCamera;
thisCameraFPs = allFPs(thisCameraFPsInd,:);
numFPs = size(thisCameraFPs,1);

% Show all detections
% figure('name', ['Camera ' int2str(trainCamera)]),
for deti=649:size(DetMat,1)
    det = DetMat(deti,:);
    frame = det(2);
    seqReader.seek(frame);
    image = seqReader.getframe();
    % imshow(image),
    showFrameAndBBs(det(1),frame);
    hold on,
    rectangle('Position',det(3:end-1),'EdgeColor','b')
    hold off,
    title(['Frame ' int2str(frame)])
  
%     waitforbuttonpress,
end

% Show all FPs
for FPi=1:size(thisCameraFPs,1)
    FP = thisCameraFPs(FPi,3:end);
    frame = thisCameraFPs(FPi,2);
            %Write cropped images and text files with information
            %Get the image associated with the detection
            hOuter  = FP(4) * 1;%(128/96); 1 means no border
            wOuter  = hOuter * 0.4062;
            uMiddle = FP(1) + FP(3)/2; %xMiddle = x0+width/2
            u0      = round(uMiddle - wOuter/2);
            u1      = round(uMiddle + wOuter/2);
            vMiddle = FP(2) + FP(4)/2; %xMiddle = x0+width/2
            v0      = round(vMiddle - hOuter/2);
            v1      = round(vMiddle + hOuter/2);
            leftPad   = 0;
            rightPad  = 0;
            bottomPad = 0;
            topPad    = 0;
            if(u0<1)
                leftPad = 1 - u0;
                u0      = 1;
            end
            if(u1>nCols)
                rightPad = u1 - nCols;
                u1       = nCols;
            end
            if(v0<1)
                topPad = 1 - v0;
                v0      = 1;
            end
            if(v1>nRows)
                bottomPad = v1 - nRows;
                v1       = nRows;
            end
    % DEBUG show images
    seqReader.seek(frame);
    image = seqReader.getframe();
    figure(1),imagesc(image);
    hold on,
    rectangle('Position', [u0 v0 u1-u0 v1-v0], 'EdgeColor','r','LineWidth',5),
    title(['Frame ' int2str(frame)])
    hold off,
    waitforbuttonpress,
end



