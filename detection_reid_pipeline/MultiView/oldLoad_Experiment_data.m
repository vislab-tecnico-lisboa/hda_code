% %% Computer Specific
% if ~exist('ComputerSpecificPaths.m','file')
%     display('Computer specific variables: (change them to suit your machine)')
%     display('Set MATpathCommited to the path where the MAT folder is (with all the datasets and masks)')
%     display('addpath the path where the bin folder is, with all the generic code (such as label2Ycollumn)')
% end
% % MATpathCommited = 'C:/Users/DFigueira/Desktop/Work/CPSbmvc11/MAT/';
% % addpath('C:/Users/DFigueira/Desktop/Work/bin') % for label2Ycollumn
% run ComputerSpecificPaths,

%% Static Variables
DONTDOPLOT = 0;
DOPLOT = 1;

%% Load_Experiment_data
% 
% 1) Load each view's F matrix into the cell matrix AllFMatrixMviews{nRun,view}
%
% 2) Load partition's ped structure, to create Y_gt and Ymatrix label matrixes
% in Offline_Minh_Optimization.m.
%   Both the .run and .probes structure fields are used
% 


unique_trainSpid = unique([trainingDataStructure.personId]);

l = length(trainingDataStructure); % # labeled samples
u = sum(filteredCropsMat(:,7));    % # unlabeled samples
m = length(viewlist);              % # of views
P = length(unique_trainSpid);      % # of classes, i.e., length of the output vector

clear AllFMatrixMviews, % used to compute m
for mIt = 1:m
    F = [lstack{mIt}, ustack{mIt}]';
    AllFMatrixMviews{1,mIt} = F;
end
% warning(['TODO: CHECK IF F (' int2str(size(F)) ') IS SUPPOSED TO BE TRANSPOSE OR SOMETHING'])

%%
numClasses = P;

% P=numClasses;
% if ~exist('AllFMatrixMviews','var') %backwards compatibility
%     m=2;
% else
%     m=size(AllFMatrixMviews,2);
% end

% l=0; u=0;
% for i=1:numClasses % for all peds
%     u = u + length(ped(1,i).gallery); % unlabeled samples (gallery)
%     l = l + length(ped(1,i).probes); % labeled samples (probes)
% end
numSamples = u+l;

assert(numSamples > numClasses, 'something is wrong'); % something is wrong otherwise

display([' numSamples=' int2str(numSamples) ' P(numClasses)=' int2str(P) ...
    ' m(views)=' int2str(m) ... 
    ' u=' int2str(u) ' l=' int2str(l) ])
display(' ')