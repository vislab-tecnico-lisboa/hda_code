%% Computer specific dataset directory
% To be able to run the main script, fill in below:
%   - "hdaRootDirectory" variable with the location of the 'HDA_Dataset'
% folder, 
%   -'addpath(genpath( ... ))' with the location of the 'hda_code' folder (which
%   need not be inside the HDA_Dataset folder) 
global hdaRootDirectory

hdaRootDirectory ='/full/path/to/HDA_Dataset_V1.2';
addpath(genpath(['/full/path/to/hda_code-master']));


% Code for allowing my and my co-worker's computers to run the same script. 
% You can delete or replace the contents of the if's below with your computer
% names' and your co-workers computer names'
%[~,systemName] = system('hostname');
%if strcmp(systemName(1:end-1),'Dario-Laptop')
%    hdaRootDirectory ='C:/Users/Dario/Desktop/WorkNoSync/HDA_Dataset';
%    addpath(genpath('C:/Users/Dario/Dropbox/Work/hda_code'));
%elseif strcmp(systemName(1:end-1),'rocoto')
%    hdaRootDirectory ='~/PhD/MyCode/ReId/HdaRoot';
%    addpath(genpath(['~/PhD/MyCode/ReId/Svn/']));
%end
