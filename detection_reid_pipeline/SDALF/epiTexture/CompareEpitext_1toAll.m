function dist1toAllTxPatch = CompareEpitext_1toAll(Blob,trainingBlobs)
% 
% 
% 

% assert(max(size(Blob) ~= [3 1]), 'Input must be in this way. Transpose it or something')
% assert(size(trainingBlobs,1) ~= 3, 'Input must be in this way. Transpose it or something')
assert(min(size(Blob) == [3 1]), 'Input must be in this way. Transpose it or something')
assert(size(trainingBlobs,1) == 3, 'Input must be in this way. Transpose it or something')

max_txpatch  = [Blob trainingBlobs]';


% maximally-texturized distances computation 
part	= 2; % upper-body part
clear dist_txpatch,
for i=1
   
  if ~isempty(max_txpatch(i,part).lbph) && ~isempty(max_txpatch(i,part).lbph{1} ) 
    
      for j=1:size(max_txpatch,1)
        
        db = []; dl = [];
        
        if ~isempty( max_txpatch(j,part).lbph)  && ~isempty( max_txpatch(j,part).lbph{1})  
            
            for h=1:length(max_txpatch(i,part).lbph)
                for k=1:length(max_txpatch(j,part).lbph)    
                    db(h,k)= bhattacharyya(max_txpatch(i,part).lbph{h}, max_txpatch(j,part).lbph{k});
                end
            end
        end    
        
        
        if ~isempty(db) 
            dist_txpatch(i,j) = min(db(:));
        else
            dist_txpatch(i,j) = 0.5;
        end
	  end
  else
	  dist_txpatch(i,1:size(max_txpatch,1)) = 0.5; 
  end
  
end

dist1toAllTxPatch = dist_txpatch;  

% name = ['iLIDS_TxPatchmatch_f' num2str(SUBfac) '.mat'];
% save(name, 'dist_txpatch');


