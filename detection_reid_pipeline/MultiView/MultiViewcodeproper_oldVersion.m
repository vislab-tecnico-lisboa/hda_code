
declareGlobalVariables,

testCamera = unique([filteredTestStruct.camera]);
assert(length(testCamera)==1,'Expecting only one testCamera each time')

bGsPath = [thisDetectorDetectionsDirectory '/camera' num2str(testCamera,'%02d') '/Detections'];

oldLoad_Experiment_data,

Offline_Minh_Optimization,

ComputeSaveLoad_bGs,

clear results,    
xvalRuns  = 1;
nRun = 1;
% for nRun = 1:xvalRuns % xvalRuns % xvalRuns loaded from partition mat file
    % bG = bGs(:,:,nRun);
    s = medianSigmas(:,nRun); medianSigmasUsed = 1;
    
    % Computed and saved the bGs with sigmas = 1, and now load and reset bGs to
    % the desired sigmas
    run Change_bG_sigmas,

    run my_Optimization,
    
    galleryIndexes = find(Ymatrix(1,:) == 0);
%     [CMC AUC] = auroc_reid(estimatedLabelsold(:,galleryIndexes),Y_gt(:,galleryIndexes), DONTDOPLOT);

%     results(nRun,:) = CMC;
% end
onlyTestEstimatedLabels = estimatedLabelsold(:,l+1:end);
% Turn estimatedLabels into a ranked list of IDs
[Y,linearIDsRankedList] = sort(onlyTestEstimatedLabels,'descend');
rankedList = zeros(size(linearIDsRankedList));
for p_i = 1:length(unique_trainSpid)
    rankedList(linearIDsRankedList == p_i) = unique_trainSpid(p_i);
end
