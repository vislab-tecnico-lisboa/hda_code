function dbEval
% Evaluate and plot all detection results (alter internal flags as needed).
%
% USAGE
%  dbEval
%
% INPUTS
%
% OUTPUTS
%
% EXAMPLE
%  dbEval
%
% See also EVALFRAME, DBINFO
%
% Caltech Pedestrian Dataset     Version 3.0.0
% Copyright 2011 Piotr Dollar.  [pdollar-at-caltech.edu]
% Please email us if you find bugs, or have suggestions or questions!
% Licensed under the Lesser GPL [see lgpl.txt]

dataNames={'UsaTest','UsaTrain','Japan','InriaTest',...
  'TudBrussels','ETH','Daimler','Usa01','Usa02','Usa03','Usa04',...
  'Usa05','Usa06','Usa07','Usa08','Usa09','Usa10','Usa11',...
  'ETH01','ETH02','ETH03','Japan01','Japan02','Japan03','Japan04',...
  'Japan05','Japan06','Japan07','Japan08','Japan09','Japan10',...
  'Japan11','Japan12','Japan13'};

for i = 1
  % experiment setup
  dataName=dataNames{i};  % evaluations to run
  rIs=[1 0 0];            % which roc curves to plot
  pIs=[0 0 0];            % which PR curves to plot (set refs=0:.1:1)
  bnds=[5 5 635 475];     % discard bbs outside this range
  lims=[2e-4 50 .035 1];  % axis limits for resulting fppi plots
  ref=10.^(-2:.25:0);     % reference points for plots
  eIds=2;                 % experiments to perform, see defineExps()
  dn=dataName; while(~isnan(str2double(dn(end)))), dn=dn(1:end-1); end
  switch dn
    case {'Usa','UsaTrain','UsaTest'}
      aIds=[1:14 6.1 6.2];
    case 'Japan'
      aIds=[1:13 6.1 6.2];
    case 'InriaTest'
      aIds=[1:13 6.1 14.4]; bnds=[];
    case 'TudBrussels'
      aIds=[1:2 4:13 6.1 6.2]; bnds=[];
    case 'ETH'
      aIds=[1:2 4:13 6.1 6.2]; bnds=[];
    case 'Daimler'
      aIds=[1:2 4 6:9 13 6.1 6.2];
    otherwise
      error('unknown type: %s',dn);
  end
  
  % directories to output temporary data and plots
  cDir = fileparts(mfilename('fullpath'));
  rDir=[cDir '/eval/' dataName '/']; pDir=[cDir '/results/'];
  if(~exist(rDir,'dir')), mkdir(rDir); end
  if(~exist(pDir,'dir')), mkdir(pDir); end
  
  % initialize dataName for future calls to dbInfo
  dbInfo(dataName);
  
  % define algorithms (set algorithm parameters here)
  [algs,aClr,aLs] = defineAlgs( aIds );
  
  % define experiments (set experiment parameters here)
  exps = defineExps( eIds, bnds );
  
  % load detections for each alg
  dts = loadDt( algs, rDir );
  
  % load ground truth for each exp
  gts = loadGt( exps, rDir );
  
  % evaluate the results
  res = evalAlgs( rDir, algs, exps, gts, dts );
  
  % plot rocs
  plotExps( 1, res, pDir, rIs, dataName, lims, aClr, aLs, ref );
  
  % plot pr curves
  plotExps( 0, res, pDir, pIs, dataName, lims, aClr, aLs, ref );
  
  % plot sample dt bb (fp/tp,fn)
  plotBb( res, rDir, 0, 'fp' );
  plotBb( res, rDir, 0, 'tp' );
  plotBb( res, rDir, 0, 'fn' );
end
end

