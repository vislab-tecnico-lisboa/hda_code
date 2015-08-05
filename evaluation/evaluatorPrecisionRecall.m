function evaluatorPrecisionRecall()

	declareGlobalVariables,
	
    loadImages = 0; % No need to load images, just using the training structure to figure out the training pedestrian IDs
    trainingDataStructure = createTrainStructure_loading_images_from_seq_files(loadImages); 

    for testCamera = testCameras
        
        % Checking the video length in frames
        seqFilesDirectory = [hdaRootDirectory '/hda_image_sequences_matlab'];
        %Set up image reading stuff
        seqName = sprintf('%s/camera%02d.seq',seqFilesDirectory, testCamera); 
        seqReader = seqIo( seqName, 'reader'); % Open the input image sequence
        info = seqReader.getinfo();
        TotalFrames = info.numFrames;
        
        % imagePath = [hdaRootDirectory '/hda_image_sequences_jpeg/camera' int2str(testCamera)];
        % imageNames = dir([imagePath '/*.jpeg']);
        % TotalFrames = length(imageNames);
        
        trainDataStructNoTestCamera = trainingDataStructure([trainingDataStructure.camera] ~= testCamera);
        unique_trainSpid = unique([trainDataStructNoTestCamera.personId]);
        nTrainPeds = length(unique_trainSpid);

        % Create test samples structure
        reIdsAndGtDirectory    = [experimentDataDirectory sprintf('/camera%02d/ReIdsAndGT_', testCamera) reIdentifierName];
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
            warning('off','MATLAB:DELETE:FileNotFound')
            delete(PrecRecFile)
            warning('on','MATLAB:DELETE:FileNotFound')
        end
        if exist(PrecRecFile,'file')
            load(PrecRecFile,'Precision_overAllFrames','Recall_overAllFrames'),
            cprintf('*blue',['Loaded file with Precision and Recall from ' PrecRecFile '\n'])
        else                
            wbr = waitbar(0, ['Precision/Recall on camera ' int2str(testCamera)]);
            Precision_overAllFrames = -ones(1,nTrainPeds);
            Recall_overAllFrames    = -ones(1,nTrainPeds);
            for R=1:nTrainPeds
                waitbar(R/nTrainPeds, wbr, ['Precision/Recall on camera ' int2str(testCamera) ', Rank ' int2str(R) '/' int2str(nTrainPeds)]);

                % Create framesShown matrix, which contains one line per pedestrian,
                % the lenght of the video, with 1 in the frames where the ReId classifier
                % detected and re-identified that pedestrian up to rank R, and 0 otherwise
                framesShown = sparse(false(length(unique_trainSpid),TotalFrames));
                for iDet = 1:length(testSamplesStructure)
                    for iR = 1:R
                        pedIndex = find(testSamplesStructure(iDet).rankList(iR)==unique_trainSpid);
                        framesShown(pedIndex,testSamplesStructure(iDet).frame+1) = 1;
                    end
                end

                % Use the output of gtAndDetMatcher.m 
                % to generate frameGTfull (we need the ground truth person Ids)
                GTreIdsAndGtMat=dlmread([reIdsAndGtDirectory '/allG.txt']);

                % For each ped in the ground truth, put a 1 in the frame
                % where he appears in matrix frameGTfull (P x Frame)
                frameGTfull = false(length(unique_trainSpid),TotalFrames);
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
                for pedIndex=1:length(unique_trainSpid_noFPs)
                    shownVect = framesShown(pedIndex,:);
                    assert(sum(size(shownVect) ~= [1 TotalFrames])==0,'Not the expected size? transpose?')

                    PSFs(pedIndex) = sum(shownVect & frameGTfull(pedIndex,:));
                    FPSFs(pedIndex) = sum(shownVect & ~frameGTfull(pedIndex,:));
                    shownpedsAll(pedIndex) = sum(shownVect);
                end

                Precision_overAllFrames(R) = 1 - sum(FPSFs)/sum(shownpedsAll);
                Recall_overAllFrames(R) =         sum(PSFs)/sum(frameGTfull(:));
                assert(sum(PSFs)<=sum(frameGTfull(:)), 'Recall greater than 1? Tha F?')

            end
            close(wbr);
            save(PrecRecFile,'Precision_overAllFrames','Recall_overAllFrames'),
            cprintf('*[1,0,1]',['Saved file with Precision and Recall to ' PrecRecFile '\n'])
        end
        % Display values to build Table 2 of HDA+ paper
        Fscore = 2*(Precision_overAllFrames.*Recall_overAllFrames) ./ (Precision_overAllFrames+Recall_overAllFrames);
        display('Fscore Prec   Rec')
        display(['  ' num2str(Fscore(1)*100,'%0.1f') ' & ' num2str(Precision_overAllFrames(1)*100,'%0.1f') ' & ' num2str(Recall_overAllFrames(1)*100,'%0.1f')])

        % Make Fig. 7 of HDA+ paper, only plot Rank 1 points, in a single
        % figure
        plotPRcurve(Recall_overAllFrames(1), Precision_overAllFrames(1), detectorName, reIdentifierName, useMutualOverlapFilter, useFalsePositiveClass, testCamera);

        % Plot a Precision/Recall curve for all ranks
        plotPRcurve(Recall_overAllFrames, Precision_overAllFrames, detectorName, reIdentifierName, useMutualOverlapFilter, useFalsePositiveClass, testCamera);
    end

