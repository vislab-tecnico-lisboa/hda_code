function [subImage, image] = getFrameAndCrop(testCamera, frame, bb)

declareGlobalVariables,

%Set up image reading stuff
seqFilesDirectory = [hdaRootDirectory '/hda_image_sequences_matlab'];
seqName = sprintf('%s/camera%02d.seq',seqFilesDirectory, testCamera); %MATTEO TODO CHANGE CAM TO CAMERA
seqReader = seqIo( seqName, 'reader'); % Open the input image sequence
%Read the image
seqReader.seek(frame);
image = seqReader.getframe();
seqReader.close(); 

if exist('bb','var')
    % and crop
    [nRows,nCols,nPags] = size(image);
    x1 = max(round(bb(1)),1);
    y1 = max(round(bb(2)),1);
    x2 = min(round(bb(1)+bb(3)),nCols);
    y2 = min(round(bb(2)+bb(4)),nRows);
    subImage=image( y1:y2, x1:x2, : );
else
    subImage = [];
end