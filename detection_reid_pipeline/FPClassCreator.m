function FPClassCreator(trainCameras, hdaRootDirectory, thisDetectorDetectionsDirectory, experimentDataDirectory, recomputeAllCachedInformation)

    createImages = 0;
    
    FPclassDirectory         = [experimentDataDirectory '/FPClass'];
    if ~exist(FPclassDirectory,'dir'), mkdir(FPclassDirectory); end;
    
    if(recomputeAllCachedInformation)
        delete([FPclassDirectory '/info.txt']);
        delete([FPclassDirectory '/allFP.txt']);
        delete([FPclassDirectory '/allUniqueFP.txt']);
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
    MatToSave = [];
    for trainCamera = trainCameras
        fprintf('FPClassCreator: Working on camera: %d\n',trainCamera);
        
        localDetectionsDirectory = [thisDetectorDetectionsDirectory sprintf('/camera%02d',trainCamera) '/Detections'];

        %Read GT file (VBB)
        GTName = [hdaRootDirectory '/hda_annotations' sprintf('/cam%02d_rev1.txt',trainCamera)];
        GTMat = vbb('vbbLoadTxt',GTName);
        
        %Load all-detections matrix
        DetMat=dlmread([localDetectionsDirectory '/allD.txt']);
        nDets=size(DetMat,1);
        
        %Work on one detectition file at a time
        wbr = waitbar(0, ['FPClassCreator on camera ' int2str(trainCamera) ', image 0/' int2str(nDets)]);
        for det=1:nDets
            waitbar(det/nDets, wbr, ['FPClassCreator on camera ' int2str(trainCamera) ', image ' int2str(det) '/' int2str(nDets)]);
            dataLine = DetMat(det,:);
            frame = dataLine(2);
            %Select the GT data for this image
            try
                % For camera 54 frames begin at 0 and end at 3424
                % objLists for camera 54 has 3424 cells
                % so wtf?
                gt=GTMat.objLists{1,frame+1}; 
            catch
                warning(['FPClassCreator: warning at ' int2str(det) ' detection of camera ' int2str(trainCamera) ])
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
    cprintf('*red',['Saved allFP.txt to ' FPclassDirectory '\n'])


    %% From all FPs select only the unique ones (with different [x y w h])
    % and crop them
    uniqueFPs = [];
    allFPs = dlmread([FPclassDirectory '/allFP.txt']);
    seqFilesDirectory = [hdaRootDirectory '/hda_image_sequences_matlab'];
    for trainCamera = trainCameras
        %%
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
        if createImages
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
                imwrite(subImage,imageName);
                
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
    cprintf('*red',['Saved allUniqueFP.txt to ' FPclassDirectory '\n'])

%     ALREADY DONE IN createTrainStructure
%     % Create feature matrix from the feature matrix of all unique FPs of all cameras 
%     falsePositiveClassDirectory =  hda_detections\AcfInria\FPClass
%     allFPfeatures = load([falsePositiveClassDirectory '/featHSV(4 Parts)[10,10,10]eq.mat'])
    
return

%% Debug: inspect all FPs
% allFPs = dlmread([FPclassDirectory '/allFP.txt']);
% seqFilesDirectory = [hdaRootDirectory '/hda_image_sequences_matlab'];
% trainCamera=60;
% localDetectionsDirectory = [thisDetectorDetectionsDirectory sprintf('/camera%02d',trainCamera) '/Detections'];
% DetMat=dlmread([localDetectionsDirectory '/allD.txt']);
% %Set up image reading stuff
% seqName = sprintf('%s/camera%02d.seq',seqFilesDirectory, trainCamera); %MATTEO TODO CHANGE CAM TO CAMERA
% seqReader = seqIo( seqName, 'reader'); % Open the input image sequence
% 
% thisCameraFPsInd = allFPs(:,1) == trainCamera;
% thisCameraFPs = allFPs(thisCameraFPsInd,:);
% numFPs = size(thisCameraFPs,1);
% 
% figure('name', ['Camera ' int2str(trainCamera)]),
% for deti=649:size(DetMat,1)
%     det = DetMat(deti,:);
%     frame = det(2);
%     seqReader.seek(frame);
%     image = seqReader.getframe();
%     imshow(image),
%     hold on,
%     rectangle('Position',det(3:end-1),'EdgeColor','r')
%     hold off,
%     title(['Frame ' int2str(frame)])
%     waitforbuttonpress,
% end
% 
% % Show all FPs
% for FPi=1:size(thisCameraFPs,1)
%     FP = thisCameraFPs(FPi,3:end);
%     frame = thisCameraFPs(FPi,2);
%             %Write cropped images and text files with information
%             %Get the image associated with the detection
%             hOuter  = FP(4) * 1;%(128/96); 1 means no border
%             wOuter  = hOuter * 0.4062;
%             uMiddle = FP(1) + FP(3)/2; %xMiddle = x0+width/2
%             u0      = round(uMiddle - wOuter/2);
%             u1      = round(uMiddle + wOuter/2);
%             vMiddle = FP(2) + FP(4)/2; %xMiddle = x0+width/2
%             v0      = round(vMiddle - hOuter/2);
%             v1      = round(vMiddle + hOuter/2);
%             leftPad   = 0;
%             rightPad  = 0;
%             bottomPad = 0;
%             topPad    = 0;
%             if(u0<1)
%                 leftPad = 1 - u0;
%                 u0      = 1;
%             end
%             if(u1>nCols)
%                 rightPad = u1 - nCols;
%                 u1       = nCols;
%             end
%             if(v0<1)
%                 topPad = 1 - v0;
%                 v0      = 1;
%             end
%             if(v1>nRows)
%                 bottomPad = v1 - nRows;
%                 v1       = nRows;
%             end
%     % DEBUG show images
%     seqReader.seek(frame);
%     image = seqReader.getframe();
%     figure(1),imagesc(image);
%     hold on,
%     rectangle('Position', [u0 v0 u1-u0 v1-v0], 'EdgeColor','r','LineWidth',5),
%     title(['Frame ' int2str(frame)])
%     hold off,
%     waitforbuttonpress,
% end
                
function [match cost] = computeBbMatch( r1, r2, threshold)
% r = [u0, v0, width, height]
% threshold should be a value between 0 and 1, typically 0.5

      %Do r1 and r2 intersect? Check if you can define a rectangle which is the intersection of the two.
      u0Int = max( r1(2), r2(2) ); %rightmost left edge
      v0Int = max( r1(1), r2(1) ); %lower top edge
      u1Int = min( r1(2) + r1(4), r2(2) +r2(4) ); %leftmost right edge
      v1Int = min( r1(1) + r1(3), r2(1) +r2(3) ); %upper bottom edge
      
      if( ( u0Int < u1Int ) && ( v0Int < v1Int ) ) %YES, intersection
        overlapArea = (u1Int - u0Int) * (v1Int - v0Int);
        unionArea = r1(3)*r1(4) + r2(3)*r2(4) - overlapArea;
        if( (overlapArea/unionArea) >= threshold)
          match = true;
          cost  = (unionArea-overlapArea)/unionArea; %Encodes how bad the match is. NonOverlap/Union.
        else
          match = false;
          cost  = inf;
        end    
      else
        overlapArea = 0;
        match = false;
        cost  = inf;
      end  
      
return


