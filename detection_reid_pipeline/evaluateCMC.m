function evaluateCMC(TestCamera)
%EVALUATECMC Learns a classifier, evaluates it and plots a CMC.  
%   EVALUATECMC(TESTCAMERA) Uses Bhattacharrya distance in a NN-classifier
%   to re-identify the test samples relative to TESTCAMERA.
%   Data for training and testing is loaded from files into the trainS and testS structures. Please, see the comments in the code for a detailed description of such structures. The data consists in cropped RGB images, binary masks for different body parts and  
%   pre-computed HSV histograms. We compute the Bhattacharrya
%   distance for each (train, test) sample pair, then create a ranked list for each test sample, and finally plot a CMC.  
%
%   This code is provided so it can be adapted to test your algorithms on
%   the HDA dataset data.
%   Detection bounding boxes by a pedestrian detector, and body-part detections computed on such
%   bounding boxes are graciously provided as well.
%
%   If you use the data provided, please cite the Pedestrian Detector work and
%   Body-Part Detector work below.
% 
%   Pedestrian Detector used: Matteo Taiana, Jacinto Nascimento,
%     Alexandre Bernardino, "An Improved Labelling for the INRIA Person
%     Data Set for Pedestrian Detection", on  Proc. of IbPRIA 2013.  
%     http://users.isr.ist.utl.pt/~mtaiana/publications.html
% 
%   Body-Part Detector used: M. Andriluka, S. Roth, B. Schiele. "Pictorial
%     Structures Revisited: People Detection and Articulated Pose
%     Estimation" on IEEE Conference on Computer Vision and Pattern
%     Recognition (CVPR'09), Miami, USA, June 2009.  
%     http://www.d2.mpi-inf.mpg.de/andriluka_cvpr09
% 


% DESCRIPTION OF THE DATA STRUCTURES
%   trainS is a structure with one element per training sample. Each
%   element contains the following fields:
%     datasetPrint: Cropped RGB image
%     pmskset4: Four binary masks, one per body-part: head-torso-thighs-shins
%     F: 120 length vector containing the concatenation of four 10-bin HSV
%       histograms. One for each body-part (10 bins for H, 10 for S, 10 for V)  
%     cam: Camera number this sample belongs to.
%     pid: Pedestrian ID.
%     imName: Image name this structure was generated from.
%     frame: Frame number of the video sequence of camera number "cam" that
%       this sample belongs to.
%     occ: Occlusion bit, indicates if sample is fully visible or imaged under any
%       degree of occlusion.
% 
%   testS is a structure with one element per test sample. Each
%   element contains the following fields:
%     datasetPrint: Cropped RGB image
%     pmskset4: Four binary masks, one per body-part: head-torso-thighs-shins
%     F: 120 length vector containing the concatenation of four 10-bin HSV
%       histograms. One for each body-part (10 bins for H, 10 for S, 10 for V)  
%     cam: Camera number this sample belongs to.
%     pid: Pedestrian ID.
%     imName: Image name this structure was generated from.
%     frame: Frame number of the video sequence of camera number "cam" that
%       this sample belongs to.
%     occ: Obsolete (not used)
%     overlap: Degree of overlap with any other detection.
%     GToverlap: Degree of overlap with corresponding ground truth bounding box.
%     GFV: Occlusion bit, indicates if sample is fully visible or imaged under any
%       degree of occlusion.
%     Conf: Confidence of the detector in this detection.
% 
if ischar(TestCamera)
    display('Received text in TestCamera, converted it to int:')
    TestCamera = sscanf(TestCamera,'%d')
    display('I hope it is correct.')
end

load('trainS.mat','trainS'),
load(['detections_testS_Cam' int2str(TestCamera) '.mat'],'testS'),

% Purge samples from Train experiment data that were taken in the TestCamera 
indTestCam = [trainS.cam] == TestCamera;
% display([' ..Purging test camera (' int2str(TestCamera) ') from trainS.. ' int2str(sum(indTestCam)) ' detections of ' int2str(length(indTestCam)) '\n'])
trainS = trainS(~indTestCam);

% Purge test samples that were taken in other cameras (if any)
indTestCaminTest = [testS.cam] == TestCamera;
testS = testS(indTestCaminTest);
% display([' ..Purging test camera (' int2str(TestCamera) ') from testS.. ' int2str(sum(~indTestCaminTest)) ' detections of ' int2str(length(indTestCaminTest)) '\n'])
% assert(min(indTestCaminTest),['There are some test samples that are not from camera ' int2str(TestCamera)])

% Classification code, one for-cycle for all test samples, creating a
% ranked list for each test sample
MC = zeros(1,length(unique([trainS.pid])));
wb = waitbar(0,'Computing Re-Id for test samples..');
trainSpidVector = [trainS.pid];% for speed
testSpidVector = [testS.pid]; % for speed
unique_trainSpid = unique([trainS.pid]);
nPed = length(unique_trainSpid);
for testIm = 1:length(testS)
    
    % Compute bhattacharrya distances of test sample to all train samples
    dist1toAll = BhattDist1toAll(testS(testIm).F', [trainS.F]');

    % Compute minimum of distances for each train ped (not sample)
    dist1toPeds = zeros(1,nPed);
    dist1toPedsPIDs = zeros(1,nPed);
    for trainPed = 1:nPed
        indTped = trainSpidVector == unique_trainSpid(trainPed);
        if ~isempty(min(dist1toAll(indTped)))
            dist1toPeds(trainPed) = min(dist1toAll(indTped));
        else
            % Apparently there are no instances of this ped
            dist1toPeds(trainPed) = Inf;
        end
        
        dist1toPedsPIDs(trainPed) = unique_trainSpid(trainPed);
    end
        
    % Sort the distances to all train peds, and find the index of the correct match    
    [Y, I] = sort(dist1toPeds);
    testS(testIm).dist1toPedsPIDsI = dist1toPedsPIDs(I); % Ranked list of best matches
    testS(testIm).indMC = find(dist1toPedsPIDs(I) == testSpidVector(testIm)); % Rank of correct match

    % To plot CMC
    MC(testS(testIm).indMC) = MC(testS(testIm).indMC)+1;       
    
    waitbar(testIm/length(testS), wb);
end
close(wb);

% Plot CMC 
CMC = cumsum(MC) / length(testS) * 100;

plotCMC(CMC);



function  distVT1 =  BhattDist1toAll(F97testIm, F96)
% function  distVT1 =  BhattDist1toAll(F97(testIm,:), F96)
% Compute bhattacharrya distances of test sample to all train samples

avoid0 = realmin;

% VTd = double([F96; F97(testIm,:)]);
VTd = double([F96; F97testIm]);
[nImages,histLen] = size(VTd); % VT should be nImages x histLen
normVec = avoid0 + sum(VTd,2); % vector with sum of each ped hist
hists_i = sqrt(VTd ./ normVec(:,ones(1,histLen))); % each hist normalized to 1, sqrt'ed
norm1 = avoid0 + sum(F97testIm);
hist_test = sqrt(F97testIm/norm1);
distVT1 = real(sqrt(1 - hists_i * hist_test')); % each element squared, 1 - , sqrt'ed

function plotCMC(CMC)

nAUC = sum(CMC)/length(CMC);
legendStr = ['nAUC ' num2str(nAUC,'%.2f') ' / 1st ' num2str(CMC(1),'%.2f') '%'];
eh = plot(CMC,'k','Linewidth',3.0);
set(eh,'DisplayName',legendStr);
axis([1,length(CMC),0,100]);
xlabel('Rank Score')
ylabel('Re-identification %')
legend('Location','SouthEast');
title('CMC')
plotedit on 

