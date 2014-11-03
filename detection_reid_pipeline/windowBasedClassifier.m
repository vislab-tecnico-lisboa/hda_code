function windowBasedClassifier(trainCameras, testCameras, hdaRootDirectory, experimentDataDirectory, detectorName, thisDetectorDetectionsDirectory, useMutualOverlapFilter, useFalsePositiveClass, recomputeAllCachedInformation, reIdentifierName)

    %     error('windowBasedClassifier.m: unfinished, TODO: add input parameters R d W ')
    R = 1;
    d = 1;
    W = 1;
    trainingDataStructure = createTrainStructure(hdaRootDirectory,trainCameras,useFalsePositiveClass,thisDetectorDetectionsDirectory);
    % testCamera = testCameras

    for testCamera = testCameras
        
        imagePath = [hdaRootDirectory '/hda_image_sequences_jpeg/camera' int2str(testCamera)];
        imageNames = dir([imagePath '/*.jpeg']);
        
        trainDataStructNoTestCamera = trainingDataStructure([trainingDataStructure.camera] ~= testCamera);
        unique_trainSpid = unique([trainDataStructNoTestCamera.personId]);
        nTrainPeds = length(unique_trainSpid);
%         if testCamera == 60
%             TotalFrames = 420+400+400+520;% Camera 60 has 420+400+400+... frames
%         elseif testCamera == 17
%             TotalFrames = 9897;
%         elseif testCamera == 50
%             TotalFrames = 2227;
%         elseif testCamera == 52
%             TotalFrames = 3444;
%         end
        TotalFrames = length(imageNames);

        % Create test samples structure
        reIdsAndGtDirectory    = [experimentDataDirectory sprintf('/camera%02d/ReIdsAndGts', testCamera) reIdentifierName];
        reIdsAndGtMat = dlmread([reIdsAndGtDirectory '/allG.txt']);        
        clear testSamplesStructure,
        for i=1:size(reIdsAndGtMat,1)
            GTSample = reIdsAndGtMat(i,:);
            testSamplesStructure(i).camera      = GTSample(1);
            testSamplesStructure(i).frame       = GTSample(2);
            testSamplesStructure(i).personId    = GTSample(3);
            testSamplesStructure(i).rankList    = GTSample(4:end);
            % trainingDataStructure(i).image       = imread([trainingDataDirectory sprintf('/T%06d.png',i)]);
            % imshow(trainSampleImage)            
        end
        % cutting out the inactive detections
        testSamplesStructure = testSamplesStructure([testSamplesStructure.camera]~=0);
        
        PrecRecFile = [experimentDataDirectory sprintf('/camera%02d', testCamera) '/PrecRec_R1to' int2str(nTrainPeds) '.mat'];                
        if recomputeAllCachedInformation
            delete(PrecRecFile)
        end
        if exist(PrecRecFile,'file')
            load(PrecRecFile,'Precision_overAllFrames','Recall_overAllFrames'),
            cprintf('*blue',['Loaded file with Precision and Recall from ' PrecRecFile '\n'])
        else                
            wbr = waitbar(0, ['windowBasedClassifier on camera ' int2str(testCamera)]);
            for R=1:nTrainPeds
                waitbar(R/nTrainPeds, wbr, ['windowBasedClassifier on camera ' int2str(testCamera) ', Rank ' int2str(R) '/' int2str(nTrainPeds)]);

                % Create frameDet matrix, which contains one line per pedestrian,
                % the lenght of the video, with 1 in the frames where the ReId classifier
                % detected and re-identified that pedestrian up to rank R, and 0 otherwise
                frameDet = sparse(zeros(max(unique([trainDataStructNoTestCamera.personId])),TotalFrames));
                %display('TODO: CORRECT THIS MAX(UNIQUE TO LENGTH(UNIQUE,... maybe not')
                for iDet = 1:length(testSamplesStructure)
                    for iR = 1:R
                        frameDet(testSamplesStructure(iDet).rankList(iR),testSamplesStructure(iDet).frame+1) = 1;
                    end
                end

                % From frameDet, create framesShown matrix, that has one line per
                % pedestrian, and the length of the video, with 1 in the frames
                % shown as output by the window-based classifier
                framesShown = sparse(false(length(unique_trainSpid),TotalFrames));
                for pedIndex=1:length(unique_trainSpid)
                    ped = unique_trainSpid(pedIndex);

                    detind = find(frameDet(ped,:) ~= 0);
                    shownVect = false(1,TotalFrames);
                    if d==1 % Debug and assert
                        shownVectd1 = false(1,TotalFrames);
                    end
                    for iDet=1:length(detind)-d+1
                        ind=detind(iDet);
                        ind2 = detind(iDet+d-1);
                        margem = W-(ind2-ind)-1;
                        if margem < 0
                            continue,
                        end
                        % for each tuple of d detection, set to 1 all frames from -margen to +margem of it
                        shownVect(max(1,ind-margem):min(ind2+margem,TotalFrames)) = 1;
                        if d==1 % Debug and assert
                            shownVectd1(max(1,ind-(W-1)):min(ind+(W-1),TotalFrames)) = 1;
                        end
                    end
                    if d==1 % Debug and assert
                        assert(min(shownVectd1 == shownVect),['Rank' int2str(R) ' d' int2str(d) ': shownVectd1 not equal to shownVect']),
                        % display(['All is good, Rank' int2str(rank) ' d' int2str(d) ': shownVectd1 equal to shownVect'])
                    end

                    framesShown(pedIndex,:) = shownVect; % logical(shownVect);            
                end


                % Use the output of gtAndDetMatcher.m ran on 'GtAnnotationsAll'
                % to generate frameGTfull (we need the ground truth person Ids)
                % GtAnnotationsAllGsDirectory = [hdaRootDirectory '/hda_detections/GtAnnotationsAll' sprintf('/camera%02d',testCamera) '/Detections'];
                % GTreIdsAndGtMat=dlmread([GtAnnotationsAllGsDirectory '/allG.txt']);
                GTreIdsAndGtMat=dlmread([reIdsAndGtDirectory '/allG.txt']);

                % For each ped in the ground truth, put a 1 in the frame where he is there
                % matrix frameGT (P x Frame)
                % For each ped in the detections, put a 1 where he is correctly detected
                % with rank 1 (frameRank1 matrix P x Frame )
                %         frameRank1 = zeros(length(dsetGT),TotalFrames);
                %         frameGT = zeros(length(dsetGT),TotalFrames);
                %         frameGTtot = zeros(max([unique_trainSpid]),TotalFrames);
                frameGTfull = false(length([unique_trainSpid]),TotalFrames);
                for GTSampleI = 1:size(GTreIdsAndGtMat,1)
                    GTSample = GTreIdsAndGtMat(GTSampleI,:);
                    if min(GTSample==zeros(size(GTSample))) % if line is "empty" (all zeros) 
                        continue,
                    end
                    frame = GTSample(2); 
                    GTid = GTSample(3); 

                    pedIndex = find(unique_trainSpid==GTid);
                    frameGTfull(pedIndex,frame+1) = 1;
                end

                % Remove FP label 999 from the list of trained pedestrians (because
                % we don't care what the Prec or Recall of the FP class is)
                if ismember(999, unique_trainSpid)
                    ind = unique_trainSpid == 999;
                    unique_trainSpid_noFPs = unique_trainSpid(~ind);
                else
                    unique_trainSpid_noFPs = unique_trainSpid;
                end

                % Compute metrics
                PSFs = zeros(length(unique_trainSpid_noFPs),1);
                FPSFs = zeros(length(unique_trainSpid_noFPs),1);
                shownpedsAll = zeros(length(unique_trainSpid_noFPs),1);
                positiveClips = zeros(length(unique_trainSpid_noFPs),1);
                numberofClips = zeros(length(unique_trainSpid_noFPs),1);
                GTclipsShownpeds = zeros(length(unique_trainSpid_noFPs),1);
                totalGTclipspeds = zeros(length(unique_trainSpid_noFPs),1);
                for pedIndex=1:length(unique_trainSpid_noFPs)
                    %if 0 % isunix && strcmp(version(), '8.1.0.604 (R2013a)') % vislab Linux
                    %    shownVect = framesShownAll(pedi,:,R,d,W);
                    %elseif 1 % ispc && strcmp(version(), '8.1.0.604 (R2013a)') || strcmp(version(), '7.12.0.635 (R2011a)') % Dario Laptop Windows
                    shownVect = framesShown(pedIndex,:);
                    %end
                    assert(sum(size(shownVect) ~= [1 TotalFrames])==0,'Not the expected size? transpose?')

                    % determine how many video-clips in the GT are shown at
                    % least one frame
                    GTshownVect = frameGTfull(pedIndex,:);
                    shownVectPad = [0 GTshownVect 0]; % deals with boundary effects in the transitions computation
                    transitionsGT = -shownVectPad(1:end-1)+shownVectPad(2:end); %
                    upsGT = find(transitionsGT == 1);
                    downsGT = find(transitionsGT == -1)-1;
                    GTclipsShown = 0;
                    for iclip=1:length(upsGT)
                        clip = false(size(GTshownVect));
                        clip(upsGT(iclip):downsGT(iclip)) = 1;
                        GTclipsShown = GTclipsShown + max(clip & shownVect);

                        % assert(~max(clip(clip) + GTshownVect(clip) == 1),'clip should never show frames that are not in shownVect')
                    end
                    totalGTclips = length(upsGT);


                    % determine how many video-clips shown
                    shownVectPad = [0 shownVect 0]; % deals with boundary effects in the transitions computation
                    transitions = -shownVectPad(1:end-1)+shownVectPad(2:end); %
                    ups = find(transitions == 1);
                    downs = find(transitions == -1)-1;
                    positiveClipsW = 0;
                    positiveFramesOfClips1ped = 0;
                    sizeOfPositiveClips1ped = 0;
                    for iclip=1:length(ups)
                        clip = false(size(shownVect));
                        clip(ups(iclip):downs(iclip)) = 1;
                        positiveClipsW = positiveClipsW + max(clip & frameGTfull(pedIndex,:));

                        if max(clip & frameGTfull(pedIndex,:))
                            positiveFramesOfClips1ped = positiveFramesOfClips1ped + sum(clip & frameGTfull(pedIndex,:));
                            sizeOfPositiveClips1ped = sizeOfPositiveClips1ped + sum(clip);
                        end

                        assert(~max(clip(clip) + shownVect(clip) == 1),'clip should never show frames that are not in shownVect')
                    end

                    % shown = sum(shownVect);
                    % PosShownFrames = sum(shownVect & frameGTfull(pedi,:));
                    % FalsePosShownFrames = sum(shownVect & ~frameGTfull(pedi,:));
                    % positiveClips_ped2show = positiveClipsW;
                    % numberofClips_ped2show = length(ups);

                    % Only for one W atm, so the ,:) is redundant
                    % shownpeds(pedi) = shown;
                    PSFs(pedIndex) = sum(shownVect & frameGTfull(pedIndex,:));
                    FPSFs(pedIndex) = sum(shownVect & ~frameGTfull(pedIndex,:));
                    shownpedsAll(pedIndex) = sum(shownVect);
                    positiveClips(pedIndex) = positiveClipsW;
                    numberofClips(pedIndex) = length(ups);

                    GTclipsShownpeds(pedIndex) = GTclipsShown;
                    totalGTclipspeds(pedIndex) = totalGTclips;

                    posFramesOfPosFClips(pedIndex) = positiveFramesOfClips1ped;
                    sizeOfPositiveClips(pedIndex) = sizeOfPositiveClips1ped;
                end

                Precision_in_videos = sum(positiveClips)/sum(numberofClips);
                % Precision_in_long_videos3D(R,d,W) = sum(PSFs > 0)/sum(shownpedsAll > 0);
                Precision_overAllFrames(R) = 1 - sum(FPSFs)/sum(shownpedsAll);
                Recall_overAllFrames(R) =         sum(PSFs)/sum(frameGTfull(:));
                Recall_in_videos = sum(GTclipsShownpeds)/sum(totalGTclipspeds);
                assert(sum(PSFs)<=sum(frameGTfull(:)), 'Recall greater than 1? Tha F?')
                Precision_inFrames_of_Positive_VideoClips = sum(posFramesOfPosFClips)/sum(sizeOfPositiveClips);

            end
            close(wbr);
            save(PrecRecFile,'Precision_overAllFrames','Recall_overAllFrames'),
            cprintf('*red',['Saved file with Precision and Recall to ' PrecRecFile '\n'])
        end
        Fscore = 2*(Precision_overAllFrames.*Recall_overAllFrames) ./ (Precision_overAllFrames+Recall_overAllFrames);
        display([num2str(Fscore(1)*100,'%0.1f') ' & ' num2str(Precision_overAllFrames(1)*100,'%0.1f') ' & ' num2str(Recall_overAllFrames(1)*100,'%0.1f')])
        plotPRcurve(Recall_overAllFrames(1), Precision_overAllFrames(1), detectorName, reIdentifierName, useMutualOverlapFilter, useFalsePositiveClass);
        plotPRcurve(Recall_overAllFrames, Precision_overAllFrames, detectorName, reIdentifierName, useMutualOverlapFilter, useFalsePositiveClass);
    end