function [algs,aClr,aLs] = defineAlgs( ids )
% Define the algorithms that should be evaluated.
%
% OUTPUTS
%  algs     - algorithms struct array, with entries:
%    .str      - string identifying the algorithm
%    .aDir     - directory containing algorithm output
%    .resize   - {flag,hr,wr,ar} controls resizing of dt bbs
%  aClr      - rgb colors for plotting algorithm results
%  aLs       - LineStyles for plotting algorithm results
algs=struct('str',{},'aDir',{},'resize',{},'clr',[],'ls',[]);
algs=repmat(algs,1,length(ids)); c=0;
nCol=15; clrs=uniqueColors(4,nCol,0,0);
clrs=reshape(permute(clrs,[2 1 3]),3,nCol,[]);

for id=ids
  switch id
    case 1,     alg=def('VJ',0,id);
    case 1.1,   alg=def('VJ-OpenCv',0,id);
    case 2,     alg=def('HOG',1,id);
    case 3,     alg=def('FtrMine',1,id);
    case 4,     alg=def('Shapelet',0,id);
    case 4.1,   alg=def('Shapelet-orig',1,id);
    case 5,     alg=def('PoseInv',1,id);
    case 5.1,   alg=def('PoseInvSvm',1,id);
    case 6,     alg=def('MultiFtr',0,id);
    case 6.1,   alg=def('MultiFtr+CSS',0,id);
    case 6.2,   alg=def('MultiFtr+Motion',0,id);
    case 6.3,   alg=def('MultiFtr+CSS+LBP',0,id);
    case 7,     alg=def('HikSvm',1,id);
    case 8,     alg=def('LatSvm-V1',0,id);
    case 9,     alg=def('LatSvm-V2',0,id);
    case 10,    alg=def('ChnFtrs',0,id);
    case 10.1,  alg=def('ChnFtrs50',0,id);
    case 11,    alg=def('FPDW',0,id);
    case 12,    alg=def('Pls',0,id);
    case 13,    alg=def('HogLbp',0,id);
    case 14,    alg=def('FeatSynth',0,id);
    case 14.4,  alg=def('FeatSynth',1,id);
  end; c=c+1; algs(c)=alg;
end
aClr=reshape([algs.clr],3,[])'; aLs={algs.ls};
algs=rmfield(algs,{'clr','ls'});

  function alg = def( str, resFlag, id )
    aDir=[dbInfo '/res/' str]; resize={{resFlag 100/128 41/64 0}};
    i=mod(floor(id)-1,nCol)+1; j=mod(round(mod(id,1)*10),4)+1;
    clr=clrs(:,i,j)'; if(mod(i,2)==1), ls='-'; else ls='--'; end
    alg=struct('str',str,'aDir',aDir,'resize',resize,'clr',clr,'ls',ls);
  end
end