return,

function plotPRcurve(Precision_overAllFrames, Recall_overAllFrames, detectorName, reIdentifierName, useMutualOverlapFilter, useFalsePositiveClass, testCamera)

    markersize = 20;
    linecolor = 'k';
    linestyle= '-';
    linewidth= 3.0;
    markerstyle = '.';
    if strcmp(detectorName,'GtAnnotationsClean')
        % default values, thich full black line
        markersize = 25;
        legendStr = 'MANUAL_c_l_e_a_n';
    elseif strcmp(detectorName,'GtAnnotationsAll')
        markersize = 15;
        linewidth= 2.0;
        legendStr = 'MANUAL_a_l_l';
    elseif ~useMutualOverlapFilter && ~useFalsePositiveClass
        markerstyle = 's';
        markersize = 5;
        linecolor = 'g';
        legendStr = 'DIRECT (FP OFF, OCC OFF)';
    elseif useMutualOverlapFilter && ~useFalsePositiveClass        
        markerstyle = 'x';
        markersize = 10;
        linewidth= 2.0;
        linecolor = 'r';
        linestyle= '--';
        legendStr = 'FP OFF, OCC ON';
    elseif ~useMutualOverlapFilter && useFalsePositiveClass
        markerstyle = 'o';
        markersize = 7;
        linewidth= 2.0;
        linecolor = 'b';
        linestyle= ':';
        legendStr = 'FP ON, OCC OFF';
    elseif useMutualOverlapFilter && useFalsePositiveClass
        markerstyle = 'd';
        markersize = 7;
        linewidth= 2.0;
        linecolor = [1 0.65 0];
        linestyle= '-.';
        legendStr = 'FP ON, OCC ON';
    end
    legendStr = [legendStr ' cam' int2str(testCamera)];

    if length(Precision_overAllFrames) == 1
        linestyle = '';
        figure(839755), hold on,
    else
        figure(675), hold on,
    end
        
    plot(Precision_overAllFrames*100,Recall_overAllFrames*100, ...
        [markerstyle linestyle],'Color',linecolor,'Linewidth',linewidth, ...
        'DisplayName',legendStr,'MarkerSize',markersize);
    axis([0,100,0,100]);
    xlabel('Recall (%)')
    ylabel('Precision (%)')
    legend('Location','SouthEast');
    title([reIdentifierName ' re-identifier Precision/Recall'])
    plotedit on
    hold off,
    
    %% Create PRpoints.pdf figure
    % set(gcf,'Position',[  269   404   489   182]);
    % axis([0,100,0,40]);
    % set(gcf,'color','w'); export_fig -painters -r600 -q101 PRpoints.pdf

return
