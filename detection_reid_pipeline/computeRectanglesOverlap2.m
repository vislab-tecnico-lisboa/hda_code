function [overlaps,theseTwoRectanglesOverlap] = computeRectanglesOverlap(rectangles)


%fprintf('This function computes whether two particular rectangles overlap. Refer to the other one, if you''re trying to understand how the function works.\n');



  % Remember the convention for rectangles:
  % r = [u0, v0, width, height]
  
  nR = size(rectangles,1); % nR := number of rectangles

  overlaps = zeros(1,nR); % output variable

  theseTwoRectanglesOverlap = zeros(nR); %tells me whether two particular rectangles overlap
  
  areas = zeros(ones(1,nR)*2); %nR-dimensional matrix
                               %It stores the area covered by only the first rectangle in areas(2,1,1,1,1,...),
                               %the area covered by rectangle 1 and 2 in aread(2,2,1,1,1,...), etc.
                               %It would be clearer in C++ notation: areas(0,1,1,0,0,...) for rectangles 2 and 3.
                               
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Prepare horizontal sweep %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%

   
  %Initialize beginning and end of each rectangle, along the horizontal (u) axis
  uPointValues     = zeros(nR*2,1); % uPointValues := u position of the beginnings and the ends of the rectangles (leftmost and rightmost u coordinate of each rectangle)
  uPointIds   = zeros(nR*2,1); % ID's of the rectangles associated with the value in the uPointValues vector
  uPointIsBeg = zeros(nR*2,1); % flag which states whether the point is a beginning or an end
  for(rec = 1:nR)
    uPointValues(     rec    ) = rectangles(rec,1);
    uPointIds(   rec    ) = rec;
    uPointIsBeg( rec    ) = 1;
    uPointValues(     rec+nR ) = rectangles(rec,1) + rectangles(rec,3);
    uPointIds(   rec+nR ) = rec;
    uPointIsBeg( rec+nR ) = 0;
  end
  
  %Sort uPointValues and the corresponding ID's and flags
  [uPointValues,index] = sort(uPointValues);
  uPointIds       = uPointIds(index);   % 32423411, correct
  uPointIsBeg     = uPointIsBeg(index); % 11100010, correct
  
  
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Sweep along the horizontal axis %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  isActiveUs = zeros(nR,1); % isActiveUs := vector of Boolean, each value is true if I'm between the beginning and the end of a specific rectangle, horizontally
  for(uPoint = 1:(nR*2)-1 ) %Scan all beginnings and ends (but the last end), classify the region that follows the point
    if(uPointIsBeg(uPoint))
      isActiveUs(uPointIds(uPoint))=1; %This particular rectangle is starting
    else
      isActiveUs(uPointIds(uPoint))=0; %This particular rectangle is finishing
    end

    
    %%%%%%%%%%%%%%%%%%%%%%%%%%
    % Prepare vertical sweep %
    %%%%%%%%%%%%%%%%%%%%%%%%%%

    nARU = sum(isActiveUs); % nARU := number of active rectangles
    activeRectsU = rectangles(logical(isActiveUs),:); % select only the active rectangles
    whichRectsU =cumsum(isActiveUs); % used laterto retrieve the active rectangle id;
    %SO FAR, SO GOOD.
    
    %Initialize beginning and end of each ACTIVE rectangle, along the VERTICAL (V) axis
    vPointValues     = zeros(nARU*2,1); % vPointValues := v position of the beginnings and the ends of the rectangles (top and bottom coordinate of each rectangle)
    vPointIds   = zeros(nARU*2,1); % ID's of the rectangles associated with the value in the vPointValues vector
    vPointIsBeg = zeros(nARU*2,1); % flag which states whether the point is a beginning or an end
    for(rec = 1:nARU)
      vPointValues(     rec     ) = activeRectsU(rec,2);
      vPointIds(   rec     ) = find( (whichRectsU == rec), 1);
      vPointIsBeg( rec     ) = 1;
      vPointValues(     rec+nARU ) = activeRectsU(rec,2) + activeRectsU(rec,4);
      vPointIds(   rec+nARU ) = find( (whichRectsU == rec), 1);
      vPointIsBeg( rec+nARU ) = 0;
    end
       
    %Sort vPointValues and the corresponding ID's and flags
    [vPointValues,index] = sort(vPointValues);
    vPointIds       = vPointIds(index);   
    vPointIsBeg     = vPointIsBeg(index); 

    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Sweep along the vertical axis %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    isActiveVs = zeros(nR,1); % isActiveVs := vector of Boolean, each value is true if I'm between the beginning and the end of a specific rectangle, vertically
    for(vPoint = 1:(nARU*2)-1 ) %Scan all beginnings and ends (but the last end), classify the region that follows the point
      if(vPointIsBeg(vPoint))
        isActiveVs(vPointIds(vPoint))=1; %This particular rectangle is starting
      else
        isActiveVs(vPointIds(vPoint))=0; %This particular rectangle is finishing
      end
      
      nARV = sum(isActiveVs);
      indices = cell(nR,1); %I need to use cells, because using a vector for indexing the n-dimentsional matrix doesn't work:
                            %a=[1,1,2,1]; areas(a); doesn't do what I want
                            %areas(1,1,2,1); does.              
      for(rec = 1:nR)
        if( isActiveVs(rec) )
          indices{rec} = 2; %This particular rectangle is active
        else  
          indices{rec} = 1; %This particular rectangle is not active
        end  
      end  
      thisArea = (vPointValues(vPoint+1)-vPointValues(vPoint)) * (uPointValues(uPoint+1)-uPointValues(uPoint));
      areas(indices{:}) = areas(indices{:}) + thisArea;
      
    end % v loop
    
  end % u loop

  
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Compile overlap results %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%
  indices = cell(nR,1);
  for(rect=1:nR)
    [indices{:}] = deal(1); %set them all to 1
    indices{rect} = 2;
    nonOverlapArea = areas(indices{:}); %This, together with the total area, is already sufficient to compute the portion of overlap

    %I could compute the occluded area, but it's not needed.
    
    overlaps(rect) = 1 - (nonOverlapArea / (rectangles(rect,3) * rectangles(rect,4)) );
    if(overlaps(rect)<-0.0000001)
      fprintf('error: negative overlap\n');
    end
    if(overlaps(rect))<0
        overlaps(rect)=0; %If the overlap value is very close to zero, but negative, it's a numerical error. Turn it into positive.
    end
  end  

  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Compile overlap results, V2 %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  indices = cell(nR,1);
  for(alpha=1:nR)  %rectangle1
      for(beta=alpha+1:nR) %rectangle2
        [indices{:}] = deal(1); %set the indices all to 1
        indices{alpha} = 2;     %set these to 2
        indices{beta} = 2;      %set these to 2
        overlapArea = areas(indices{:}); %This is the area of overlap of the rectangles alpha and beta
        if(overlapArea>0)
          theseTwoRectanglesOverlap(alpha,beta) = 1;
          theseTwoRectanglesOverlap(beta, alpha) = 1;          
        end
  end  
  
  
  %correct output: 0, 0.6286, 0.6, 0.7222
end