function exps = defineExps( ids, bnds )
% Define the experiments that should be performed.
%
% OUTPUTS
%  exps     - experiments struct array, with entries:
%    .str      - string identifying the experiment
%    .lbls     - object labels for which to get gt (see vbb:frameAnn()
%    .overlap  - overlap threshold for PASCAL criteria
%    .testGt   - gt bbs that fail test are set to ignore
%    .testDt   - dt bbs that fail test are set to ignore
exps=struct('str',{},'lbls',{},'overlap',{},'testGt',{},'testDt',{});
exps=repmat(exps,1,length(ids)); c=0; m=inf;
if(isempty(bnds)), bnds=[-m -m m m]; end
for i=1:length(ids), id=ids(i);
  switch floor(id)
    case 1,  exp=def('all',            [20 m],  [.2 m],   0 );
    case 2,  exp=def('reasonable',     [50 m],  [.65 m],  0 );
    case 3,  exp=def('scale=large',    [100 m], [m m],    0 );
    case 4,  exp=def('scale=near',     [80 m],  [m m],    0 );
    case 5,  exp=def('scale=medium',   [30 80], [m m],    0 );
    case 6,  exp=def('scale=far',      [20 30], [m m],    0 );
    case 7,  exp=def('occ=none',       [50 m],  [m m],    0 );
    case 8,  exp=def('occ=partial',    [50 m],  [.65 1],  0 );
    case 9,  exp=def('occ=heavy',      [50 m],  [.2 .65], 0 );
    case 10, exp=def('ar=all',         [50 m],  [m m],    0 );
    case 11, exp=def('ar=typical',     [50 m],  [m m],   .1 );
    case 12, exp=def('ar=atypical',    [50 m],  [m m],  -.1 );
    case 13  % scale sweep, usage: eIds=13+(1:6)/10;
      scl=2^(4+(id-13)*10/2); sclStr=int2str2(round(scl),3);
      rng=round([scl/2^(1/4) scl*2^(1/4)]); if(id==13.6), rng(2)=m; end
      exp=def(['scale=' sclStr], rng, [m m], 0 );
    case 14  % overlap sweep, usage: eIds=14+(5:5:95)/100;
      overlap=id-14; overlapStr=int2str2(round(overlap*100),2);
      exp=def(['overlap=' overlapStr], [50 m], [.65 m], 0, overlap );
    case 15  % scale_e sweep, usage: eIds=15+(0:5:95)/100;
      e=id-15;  filterStr=int2str2(round(e*100),2);
      exp=def(['filter=' filterStr], [50 m], [.65 m], 0, .5, e+1 );
    otherwise, error('unknown type %f',id);
  end; c=c+1; exps(c)=exp;
end

  function exp = def( str, hs, vs, ar, overlap, e )
    if(nargin<5 || isempty(overlap)), overlap=.5; end
    if(nargin<6 || isempty(e)), e=1.25; end
    testGt = @(lbl,bb,bbv) testGt(lbl,bb,bbv,hs,vs,ar);
    testDt = @(bb) (bb(:,4)>=hs(1)/e & bb(:,4)<hs(2)*e); %| bb(:,6)==1);
    lbls={'person','person?','people','ignore'};
    exp=struct('str',str,'lbls',{lbls},'overlap',overlap,...
      'testGt',testGt,'testDt',testDt);
  end

  function p = testGt( lbl, bb, bbv, hs, vs, ar )
    p=strcmp(lbl,'person'); % only 'person' objects are considered
    h=bb(4); p=p & (h>=hs(1) & h<hs(2)); % height must be in range
    if(all(bbv==0)), v=inf; else v=bbv(3).*bbv(4)./(bb(3)*bb(4)); end
    p=p & v>=vs(1) & v<=vs(2); % fraction visible area in range
    if(ar~=0), p=p & sign(ar)*abs(bb(3)./bb(4)-.41)<ar; end % ar test
    p = p & bb(1)>=bnds(1) & (bb(1)+bb(3)<=bnds(3));
    p = p & bb(2)>=bnds(2) & (bb(2)+bb(4)<=bnds(4));
  end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function res = evalAlgs( rDir, algs, exps, gts, dts )
% Evaluate every algorithm on each experiment
%
% INPUTS
%   rDir    - results directory
%   algs    - output of defineAlgs()
%   exps    - output of defineExps()
%   gts     - output of loadDt()
%   dts     - output of loadGt()
%
% OUTPUTS
%   dtRes   - nGt x nDt cell of all evaluations, each with fields
%     .str    - string identifying the plot [stra stre]
%     .stra   - string identifying algorithm
%     .stre   - string identifying experiment
%     .n      - num frames evaluated
%     .gtr    - gt results (merged output 1 of evalRes), with fields:
%         .ind    - [m x 3] set/video/frame ind of each gt bb
%         .bb     - [m x 5] gt bbs [x y w h match]
%     .dtr    - dt results (merged output 2 of evalRes), with fields:
%         .ind    - [n x 3] set/video/frame ind of each dt bb
%         .bb     - [n x 6] dt bbs [x y w h score match]
fprintf('Evaluating: %s\n',rDir); nGt=length(gts); nDt=length(dts);
res=repmat(struct('str',[], 'stra',[], 'stre',[], 'n',[],...
  'gtr',[],'dtr',[]),nGt,nDt);
