%% Computer specific dataset directory
% To be able to run the main script, fill in below:
%   - "hdaRootDirectory" variable with the location of the 'HDA_Dataset'
% folder, 
%   -'addpath(genpath( ... ))' with the location of the 'hda_code' folder (which
%   need not be inside the HDA_Dataset folder) 

% Code for allowing my and my co-worker's computers to run the same script. 
% Delete or Replace the contents of the if's below with your computer
% names' and your co-workers computer names'
[~,systemName] = system('hostname');

if strcmp(systemName(1:end-1),'Dario-Laptop')

    hdaRootDirectory ='C:/Users/Dario/Desktop/WorkNoSync/HDA_Dataset';
    addpath(genpath('C:/Users/Dario/Dropbox/Work/hda_code'));

elseif strcmp(systemName(1:end-1),'dwarf') % Plinio desktop
    
    hdaRootDirectory ='C:/Users/Dario/Desktop/WorkPlinioPC/HDA_Dataset';
    % not doing genpath(), but adding each folder individually because of
    % the .sync folder from BTSync
    addpath('C:/Users/Dario/Desktop/WorkPlinioPC/hda_code/detection_reid_pipeline');
    addpath('C:/Users/Dario/Desktop/WorkPlinioPC/hda_code/evaluation');
    addpath(genpath('C:/Users/Dario/Desktop/WorkPlinioPC/hda_code/visualization'));
        
elseif strcmp(systemName(1:end-1),'vislab7') % My desktop
    
    hdaRootDirectory ='/home/dario/Desktop/Dropbox/Work/HDA_Dataset';
    % not doing genpath(), but adding each folder individually because of
    % the .sync folder from BTSync
    addpath('/home/dario/Desktop/Dropbox/Work/hda_code/detection_reid_pipeline');
    addpath('/home/dario/Desktop/Dropbox/Work/hda_code/evaluation');
    addpath(genpath('/home/dario/Desktop/Dropbox/Work/hda_code/visualization'));
        
elseif strcmp(systemName(1:end-1),'NetVis-PC') % Asus Eee PC do Vislab
    
    hdaRootDirectory ='C:/Users/Dario/Dropbox/Work/HDA_Dataset';
    addpath(genpath('C:/Users/Dario/Dropbox/Work/hda_code'));
        
elseif strcmp(systemName(1:end-1),'rocoto')
    
    hdaRootDirectory ='~/PhD/MyCode/ReId/HdaRoot';
    addpath(genpath(['~/PhD/MyCode/ReId/Svn/']));
end