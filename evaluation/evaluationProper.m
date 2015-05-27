%% Evaluation code, CMC, Confusion Matrix, Precision/Recall

% Evaluates and plots a CMC curve
% mode = 'repository'
% evaluatorCMC(mode);
evaluatorCMC('development'); % Options: 'repository' 'development'
% evaluatorCMC('repository'); % Options: 'repository' 'development'

% Confusion Matrix
% trainingDataStructure = createTrainStructure(0);
% unique_trainSpid = unique([trainingDataStructure.personId]);
% testCamera = testCameras;
% reIdsAndGtDirectory = [experimentDataDirectory sprintf('/camera%02d',testCamera) '/ReIdsAndGT_' reIdentifierName ];    
% reIdsAndGtMat = dlmread([reIdsAndGtDirectory '/allG.txt']);
% Conf = confusionmat(reIdsAndGtMat(:,3),reIdsAndGtMat(:,4));
% for p_i = 1:length(unique_trainSpid)
%     linearTrainIDs(reIdsAndGtMat(:,3) == unique_trainSpid(p_i)) = p_i;
%     linearTestIDs (reIdsAndGtMat(:,4) == unique_trainSpid(p_i)) = p_i;
% end
% Conf = confusionmat(linearTrainIDs,linearTestIDs);
% % Conf = confusionmat(int2str(reIdsAndGtMat(:,3)),int2str(reIdsAndGtMat(:,4)));
% figure,bigsubplot(1,1,1,1)
% imshow(Conf/max(Conf(:)))
% colormap('default')
% colorbar


% Evaluates and plots a Precision-Recall curve
% evaluatorPrecisionRecall();