for g=1:nGt
  for d=1:nDt
    gt=gts{g}; dt=dts{d}; str=[exps(g).str ' ' algs(d).str];
    testDt=exps(g).testDt; fName = [rDir 'ev-' str '.mat'];
    % if previously evaluated, load result and continue
    if(exist(fName,'file')), R=load(fName); res(g,d)=R.R; continue; end
    % evaluating alg d on experiment g
    fprintf('\tExp %i/%i, Alg %i/%i: %s\n',g,nGt,d,nDt,str);
    n=sum([gt.n]); gtr=struct('ind',zeros(n,3),'bb',zeros(n,5)); cGt=0;
    n=sum([dt.n]); dtr=struct('ind',zeros(n,3),'bb',zeros(n,6)); cDt=0;
    n=length(gt); assert(length(dt)==n);
    % evaluate each frame individually, concatenate results
    for f=1:n
      % filter detections and standardize aspect ratios
      dtBb=dt(f).bb; gtBb=gt(f).bb; ids=testDt(dtBb); dtBb=dtBb(ids,:);
      dtBb=bbApply('resize',dtBb,1,0,.41); ids=gtBb(:,5)~=1;
      gtBb(ids,:)=bbApply('resize',gtBb(ids,:),1,0,.41);
      % perform evaluation and store
      [gtr1, dtr1] = bbGt('evalRes', gtBb, dtBb, exps(g).overlap );
      if(0), dtr1(testDt(dtr1)==0,6)=-1; end
      gtr1=gtr1(gtr1(:,5)~=-1,:); dtr1=dtr1(dtr1(:,6)~=-1,:);
      cGt1=size(gtr1,1); isGt=cGt+1:cGt+cGt1; cGt=cGt+cGt1;
      cDt1=size(dtr1,1); isDt=cDt+1:cDt+cDt1; cDt=cDt+cDt1;
      gtr.ind(isGt,:)=repmat(gt(f).ind,[cGt1,1]); gtr.bb(isGt,:)=gtr1;
      dtr.ind(isDt,:)=repmat(dt(f).ind,[cDt1,1]); dtr.bb(isDt,:)=dtr1;
    end
    % store results
    gtr.ind=gtr.ind(1:cGt,:); gtr.bb=gtr.bb(1:cGt,:);
    dtr.ind=dtr.ind(1:cDt,:); dtr.bb=dtr.bb(1:cDt,:);
    clear R; R.str=str; R.stra=algs(d).str; R.stre=exps(g).str;
    R.n=n; R.gtr=gtr; R.dtr=dtr; res(g,d)=R; save(fName,'R');
  end
end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function plotExps( isRoc,res,rDir,types,dataName,lims,aClr,aLs,ref )
% plot all ROC or PR curves

% Compute roc and pr curve for every exp/alg
if(all(types==0)), return; end
[nGt,nDt]=size(res); xs=cell(nGt,nDt); ys=xs; rs=zeros(nGt,nDt);
for g=1:nGt
  for d=1:nDt
    R=res(g,d); dtr=R.dtr; np=size(R.gtr.bb,1);
    score=dtr.bb(:,5); tp=dtr.bb(:,6);
    [xs{g,d},ys{g,d},rs(g,d)]=compCurve(isRoc,score,tp,np,R.n,ref);
  end
