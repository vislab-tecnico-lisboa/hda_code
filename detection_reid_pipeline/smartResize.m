function resizedImage = smartResizeImageToBodyPartMaskSize(image,H,W,bord,dontload)
% dataset = FloadData(expName,namefile)
%
% Load and resize the images from the given directory and list and
% save the dataset in the given namefile and return it
% 
% output:
%  saved file in MAT/_DATASETS_/dataset_ expName _fX.mat
%  - dataset: all dataset images, all same size
%

global dset,

% if the border to ignore param is not given, then don't use it
if nargin < 6, bord = 0; end

if ~exist('dontload','var')
    dontload = 0;
end

nImages = length([dset.global]);

targetRatio = H/W;

if exist(namefile,'file') && isfield(load(namefile),'datasetOriginal') && ~dontload
    load(namefile);
    display([' - Dataset loaded from file ' namefile '.']);
else
    fprintf('Dataset loading...');
    hwait = waitbar(0,'LOADING dataset...');
    
    % w = warning('query','last')
    % id = w.identifier;
    warning('off','MATLAB:intConvertOverflow'),
    warning('off','MATLAB:intConvertNonIntVal'),
    for ii = 1:nImages
        img = imread(strcat(imgDir,'/',imgFiles(ii).name));
        
        % check if we need to crop the borders
        if bord > 0
            img = img(bord+1:end-bord,bord+1:end-bord,:);
        end
        
%         figure(199);
%         bigsubplot(1,3,1,1); imagesc(img); axis equal; axis off;
%         bigsubplot(1,3,1,2); imagesc(imresize(img,[H,W])); axis equal; axis off;
        
        [hei,wid,chs] = size(img);
        thisRatio = hei/wid;
        
        if thisRatio > targetRatio
            % image is short on width, pad
            % width
            pad = hei / targetRatio - wid;
            img = padarray(img,[0 round(pad/2) 0],'replicate','both');
        elseif thisRatio < targetRatio
            % too FAT, padding height

            pad = wid * targetRatio - hei;
            img = padarray(img,[round(pad/2) 0 0],'replicate','both');
        end
        
        datasetOriginal{ii} = img;
        img = imresize(img,[H,W]);
        dataset{ii} = img;
        waitbar(ii/nImages,hwait);
    end
    warning('on','MATLAB:intConvertOverflow'),
    warning('on','MATLAB:intConvertNonIntVal'),
    close(hwait);
    save(namefile,'dataset', 'datasetOriginal');
    fprintf('OK.') 
    display(['Saved to ' namefile ]);
end
varargout{1} = datasetOriginal;

for i=1:length(datasetOriginal)
   sizes(i,:) = size(datasetOriginal{i});
end
%[Y,I] = max(sizes)

