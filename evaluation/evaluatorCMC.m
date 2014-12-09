function evaluatorCMC(mode, allGs)
%evaluatorCMC Create and plot a CMC curve.
% 
%   evaluatorCMC() plots CMC curves with color and style of paper (thick
%   full black for MANUALclean, thin full black for MANUALall, full green
%   for DIRECT, dashed red for FP OFF OCC ON, dotted blue for FP ON OCC OFF, 
%   and dash-dot orange for FP ON, OCC ON.
%
%   evaluatorCMC('default') is the same as evaluatorCMC().
% 
%   evaluatorCMC('repository') plots CMC curves with color and style for
%   the repository of results. Currently this means full black for NN HSV [1], 
%   dashed black for NN MSCR [2], and full blue for SDALF [3]. You should
%   choose and add your prefered color and style for your results below.
%   This mode of operation also saves the fig file to the respective
%   experiment_data folder and opens the respective repository of results
%   figure (to make it easy to copy paste from one fig to another).
%   
%   evaluatorCMC('development') plots CMCs with random style and color.
%   
% 
%   [1] Dario Figueira, Matteo Taiana, Athira Nambiar, Jacinto Nascimento, Alexandre Bernardino, ”The HDA+ data set for research on fully automated re-identification systems“, in ECCV workshop, 2014.
%   [2] Forssen, P.-E., “Maximally Stable Colour Regions for Recognition and Matching,” in Computer Vision and Pattern Recognition (CVPR), 2007.
%   [3] M. Farenzena, L. Bazzani, A. Perina, V. Murino, and M. Cristani, ”Person Re-identification by Symmetry-Driven Accumulation of Local Features”  In IEEE Conference on Computer Vision and Pattern Recognition (CVPR), 2010

if ~exist('mode','var')
    mode = 'default';
end


% There are pedestrians in the testCameras that aren't in the trainCameras,
% those, historically, have been removed. But 999 should not be removed if
% there is no FP class.

declareGlobalVariables,

[trainingDataStructure, allTrainingDataStructure] = createTrainStructure(0);
if strcmp(mode,'all')
    unique_trainStruct_Pid = unique([allTrainingDataStructure.personId]);
else
    unique_trainStruct_Pid = unique([trainingDataStructure.personId]);
end

for testCamera = testCameras
    % Filter out test camera from training data structure
    % No need anymore, using trainCameras list to create the structure
    % trainDataStructNoTestCamera = trainingDataStructure([trainingDataStructure.camera] ~= testCamera);
    
    if strcmp(mode,'all')
        reIdsAndGtMat = allGs;
    else
        reIdsAndGtDirectory = [experimentDataDirectory sprintf('/camera%02d',testCamera) '/ReIdsAndGT_' reIdentifierName ];
        reIdsAndGtMat = dlmread([reIdsAndGtDirectory '/allG.txt']);
        assert(min(reIdsAndGtMat(:,1)==testCamera + reIdsAndGtMat(:,1)==0),['This allG has samples not from this camera (' int2str(testCamera) ')?? Wtf?'])
    end
    
    
    unique_testSamples_personIds = unique(reIdsAndGtMat(:,3));
    
    pIdofTestNotInTrain = setdiff(unique_testSamples_personIds,[unique_trainStruct_Pid 999]);
    
    % To plot Cumulative Matching Characteristic curve
    CM = zeros(1,length(unique_trainStruct_Pid));
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
            error('Test peds not in the training set of it''s training cameras should have been filtered in filterOccluded')
            % pedestrian that only appears in this test camera (ergo
            % not in current training set and should be ignored)
        else
            %if strcmp(mode,'all')
            %    if strcmp(detectorName,'AcfInria')
            %        error('with  FP this is not enough'),
            %    end
            %    % if on the 'all' mode there are test samples that are not in
            %    % the training set of that camera, and so should be ignored
            %    continue,
            %end
            % False positive without a False Positive class
            FPs = FPs + 1;
        end
        
    end
    % CMC is normalized to the number of test samples used
    numTestSamples = sum(CM) + FPs;
    CMC = cumsum(CM) / numTestSamples * 100;
    
    plotCMC(CMC, testCamera, mode);
end

return


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
    legendStr = ['DIRECT (FP OFF, OCC OFF)'];
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
% TODO: open here the saved figure in repository of results, so new line is
% automatically added to figure?

nAUC = sum(CMC)/length(CMC)
% numberActiveDetections = sum(reIdsAndGtMat(:,1)~=0);
% legendStr = [int2str(numberActiveDetections) ' Active Detections, nAUC ' num2str(nAUC,'%.2f') ' / 1st ' num2str(CMC(1),'%.2f') '%'];
eh = plot(CMC,linestyle,'Color',linecolor,'Linewidth',linewidth);
axis([1,length(CMC),0,100]);
xlabel('Rank Score')
ylabel('Re-identification %')
legend('Location','SouthEast');
plotedit on

if strcmp(mode,'default')
    % Default colors and style used in the paper, one color and style
    % per experiment
    title([reIdentifierName ' re-identifier CMC'])
    set(eh,'DisplayName',legendStr);
    
elseif strcmp(mode,'repository') || strcmp(mode,'all')
    % Choose a color and style for your algorithm results in the public
    % repository http://vislab.isr.ist.utl.pt/repository-of-results/
    
    title([legendStr])
    
    % Substitute 'NN HSV [1]' with your desired legend string
    set(eh,'DisplayName',['[1] NN HSV (' num2str(CMC(1),'%04.1f') '% ; ' num2str(nAUC,'%0.1f') '%)']);
    % Substitute 'k' with your desired line color
    set(eh,'Color','k');
    % Substitute '-' with your desired line style
    set(eh,'linestyle','-');
    
    % Code to plot multiple algorithm legends
    if strcmp(reIdentifierName, 'BhattacharryaNNReId')
        set(eh,'DisplayName',['(' num2str(CMC(1),'%04.1f') '% ; ' num2str(nAUC,'%0.1f') '%) NN HSV [1]']);
        set(eh,'linestyle','-');
        set(eh,'Color','k');
    elseif strcmp(reIdentifierName, 'MSCR_NN_ReId')
        set(eh,'DisplayName',['(' num2str(CMC(1),'%04.1f') '% ; ' num2str(nAUC,'%0.1f') '%) NN MSCR [2]']);
        set(eh,'linestyle','--');
        set(eh,'Color','k');
    elseif strcmp(reIdentifierName, 'SDALF_ReId')
        set(eh,'DisplayName',['(' num2str(CMC(1),'%04.1f') '% ; ' num2str(nAUC,'%0.1f') '%) SDALF [3]']);
        set(eh,'linestyle','-');
        set(eh,'Color','b');
    elseif strcmp(reIdentifierName, 'MultiViewold_BVT_HSV_Lab_MR8_LBP')
        set(eh,'DisplayName',['(' num2str(CMC(1),'%04.1f') '% ; ' num2str(nAUC,'%0.1f') '%) MultiView [4]']);
        set(eh,'linestyle','--');
        set(eh,'Color',[1 0.5 0.5]);
    end
    hold off,    
    
    Path_for_images = [experimentDataDirectory sprintf('/camera%02d', testCamera) ];
    set(gcf,'color','w'); export_fig('-painters','-r150','-q101',[Path_for_images '/' 	 '.png'])
    saveas(gcf,[Path_for_images '/' legendStr], 'fig')
    
    open([hdaRootDirectory '/hda_code/Repository of Results/' legendStr '.fig'])
    plotedit on

elseif strcmp(mode,'development')
    title([legendStr])
    set(eh,'DisplayName',['(' num2str(CMC(1),'%04.1f') '% ; ' num2str(nAUC,'%0.1f') '%) ' featureExtractionName ]);
    lineStyles={'-','--','-.',':'};
    set(eh,'linestyle',lineStyles{randi(length(lineStyles))});
    numberOfColors = 10;
    cmap = hsv(numberOfColors);
    set(eh,'Color',cmap(randi(numberOfColors),:));    
            
end

% To create a prettier pdf figure
%set(gcf,'color','w'); export_fig -painters -r600 -q101 6CMCs.pdf


return