end
% plot name, titles, legends
if( isRoc ), tstr='roc '; else tstr='pr '; end;
stra={res(1,:).stra}; stra1=stra; stre={res(:,1).stre}; stre1=stre;
ns=zeros(1,nGt); for g=1:nGt, ns(g)=size(res(g,1).gtr.ind,1); end
fName=[rDir dataName ' ' tstr]; rs1=round(rs*100);
% Create 1 figure per exp for all algs
if(types(1))
  for g=1:nGt
    for d=1:nDt, stra1{d}=sprintf('%2i%% %s',rs1(g,d),stra{d}); end
    fName1=[fName 'exp=' stre{g}]; [d,order]=sort(rs(g,:),'descend');
    plotExp(isRoc,xs(g,:),ys(g,:),'',stra1,fName1,lims,order,aClr,aLs,ref);
    f=fopen([fName1 '.txt'],'w');
    for d=1:nDt, fprintf(f,'%s %f\n',stra{d},rs(g,d)); end; fclose(f);
  end
end
% Create 1 figure per alg for all exps
if(types(2))
  for d=1:nDt
    for g=1:nGt, stre1{g}=sprintf('%2i%% %s',rs1(g,d),stre{g}); end
    fName1=[fName 'alg=' stra{d}]; order=1:nGt;
    plotExp(isRoc,xs(:,d),ys(:,d),'',stre1,fName1,lims,order,[],[],ref);
  end
end
% Create 1 figure per alg per exp
if(types(3))
  for g=1:nGt
    for d=1:nDt
      str=res(g,d).str; lgd=[];
      plotExp(isRoc,xs(g,d),ys(g,d),'',lgd,[fName str],lims,1,[],[],ref);
    end
  end
end
end

function [xs,ys,r]=compCurve( isRoc, score, tp, np, nIm, ref )
% Get either PR (precision/recall) or ROC (fppi) curve
%
% Also computes reference point, which for:
%  ROC curves is the log-average miss rate at ref FPPI rates
%  PR curves is the average precision (AP) at ref recall rates
%
% INPUTS
%  isRoc   - if true compute ROC else compute PR
%  score   - [nx1] score of every detection
%  tp      - [nx1] 0/1 indicates if detection is a true positive
%  np      - num true pos in the set
%  nIm     - num images
%  ref     - reference point
if(isempty(tp)), xs=0; ys=1; r=isRoc; return; end
[score,order]=sort(score,'descend');
tp=tp(order); fp=double(tp~=1);
fp=cumsum(fp); tp=cumsum(tp);
m=length(ref); rs=zeros(1,m);
if( isRoc )
  tp=tp/max(eps,np); fp=fp/nIm; xs=fp; ys=1-tp;
  for i=1:m, j=find(xs<=ref(i)); rs(i)=ys(j(end)); end
  r=exp(mean(log(rs)));
else
  rec=tp/max(eps,np); prec=tp./(fp+tp); xs=rec; ys=prec;
  xs1=[xs; 1]; ys1=[ys; 0];
  for i=1:m, j=find(xs1>=ref(i)); rs(i)=ys1(j(1)); end
  r=mean(rs);
end
end

function plotExp( isRoc,xs,ys,str,lgd,fName,lims,order,clr,ls,ref )
% plot either ROC or PR curves

% plot curves
figure(1); clf; grid on; hold on; n=length(xs); h=zeros(1,n);
if(isempty(clr)), clr=uniqueColors(1,max(10,n)); end
if(isempty(ls)), ls=repmat({'-','--'},1,100); end
if(isRoc && length(ref)==1)
  plot([ref ref],[eps 1],'Color',[1 1 1]*.7,'LineWidth',3); end
for i=1:n, h(i)=plot(xs{i},ys{i},'Color',clr(i,:),'LineStyle',ls{i}); end
set(h,'LineWidth',3);

% setup axes etc
fnt={ 'FontSize',12 };
if( isRoc )
  ys=[0 .05 .1:.1:.5 .64 .8]; yt=[sprintf('.%02i|',ys*100) '1']; ys=[ys 1];
  set(gca,'XScale','log','YScale','log','YTick',ys,'YTickLabel',yt);
  set(gca,'XMinorGrid','off','XMinorTic','off');
  set(gca,'YMinorGrid','off','YMinorTic','off');
  if(~isempty(str)), title(['ROC for ' str],fnt{:}); end
  xlabel('false positives per image',fnt{:});
  ylabel('miss rate',fnt{:}); axis(lims); lgdLoc='sw';
