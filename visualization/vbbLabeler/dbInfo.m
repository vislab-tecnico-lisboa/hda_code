function [pth,setIds,vidIds,skip,minHt] = dbInfo( name1 )
% Specifies data amount and location (alter internal flag as desired).
%
% USAGE
%  [pth,setIds,vidIds,skip,minHt] = dbInfo( [name] )
%
% INPUTS
%  name     - ['UsaTest'] specify dataset, caches last passed in name
%
% OUTPUTS
%  pth      - directory containing database
%  setIds   - integer ids of each set
%  vidIds   - [1xnSets] cell of vectors of integer ids of each video
%  skip     - specify subset of frames to use for evaluation
%  minHt    - minimum labeled pedestrian height in dataset
%
% EXAMPLE
%  [pth,setIds,vidIds,skip,minHt] = dbInfo
%
% See also
%
% Caltech Pedestrian Dataset     Version 3.0.0
% Copyright 2011 Piotr Dollar.  [pdollar-at-caltech.edu]
% Please email us if you find bugs, or have suggestions or questions!
% Licensed under the Lesser GPL [see lgpl.txt]

persistent name; % cache last used name
if(nargin && ~isempty(name1))
    name=lower(name1);
else
    if(isempty(name))
        name='hda60a';
    end;
end;
if(iscell(name))
    name1=name{1,1};
else
    name1=name;
end

% vidId=str2double(name1(end-2:end)); % check if name ends in 3 ints
% if(isnan(vidId)), vidId=[]; else name1=name1(1:end-3); end
% setId=str2double(name1(end-1:end)); % check if name ends in 2 ints
% if(isnan(setId)), setId=[]; else name1=name1(1:end-2); end

switch name1

  case 'hda' % HDA dataset (all)
    setIds=[2 17 18 19 40 50 53 54 56 57 58 59 60]; subdir='HDA'; skip=1; ext='jpg';
    vidIds={0 0 0 0 0 0 0 0 0 0 0 0 0};

  case 'hda1760a' % HDA only 17 and 60
    setIds=[17 60]; subdir='HDA'; skip=1; ext='jpg';
    vidIds={0 0 };
    

  case 'hdawithout2a' % HDA minus seq02, for which the detector fails
    setIds=[17 18 19 40 50 53 54 56 57 58 59 60]; subdir='HDA'; skip=1; ext='jpg';
    vidIds={0 0 0 0 0 0 0 0 0 0 0 0};
    
  case 'hda02a' % HDA seq02
    setIds=[2]; subdir='HDA'; skip=1; ext='jpg';
    vidIds={0};

  case 'hda17a' % HDA seq17
    setIds=[17]; subdir='HDA'; skip=1; ext='jpg';
    vidIds={0};

  case 'hda18a' % HDA seq18
    setIds=[18]; subdir='HDA'; skip=1; ext='jpg';
    vidIds={0};

  case 'hda19a' % HDA seq19
    setIds=[19]; subdir='HDA'; skip=1; ext='jpg';
    vidIds={0};

  case 'hda40a' % HDA seq40
    setIds=[40]; subdir='HDA'; skip=1; ext='jpg';
    vidIds={0};

  case 'hda50a' % HDA seq50
    setIds=[50]; subdir='HDA'; skip=1; ext='jpg';
    vidIds={0};

  case 'hda53a' % HDA seq53
    setIds=[53]; subdir='HDA'; skip=1; ext='jpg';
    vidIds={0};

  case 'hda54a' % HDA seq54
    setIds=[54]; subdir='HDA'; skip=1; ext='jpg';
    vidIds={0};

  case 'hda56a' % HDA seq56
    setIds=[56]; subdir='HDA'; skip=1; ext='jpg';
    vidIds={0};

  case 'hda57a' % HDA seq57
    setIds=[57]; subdir='HDA'; skip=1; ext='jpg';
    vidIds={0};

  case 'hda58a' % HDA seq58
    setIds=[58]; subdir='HDA'; skip=1; ext='jpg';
    vidIds={0};

  case 'hda59a' % HDA seq59
    setIds=[59]; subdir='HDA'; skip=1; ext='jpg';
    vidIds={0};

  case 'hda60a' % HDA seq60
    setIds=[60]; subdir='HDA'; skip=1; ext='jpg';
    vidIds={0};


  otherwise, error('unknown data type: %s',name);
end

% optionally select only specific set/vid if name ended in ints
%if(~isempty(setId)), setIds=setIds(setId); vidIds=vidIds(setId); end
%if(~isempty(vidId)), vidIds={vidIds{1}(vidId)}; end

declareGlobalVariables,
% actual ROOT directory where data is contained
pth= [hdaRootDirectory '/hda_detections/'];
%pth=[pth filesep 'data-' subdir];
