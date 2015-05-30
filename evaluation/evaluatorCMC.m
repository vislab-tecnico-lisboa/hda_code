function CMC = evaluatorCMC(mode, allGs)
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

declareGlobalVariables, % uses testCameras

% [trainingDataStructure, allTrainingDataStructure] = createTrainStructure(0);
[trainingDataStructure, allTrainingDataStructure] = createTrainStructure_loading_images_from_seq_files(0);
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
    %     CM = zeros(1,length(unique_trainStruct_Pid));
    %     FPs = 0;
    %     for testSampleI = 1:size(reIdsAndGtMat,1)
    %         testSample = reIdsAndGtMat(testSampleI,:);
    %         if min(testSample==zeros(size(testSample))) % if line is "empty" (all zeros)
    %             continue,
    %         end
    %         GTid = testSample(3);
    %         REIDrankList = testSample(4:end);
    %         correctMatchRank = find(GTid == REIDrankList);
    %
    %         if ~isempty(correctMatchRank)
    %             CM(correctMatchRank) = CM(correctMatchRank)+1;
    %         elseif max(GTid == pIdofTestNotInTrain)
    %             error('Test peds not in the training set of it''s training cameras should have been filtered in filterOccluded')
    %             % pedestrian that only appears in this test camera (ergo
    %             % not in current training set and should be ignored)
    %         else
    %             %if strcmp(mode,'all')
    %             %    if strcmp(detectorName,'AcfInria')
    %             %        error('with  FP this is not enough'),
    %             %    end
    %             %    % if on the 'all' mode there are test samples that are not in
    %             %    % the training set of that camera, and so should be ignored
    %             %    continue,
    %             %end
    %             % False positive without a False Positive class
    %             FPs = FPs + 1;
    %         end
    %
    %     end
    % Vectorization of the above code
    indNotZero = reIdsAndGtMat(:,1) ~= 0;
    GTids = reIdsAndGtMat(indNotZero,3);
    REIDrankLists = reIdsAndGtMat(indNotZero,4:end);
    [I, correctMatchRanks] = find(repmat(GTids,1,size(REIDrankLists,2)) == REIDrankLists);
    CMvect = hist(correctMatchRanks,1:length(unique_trainStruct_Pid));
    FPsvect = sum(indNotZero) - sum(CMvect);
    %     in(CM-CMvect)
    %     assert(max(CM-CMvect)==0,'Hmm, the vectorization isn''t consistent with the above code')
    
    % CMC is normalized to the number of test samples used
    numTestSamples = sum(CMvect) + FPsvect;
    CMC = cumsum(CMvect) / numTestSamples * 100;
    
    
    if ~strcmp(mode,'silent')
        plotCMC(CMC, testCamera, mode, numTestSamples);
%         plotCMC(CMC, testCamera, 'development');
    end
    
%     rabo = hist([trainingDataStructure.personId],1:max([trainingDataStructure.personId]));
%     % CMC computation just for a select few peds.
%     for ped = unique_trainStruct_Pid
%         indPedInTest = find(reIdsAndGtMat(:,3) == ped);
%         if ~isempty(indPedInTest)
%             GTids = reIdsAndGtMat(indPedInTest,3);
%             REIDrankLists = reIdsAndGtMat(indPedInTest,4:end);
%             [I, correctMatchRanks] = find(repmat(GTids,1,size(REIDrankLists,2)) == REIDrankLists);
%             CMped = hist(correctMatchRanks,1:length(unique_trainStruct_Pid));
%             
%         end
%         
%     end
end

return


function plotCMC(CMC, testCamera, mode, numTestSamples)

if ~exist('mode','var')
    mode = 'default';
end
declareGlobalVariables,

linecolor = 'k';
linestyle= '-';
linewidth= 3.0;
if strcmp(detectorName,'GtAnnotationsClean')
    % default values, thich full black line
    experiment = ['MANUAL_c_l_e_a_n'];
elseif strcmp(detectorName,'GtAnnotationsAll')
    linewidth= 2.0;
    experiment = ['MANUAL_a_l_l'];
elseif strncmp(detectorName,'Toy',3) 
    experiment = detectorName;
elseif ~useMutualOverlapFilter && ~useFalsePositiveClass
    linecolor = 'g';
    experiment = ['DIRECT (FP OFF, OCC OFF)'];
elseif useMutualOverlapFilter && ~useFalsePositiveClass
    linecolor = 'r';
    linestyle= '--';
    experiment = ['FP OFF, OCC ON'];
elseif ~useMutualOverlapFilter && useFalsePositiveClass
    linecolor = 'b';
    linestyle= ':';
    experiment = ['FP ON, OCC OFF'];