else
  x2=1; for i=1:n, x2=max(x2,max(xs{i})); end, x2=min(x2-mod(x2,.1),1.0);
  y1=.8; for i=1:n, y1=min(y1,min(ys{i})); end, y1=max(y1-mod(y1,.1),.01);
  xlim([0, x2]); ylim([y1, 1]); lgdLoc='sw';
  set(gca,'xtick',0:.1:1);
  xlabel('Recall',fnt{:}); ylabel('Precision',fnt{:});
  if(~isempty(str)), title(['PR for ' str],fnt{:}); end
end
if(~isempty(lgd)),
  legend(h(order),lgd(order),'Location',lgdLoc,'FontSize',9); end
savefig(fName,1,'pdf','-r300','-fonts'); close(1);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function plotBb( res, rDir, pPage, type )
% This function plots sample fp/tp/fn bbs for given algs/exps
if(pPage==0), return; end
[nGt,nDt]=size(res);
for g=1:nGt
  for d=1:nDt
    % get bb, ind, bbo, and indo according to type
    dtr=res(g,d).dtr; gtr=res(g,d).gtr;
    if( strcmp(type,'fn') )
      keep=gtr.bb(:,5)==0; ord=randperm(sum(keep));
      bbCol='r'; bboCol='y'; bbLst='-'; bboLst='--';
      bb=gtr.bb(:,1:4); ind=gtr.ind; bbo=dtr.bb; indo=dtr.ind;
    else
      switch type
        case 'all', bbCol='y'; keep=dtr.bb(:,6)>=0;
        case 'fp',  bbCol='r'; keep=dtr.bb(:,6)==0;
        case 'tp',  bbCol='y'; keep=dtr.bb(:,6)==1;
      end
      [disc,ord]=sort(dtr.bb(keep,5),'descend');
      bboCol='g'; bbLst='--'; bboLst='-';
      bb=dtr.bb; ind=dtr.ind; bbo=gtr.bb(:,1:4); indo=gtr.ind;
    end
    % prepare and display
    n=sum(keep); bbo1=cell(1,n); O=ones(1,size(indo,1));
    ind=ind(keep,:); bb=bb(keep,:); ind=ind(ord,:); bb=bb(ord,:);
    for f=1:n, bbo1{f}=bbo(all(indo==ind(O*f,:),2),:); end
    R=struct('ind',ind,'bb',bb,'bbo',{bbo1});
    fName = sprintf('%s/res-%s-%s', rDir, res(g,d).str, type);
    plotBbSheet( R,'fName',fName,'pPage',pPage,'bbCol',bbCol,...
      'bbLst',bbLst,'bboCol',bboCol,'bboLst',bboLst );
  end
end
end

function plotBbSheet( R, varargin )
% Draw sheet of bbs.
%
% USAGE
%  plotBbSheet( R, varargin )
%
% INPUTS
%  R        - results struct containg info per cell, with entries:
%     .ind      - [1xn] the set/video/image number
%     .bb       - [nx4] bb defining each cell
%     .bbo      - {nx1} other bbs to draw in each cell (optional)
%  varargin - prm struct or name/value list w following fields:
%     .fName    - ['REQ'] base file to save to
%     .pPage    - [1] num pages
%     .mRows    - [5] num rows / page
%     .nCols    - [9] num cols / page
%     .scale    - [2] size of image region to crop relative to bb
%     .siz0     - [100 50] target size of each bb
%     .pad      - [4] amount of space between cells
%     .bbCol    - ['g'] bb color
%     .bbLst    - ['-'] bb LineStyle
%     .bboCol   - ['r'] bbo color
%     .bboLst   - ['--'] bbo LineStyle

