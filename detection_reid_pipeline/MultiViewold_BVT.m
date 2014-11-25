function rankedList = MultiViewold_BVT(trainingDataStructure,filteredTestStruct, filteredCropsMat)

% Load your data

viewlist = [1 ];

lfeatures = [trainingDataStructure.feature];
lBVTstack = [lfeatures];
% lHSVstack = [lfeatures.HSV];
% lLabstack = [lfeatures.Lab];
% lMR8stack = [lfeatures.MR8];
% lLBPstack = [lfeatures.LBP];

ufeatures = [filteredTestStruct.feature];
uBVTstack = [ufeatures];
% uHSVstack = [ufeatures.HSV];
% uLabstack = [ufeatures.Lab];
% uMR8stack = [ufeatures.MR8];
% uLBPstack = [ufeatures.LBP];

lstack = {lBVTstack};
ustack = {uBVTstack};
% lstack = {lBVTstack, lHSVstack, lLabstack, lMR8stack, lLBPstack};
% ustack = {uBVTstack, uHSVstack, uLabstack, uMR8stack, uLBPstack};


% Set PARAMETERS
params_mv.gA = 10^-5;  % RKHS regularization
params_mv.gB = 10^-6;  % between-view regularization
params_mv.gW = 10^-6;  % within-view regularization
% vector to build the matrix C (length of the list of views)
params_mv.c  = ones(length(viewlist),1)/length(viewlist); % uniform weighting to build the matrix C  
params_mv.Laplacian.GraphNormalize = 1; % parameter to compute the laplacian

%% MultiView code proper
MultiViewcodeproper_oldVersion,


