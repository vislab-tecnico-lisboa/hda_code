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
if(nargin && ~isempty(name1)), name=lower(name1); else
  if(isempty(name)), name='usatest'; end; end; name1=name;

vidId=str2double(name1(end-2:end)); % check if name ends in 3 ints
if(isnan(vidId)), vidId=[]; else name1=name1(1:end-3); end
setId=str2double(name1(end-1:end)); % check if name ends in 2 ints
if(isnan(setId)), setId=[]; else name1=name1(1:end-2); end

switch name1
  case 'usa' % Caltech Pedestrian Datasets (all)
    setIds=0:10; subdir='USA'; skip=30; minHt=25;
    vidIds={0:14 0:5 0:11 0:12 0:11 0:12 0:18 0:11 0:10 0:11 0:11};
  case 'usatrain' % Caltech Pedestrian Datasets (training)
    setIds=0:5; subdir='USA'; skip=30; minHt=25;
    vidIds={0:14 0:5 0:11 0:12 0:11 0:12};
  case 'usatest' % Caltech Pedestrian Datasets (testing)
    setIds=6:10; subdir='USA'; skip=30; minHt=25;
    vidIds={0:18 0:11 0:10 0:11 0:11};
  case 'inriatrain' % INRIA peds (training)
    setIds=0; subdir='INRIA'; skip=1; minHt=100; vidIds={0};
  case 'inriatest' % INRIA peds (testing)
    setIds=1; subdir='INRIA'; skip=1; minHt=100; vidIds={0};
  case 'japan' % Caltech Japan data (not publicly avialable)
    setIds=0:12; subdir='Japan'; skip=30; minHt=25;
    vidIds={0:5 0:5 0:3 0:5 0:5 0:5 0:5 0:5 0:4 0:4 0:5 0:5 0:4};
  case 'tudbrussels' % TUD-Brussels dataset
    setIds=0; subdir='TudBrussels'; skip=1; minHt=50; vidIds={0};
  case 'eth' % ETH dataset
    setIds=0:2; subdir='ETH'; skip=1; minHt=50; vidIds={0 0 0};
  case 'daimler' % Daimler dataset
    setIds=0; subdir='Daimler'; skip=1; minHt=50; vidIds={0};
  case 'pietro'
    setIds=0; subdir='Pietro'; skip=1; minHt=50; vidIds={0};
  otherwise, error('unknown data type: %s',name);
end

% optionally select only specific set/vid if name ended in ints
if(~isempty(setId)), setIds=setIds(setId); vidIds=vidIds(setId); end
if(~isempty(vidId)), vidIds={vidIds{1}(vidId)}; end

% actual directory where data is contained
pth=fileparts(mfilename('fullpath'));
pth=[pth filesep 'data-' subdir];