dfs={'fName','REQ', 'pPage',1, 'mRows',5, 'nCols',9, 'scale',1.5, ...
  'siz0',[100 50], 'pad',8, 'bbCol','g', 'bbLst','-', ...
  'bboCol','r', 'bboLst','--' };
[fName,pPage,mRows,nCols,scale,siz0,pad,bbCol,bbLst, ...
  bboCol,bboLst] = getPrmDflt(varargin,dfs);

n=size(R.ind,1); if(~isfield(R,'bbo')), R.bbo=cell(1,n); end
for page=1:min(pPage,ceil(n/mRows/nCols))
  IS = zeros(siz0(1)*scale,siz0(2)*scale,3,mRows*nCols,'uint8');
  bbN=[]; bboN=[]; labels=repmat({''},1,mRows*nCols);
  for f=1:mRows*nCols
    % get fp bb (bb), double size (bb2), and other bbs (bbo)
    f0=f+(page-1)*mRows*nCols; if(f0>n), break, end
    [col,row]=ind2sub([nCols mRows],f);
    ind=R.ind(f0,:); bb=R.bb(f0,:); bbo=R.bbo{f0};
    hr=siz0(1)/bb(4); wr=siz0(2)/bb(3); mr=min(hr,wr);
    bb2 = round(bbApply('resize',bb,scale*hr/mr,scale*wr/mr));
    bbo=bbApply('intersect',bbo,bb2); bbo=bbo(bbApply('area',bbo)>0,:);
    labels{f}=sprintf('%i/%i/%i',ind(1),ind(2),ind(3));
    % normalize bb and bbo for siz0*scale region, then shift
    bb=bbApply('shift',bb,bb2(1),bb2(2)); bb(:,1:4)=bb(:,1:4)*mr;
    bbo=bbApply('shift',bbo,bb2(1),bb2(2)); bbo(:,1:4)=bbo(:,1:4)*mr;
    xdel=-pad*scale-(siz0(2)+pad*2)*scale*(col-1);
    ydel=-pad*scale-(siz0(1)+pad*2)*scale*(row-1);
    bb=bbApply('shift',bb,xdel,ydel); bbN=[bbN; bb]; %#ok<AGROW>
    bbo=bbApply('shift',bbo,xdel,ydel); bboN=[bboN; bbo]; %#ok<AGROW>
    % load and crop image region
    sr=seqIo(sprintf('%s/videos/set%02i/V%03i',dbInfo,ind(1),ind(2)),'r');
    sr.seek(ind(3)); I=sr.getframe(); sr.close();
    I=bbApply('crop',I,bb2,'replicate');
    I=uint8(imResample(double(I{1}),siz0(1)*scale,siz0(2)*scale));
    IS(:,:,:,f)=I;
  end
  % now plot all and save
  prm=struct('hasChn',1,'padAmt',pad*2*scale,'padEl',0,'mm',mRows,...
    'showLines',0,'labels',{labels});
  h=figureResized(.9,1); clf; montage2(IS,prm); hold on;
  bbApply('draw',bbN,bbCol,2,bbLst); bbApply('draw',bboN,bboCol,2,bboLst);
  savefig([fName int2str2(page-1,2)],h,'png','-r200','-fonts'); close(h);
  if(0), save([fName int2str2(page-1,2) '.mat'],'IS'); end
end

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function A = loadVbb( s, v )
% Load given annotation (caches AS for speed).
persistent AS pth sIds vIds; [pth1,sIds1,vIds1]=dbInfo;
if(~strcmp(pth,pth1) || ~isequal(sIds,sIds1) || ~isequal(vIds,vIds1))
  [pth,sIds,vIds]=dbInfo; AS=cell(length(sIds),1e3); end
A=AS{s,v}; if(~isempty(A)), return; end
fName=@(s,v) sprintf('%s/annotations/set%02i/V%03i',pth,s,v);
A=vbb('vbbLoad',fName(sIds(s),vIds{s}(v))); AS{s,v}=A;
end