return,

function plotPRcurve(Precision_overAllFrames, Recall_overAllFrames, detectorName, reIdentifierName, useMutualOverlapFilter, useFalsePositiveClass)

    markersize = 20;
    linecolor = 'k';
    linestyle= '-';
    linewidth= 3.0;
    markerstyle = '.';
    if strcmp(detectorName,'GtAnnotationsClean')
        % default values, thich full black line
        markersize = 25;
        legendStr = ['MANUAL_c_l_e_a_n'];
    elseif strcmp(detectorName,'GtAnnotationsAll')
        markersize = 15;
        linewidth= 2.0;
        legendStr = ['MANUAL_a_l_l'];
    elseif ~useMutualOverlapFilter && ~useFalsePositiveClass
        markerstyle = 's';
        markersize = 5;
        linecolor = 'g';
        legendStr = ['DIRECT (FP OFF, OCC OFF)'];
    elseif useMutualOverlapFilter && ~useFalsePositiveClass        
        markerstyle = 'x';
        markersize = 10;
        linewidth= 2.0;
        linecolor = 'r';
        linestyle= '--';
        legendStr = ['FP OFF, OCC ON'];
    elseif ~useMutualOverlapFilter && useFalsePositiveClass
        markerstyle = 'o';
        markersize = 7;
        linewidth= 2.0;
        linecolor = 'b';
        linestyle= ':';
        legendStr = ['FP ON, OCC OFF'];
    elseif useMutualOverlapFilter && useFalsePositiveClass
        markerstyle = 'd';
        markersize = 7;
        linewidth= 2.0;
        linecolor = [1 0.65 0];
        linestyle= '-.';
        legendStr = ['FP ON, OCC ON'];
    end
    
    if length(Precision_overAllFrames) == 1
        linestyle = '';
        figure(839755), hold on,
    else
        figure,
    end
        
    % numberActiveDetections = sum(frameGTfull(:));

    %legendStr = [];%[int2str(numberActiveDetections) ' Active Detections'];
    eh = plot(Precision_overAllFrames*100,Recall_overAllFrames*100, ...
        [markerstyle linestyle],'Color',linecolor,'Linewidth',linewidth, ...
        'DisplayName',legendStr,'MarkerSize',markersize);
    % set(eh,'DisplayName',legendStr);
    axis([0,100,0,100]);
    xlabel('Recall (%)')
    ylabel('Precision (%)')
    legend('Location','SouthEast');
    title([reIdentifierName ' re-identifier Precision/Recall'])
    plotedit on
    hold off,
    
    % For PRpoints.pdf figure
    %set(gcf,'Position',[  269   404   489   182]);
    %axis([0,100,0,40]);
    %set(gcf,'color','w'); export_fig -painters -r600 -q101 PRpoints.pdf


return