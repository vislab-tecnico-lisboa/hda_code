function showFrameAndBBs(cam, frame)

% error('UNDER CONSTRUCTION')

declareGlobalVariables,

%Read GT file (VBB)
GTName = [hdaRootDirectory '/hda_annotations' sprintf('/cam%02d.txt',cam)];
GTMat = vbb('vbbLoadTxt',GTName);

%Set up image reading stuff
seqFilesDirectory = [hdaRootDirectory '/hda_image_sequences_matlab'];
seqName = sprintf('%s/camera%02d.seq',seqFilesDirectory, cam); %MATTEO TODO CHANGE CAM TO CAMERA
seqReader = seqIo( seqName, 'reader'); % Open the input image sequence
%Read the image
seqReader.seek(frame);
image = seqReader.getframe();
seqReader.close(); 

figure(2356),imshow(image);

%Select the GT data for this image
gt=GTMat.objLists{1,frame+1};
for gtId=1:size(gt,2)
    BB=gt(1,gtId).pos;

    hold on,
    rectangle('Position', [BB(1) BB(2) BB(3) BB(4)], 'EdgeColor','r','LineWidth',5),
    %     rectangle('Position', dets(detId,1:4), 'EdgeColor','g','LineWidth',5),

    label = GTMat.objLbl{1,gt(1,gtId).id};
    text(BB(1), BB(2), label)
    
    hold off,
% waitforbuttonpress,
end
