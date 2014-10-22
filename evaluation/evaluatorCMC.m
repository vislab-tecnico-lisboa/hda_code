function evaluatorCMC()
% evaluatorCMC script

% There are pedestrians in the testCameras that aren't in the trainCameras,
% those, historically, have been removed. But 999 should not be removed if
% there is no FP class.

	declareGlobalVariables,

    trainingDataStructure = createTrainStructure(0);    
    unique_trainStruct_Pid = unique([trainingDataStructure.personId]);
    
    for testCamera = testCameras
        % Filter out test camera from training data structure
        % No need anymore, using trainCameras list to create the structure
        % trainDataStructNoTestCamera = trainingDataStructure([trainingDataStructure.camera] ~= testCamera);
        
        reIdsAndGtDirectory = [experimentDataDirectory sprintf('/camera%02d',testCamera) '/ReIdsAndGts' reIdentifierName ];

        reIdsAndGtMat = dlmread([reIdsAndGtDirectory '/allG.txt']);
        assert(min(reIdsAndGtMat(:,1)==testCamera + reIdsAndGtMat(:,1)==0),['This allG has samples not from this camera (' int2str(testCamera) ')?? Wtf?'])
        
        unique_testSamples_personIds = unique(reIdsAndGtMat(:,3));

        pIdofTestNotInTrain = setdiff(unique_testSamples_personIds,[unique_trainStruct_Pid 999]);
        
        % To plot Cumulative Matching Characteristic curve
        CM = zeros(1,length(unique([trainingDataStructure.personId])));
        FPs = 0;
        for testSampleI = 1:size(reIdsAndGtMat,1)
            testSample = reIdsAndGtMat(testSampleI,:);
            if min(testSample==zeros(size(testSample))) % if line is "empty" (all zeros) 
                continue,
            end
            GTid = testSample(3); 
            REIDrankList = testSample(4:end); 
            correctMatchRank = find(GTid == REIDrankList);
            
            if ~isempty(correctMatchRank)
                CM(correctMatchRank) = CM(correctMatchRank)+1;
            elseif max(GTid == pIdofTestNotInTrain)
                % pedestrian that only appears in this test camera (ergo
                % not in current training set)
            else
                % False positive without a False Positive class
                FPs = FPs + 1;
            end

        end
        % CMC is normalized to the number of test samples used
        numTestSamples = sum(CM) + FPs;
        CMC = cumsum(CM) / numTestSamples * 100;
        
        plotCMC(CMC, detectorName, reIdentifierName, reIdsAndGtMat, useMutualOverlapFilter, useFalsePositiveClass, testCamera);
    end    
    
return


function plotCMC(CMC, detectorName, reIdentifierName, reIdsAndGtMat, useMutualOverlapFilter, useFalsePositiveClass, testCamera)

    linecolor = 'k';
    linestyle= '-';
    linewidth= 3.0;
    if strcmp(detectorName,'GtAnnotationsClean')
        % default values, thich full black line
        legendStr = ['MANUAL_c_l_e_a_n'];
    elseif strcmp(detectorName,'GtAnnotationsAll')
        linewidth= 2.0;
        legendStr = ['MANUAL_a_l_l'];
    elseif ~useMutualOverlapFilter && ~useFalsePositiveClass
        linecolor = 'g';
        legendStr = ['DIRECT'];
    elseif useMutualOverlapFilter && ~useFalsePositiveClass        
        linecolor = 'r';
        linestyle= '--';
        legendStr = ['FP OFF, OCC ON'];
    elseif ~useMutualOverlapFilter && useFalsePositiveClass
        linecolor = 'b';
        linestyle= ':';
        legendStr = ['FP ON, OCC OFF'];
    elseif useMutualOverlapFilter && useFalsePositiveClass
        linecolor = [1 0.65 0];
        linestyle= '-.';
        legendStr = ['FP ON, OCC ON'];
    end
    legendStr = [legendStr ' cam' int2str(testCamera)];
        

    figure(839754), hold on,
    nAUC = sum(CMC)/length(CMC)
    % numberActiveDetections = sum(reIdsAndGtMat(:,1)~=0);
    % legendStr = [int2str(numberActiveDetections) ' Active Detections, nAUC ' num2str(nAUC,'%.2f') ' / 1st ' num2str(CMC(1),'%.2f') '%'];
    eh = plot(CMC,linestyle,'Color',linecolor,'Linewidth',linewidth);
    set(eh,'DisplayName',legendStr);
    axis([1,length(CMC),0,100]);
    xlabel('Rank Score')
    ylabel('Re-identification %')
    legend('Location','SouthEast');
    title([reIdentifierName ' re-identifier CMC'])
    plotedit on
    hold off,
    
    % To create a prettier pdf figure 
    %set(gcf,'color','w'); export_fig -painters -r600 -q101 6CMCs.pdf


return