elseif useMutualOverlapFilter && useFalsePositiveClass
    linecolor = [1 0.65 0];
    linestyle= '-.';
    experiment = ['FP ON, OCC ON'];
end
if strcmp(mode,'all')
    legendStr = [experiment ', All cameras'];
    figure(411), hold on,
else
    legendStr = [experiment ' cam' int2str(testCamera)];
    figure(testCamera), hold on,
end


nAUC = sum(CMC)/length(CMC);

if length(CMC) >= 5
    percentages = ['(' num2str(CMC(1),'%04.1f') '% ; ' num2str(CMC(5),'%04.1f') '% ; ' num2str(nAUC,'%0.1f') '%) '];
else
    percentages = ['(' num2str(CMC(1),'%04.1f') '% ; ' num2str(nAUC,'%0.1f') '%) '];
end    

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
    set(eh,'DisplayName',[percentages legendStr]);
    
elseif strcmp(mode,'repository') 
    % Choose a color and style for your algorithm results in the public
    % repository http://vislab.isr.ist.utl.pt/repository-of-results/
    
    title(legendStr)
    
    % Substitute 'Algorithm [?]' with your desired legend string
    set(eh,'DisplayName',    [percentages 'Algorithm [?]']);
    % Substitute 'k' with your desired line color
    set(eh,'Color','k');
    % Substitute '-' with your desired line style
    set(eh,'linestyle','-');
    % Substitute 3.0 with your desired line width
    set(eh,'Linewidth',3.0);
    
    % Code to plot multiple algorithm legends
    if strcmp(reIdentifierName, 'BhattacharryaNNReId')
        set(eh,'DisplayName',[percentages 'NN HSV [1]']);
        set(eh,'linestyle','-');
        set(eh,'Color','k');
    elseif strcmp(reIdentifierName, 'MSCR_NN_ReId')
        set(eh,'DisplayName',[percentages 'MSCR [2]']);
        set(eh,'linestyle','--');
        set(eh,'Color','k');
    elseif strcmp(reIdentifierName, 'SDALF_ReId')
        set(eh,'DisplayName',[percentages 'SDALF [3]']);
        set(eh,'linestyle','-');
        set(eh,'Color','b');
    elseif strcmp(reIdentifierName, 'MultiViewold_BVT_HSV_Lab_MR8_LBP')
        set(eh,'DisplayName',[percentages 'MultiView [4]']);
        set(eh,'linestyle','--');
        set(eh,'Color',[1 0.5 0.5]);
    end
    hold off,
    
    Path_for_images = [experimentDataDirectory sprintf('/camera%02d', testCamera) ];
    set(gcf,'color','w'); export_fig('-painters','-r150','-q101',[Path_for_images '/' 	 '.png'])
    try
    saveas(gcf,[Path_for_images '/' legendStr], 'fig')
    catch me
        warning(['Figure.fig was not saved, ' me.message]),
    end 
       
    
    open([hdaRootDirectory '/hda_code/Repository of Results/' legendStr '.fig'])
    plotedit on
    
elseif strcmp(mode,'development') || strcmp(mode,'all')
    maxTrainingSample = '';
    ind = strfind(trainingSetPath,'hda_sample_train_data_max');
    if ~isempty(ind)
        maxTrainingSample = [' max ' int2str(sscanf(trainingSetPath(ind:end),'hda_sample_train_data_max%dsamples_v1')) ' training samples'];
    end
    ind = strfind(featureExtractionName,'extract');
    if ~isempty(ind)
        featureExtractionNameToPrint = [' ' featureExtractionName(ind+7:end)]; 
    else
        featureExtractionNameToPrint = [' ' featureExtractionName];         
    end
    if strcmp(featureExtractionMethod,'4parts')
        featureExtractionMethod_toPrint = '';
    else
        featureExtractionMethod_toPrint = [' ' featureExtractionMethod];
    end
    title([legendStr ' ' int2str(numTestSamples) ' samples']),
    set(eh,'DisplayName',[percentages reIdentifierName featureExtractionNameToPrint featureExtractionMethod_toPrint maxTrainingSample]);
    lineStyles={'-','--','-.',':'};
    set(eh,'linestyle',lineStyles{randi(length(lineStyles))});
    numberOfColors = 10;
    cmap = hsv(numberOfColors);
    set(eh,'Color',cmap(randi(numberOfColors),:));
    linewidths= 1:3;
    set(eh,'Linewidth',linewidths(randi(length(linewidths))));    
    
end

% To create a prettier pdf figure
%set(gcf,'color','w'); export_fig -painters -r600 -q101 6CMCs.pdf

set(gcf,'Position', [ 361   403   313   262])
xlabel('Rank Score')
ylabel('Re-identification %')
axis([1,25,0,100]);
plotedit on 

return






