%% Offline part of Minh Multi-View formulation
% part of code that only needs to be done once per experiment (the Kernel
% and derivatives of it need to be computed each time given the different
% feature matrixes for each run)

%% Paramethers to fine tune

% if ~exist('gI','var'),    gI = 10^(-7);    display('Set gI to 10^(-7)'), end
% if ~exist('gA','var'),    gA = 0.1;    display(['Set gA to ' num2str(gA)]), end
% % if ~exist('s1','var'),    s1 = 1;        display('Set s1 to 1'), end
% % if ~exist('s2','var'),    s2 = 0.1;        display(['Set s2 to' num2str(s1)]), end
% if ~exist('kernelType','var'), kernelType = 'Laplacian'; display(['Set kernelType to ' ]), end
% if ~exist('s','var'),  
%     for mit = 1:m
%         s(mit) = 1; 
%         fprintf(['Set s' int2str(mit) ' to ' num2str(s(mit)) ' ']),
%     end
%     display(' ')
% end

%% C: row-block matrix size (P,P*m), where each block Ck is the identity 
% matrik of size P 
% C*f = average of f's
Ck = eye(P);
C = sparse(1/m * repmat(Ck, 1,m));

%%

% thisped=ped(1,:); % used for Y_gt and Ymatrix

%allGT = GTandDetMatcher('detections');
%testPersonIDs = allGT(:,3)';
trainPersonIDs = [trainingDataStructure.personId];
linearTrainIDs = zeros(size(trainPersonIDs));
%linearTestIDs = zeros(size(testPersonIDs));
for p_i = 1:length(unique_trainSpid)
    linearTrainIDs(trainPersonIDs == unique_trainSpid(p_i)) = p_i;
    %linearTestIDs(testPersonIDs == unique_trainSpid(p_i)) = p_i;
end
% YGT = linearTestIDs; % labels of the testing samples

% size, P x l+u
%Y_gt = labels2vec([linearTrainIDs, linearTestIDs],P); 
Ymatrix = zeros(P,numSamples);
Ymatrix(:,1:l) = labels2vec([linearTrainIDs],P); 

% Y_gt: ground truth
% Y_gt = zeros(numClasses,numSamples);
% for pedNum=1:numClasses
%     for i=thisped(pedNum).run
%         Y_gt(:,i) = label2Ycollumn(pedNum,numClasses);
%     end
% end

% Ymatrix = zeros(P,numSamples);
% for pedNum=1:numClasses
%     for i=thisped(pedNum).run(thisped(pedNum).probes)
%         Ymatrix(:,i) = label2Ycollumn(pedNum,numClasses);
%     end
% end


%% re-order Y's and F's to have labeled samples first and unlabeled samples
% last
% unlabeledIndexes = Ymatrix(1,:)==0;
% Y_gt = [Y_gt(:,~unlabeledIndexes) Y_gt(:,unlabeledIndexes)];
% Ymatrix = [Ymatrix(:,~unlabeledIndexes) Ymatrix(:,unlabeledIndexes)];
% F = [F(~unlabeledIndexes, :); F(unlabeledIndexes,:)]; % Minh
% Fbody = [Fbody(~unlabeledIndexes, :); Fbody(unlabeledIndexes,:)]; % Minh

%% Y: vector size P*samples : concatenated label vectors, each label vector 
% of size P has -1 for negative and +1 for positive label for that
% class/pedestrian ID
Y=reshape(Ymatrix,size(Ymatrix,1)*size(Ymatrix,2),1);

%% Mm square matrix of size (m,m)
Mm = m*eye(m) - ones(m);

%% J: diagonal matrix with l entries at 1 and u entries at 0 (ordered in
% accordance to Y)
J = diag(abs(Ymatrix(1,:)));
