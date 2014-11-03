function evaluatorCMC(mode)
% evaluatorCMC script

if ~exist('mode','var')
    mode = 'default';
end


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
    
    reIdsAndGtDirectory = [experimentDataDirectory sprintf('/camera%02d',testCamera) '/ReIdsAndGT_' reIdentifierName ];
    
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
    
    %         plotCMC(CMC, detectorName, reIdentifierName, reIdsAndGtMat, useMutualOverlapFilter, useFalsePositiveClass, testCamera);
    plotCMC(CMC, testCamera, mode);
end

return


% function plotCMC(CMC, detectorName, reIdentifierName, reIdsAndGtMat, useMutualOverlapFilter, useFalsePositiveClass, testCamera)
function plotCMC(CMC, testCamera, mode)

if ~exist('mode','var')
    mode = 'default';
end
declareGlobalVariables,

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
% TODO: put here open saved figure in repository of results

nAUC = sum(CMC)/length(CMC)
% numberActiveDetections = sum(reIdsAndGtMat(:,1)~=0);
% legendStr = [int2str(numberActiveDetections) ' Active Detections, nAUC ' num2str(nAUC,'%.2f') ' / 1st ' num2str(CMC(1),'%.2f') '%'];
eh = plot(CMC,linestyle,'Color',linecolor,'Linewidth',linewidth);
axis([1,length(CMC),0,100]);
xlabel('Rank Score')
ylabel('Re-identification %')
legend('Location','SouthEast');

if strcmp(mode,'default')
    % Default colors and style used in the paper, one color and style
    % per experiment
    title([reIdentifierName ' re-identifier CMC'])
    set(eh,'DisplayName',legendStr);
    
elseif strcmp(mode,'repository')
    % Choose a color and style for your algorithm results in the public
    % repository http://vislab.isr.ist.utl.pt/repository-of-results/
    
    title([legendStr])
    
    % Substitute 'NN HSV [1]' with your desired legend string
    set(eh,'DisplayName','NN HSV [1]');
    % Substitute 'k' with your desired line color
    set(eh,'Color','k');
    % Substitute '-' with your desired line style
    set(eh,'linestyle','-');
    
    % Code to plot multiple algorithm legends
    if strcmp(reIdentifierName, 'BhattacharryaNNReId')
        set(eh,'DisplayName','NN HSV [1]');
        set(eh,'linestyle','-');
        set(eh,'Color','k');
    elseif strcmp(reIdentifierName, 'MSCR_NN_ReId')
        set(eh,'DisplayName','NN MSCR [2]');
        set(eh,'linestyle','--');
        set(eh,'Color','k');
    end
    
    
    Path_for_images = [experimentDataDirectory sprintf('/camera%02d', testCamera) ];
    set(gcf,'color','w'); export_fig('-painters','-r300','-q101',[Path_for_images '/' legendStr '.png'])
    saveas(gcf,[Path_for_images '/' legendStr], 'fig')
end

plotedit on
hold off,

% To create a prettier pdf figure
%set(gcf,'color','w'); export_fig -painters -r600 -q101 6CMCs.pdf


return