function gts = loadGt( exps, rDir )
% Load detections of all algorithm for all frames.
%
% OUTPUTS
%  dts     - {1xnExp} gathered ground truth for each experiment:
%    dt      - detection struct array, one per frame, with entries:
%      .ind    - 3x1 the set/video/frame index [s v f]
%      .bb     - nx5 array of bbs in frame [x y w h ignore]
%      .n      - number of gt bbs in frame
fprintf('Loading ground truth: %s\n',rDir);
nExp=length(exps); gts=cell(1,nExp);
[pth,setIds,vidIds,skip] = dbInfo;
for i=1:nExp
  % first try looking for cached file for given algorithm
  gName = [rDir 'gt-' exps(i).str '.mat'];
  if(exist(gName,'file')), gt=load(gName); gts{i}=gt.gt; continue; end
  % otherwise load detections for given algorithm from individual files
  fprintf('\tExperiment #%d: %s\n', i, exps(i).str);
  gt=repmat(struct('ind',[0 0 0],'bb',[],'n',0),1,100000); c=0;
  lbls=exps(i).lbls; testGt=exps(i).testGt;
  for s=1:length(setIds), s1=setIds(s);
    for v=1:length(vidIds{s}), v1=vidIds{s}(v);
      % gather gt from annotation file
      A = loadVbb(s,v);
      for f=skip-1:skip:A.nFrame-1
        bb = vbb('frameAnn', A, f+1, lbls, testGt ); c=c+1;
        gt(c).ind=[s1 v1 f]; gt(c).bb=bb; gt(c).n=size(bb,1);
      end
    end
  end
  gt=gt(1:c); gts{i}=gt; save(gName,'gt','-v6');
end

end

function dts = loadDt( algs, rDir )
% Load detections of all algorithm for all frames.
%
% OUTPUTS
%  dts     - {1xnAlg} gathered detections results of each algorithm:
%    dt      - detection struct array, one per frame, with entries:
%      .ind    - 3x1 the set/video/frame index [s v f]
%      .bb     - nx5 array of bbs in frame [x y w h score]
%      .n      - number of detections in frame
fprintf('Loading detections: %s\n',rDir);
nAlg=length(algs); dts=cell(1,nAlg);
[pth,setIds,vidIds,skip] = dbInfo;
for i=1:nAlg
  % first try looking for cached file for given algorithm
  aName = [rDir 'dt-' algs(i).str '.mat'];
  if(exist(aName,'file')), dt=load(aName); dts{i}=dt.dt; continue; end
  % otherwise load detections for given algorithm from individual files
  fprintf('\tAlgorithm #%d: %s\n', i, algs(i).str);
  dt=repmat(struct('ind',[0 0 0],'bb',[],'n',0),1,100000); c=0;
  aDir=algs(i).aDir; resize=algs(i).resize;
  for s=1:length(setIds), s1=setIds(s);
    for v=1:length(vidIds{s}), v1=vidIds{s}(v);
      A = loadVbb(s,v);
      for f=skip-1:skip:A.nFrame-1
        % load results from each individual ascii text file
        fName = sprintf('%s/set%02d/V%03d/I%05d.txt',aDir,s1,v1,f);
        if(~exist(fName,'file')), error(['file not found:' fName]); end
        bb=load(fName,'-ascii'); if(numel(bb)==0), bb=zeros(0,5); end
        if(size(bb,2)~=5), error('incorrect dimensions'); end
        if(resize{1}), bb=bbApply('resize',bb,resize{2:4}); end; c=c+1;
        dt(c).ind=[s1 v1 f]; dt(c).bb=bb; dt(c).n=size(bb,1);
      end
    end
  end
  dt=dt(1:c); dts{i}=dt; save(aName,'dt','-v6');
end
end
