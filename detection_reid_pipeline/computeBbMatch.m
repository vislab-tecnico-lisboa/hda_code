function [match cost] = computeBbMatch( r1, r2, threshold)
% r = [u0, v0, width, height]
% threshold should be a value between 0 and 1, typically 0.5

      %Do r1 and r2 intersect? Check if you can define a rectangle which is the intersection of the two.
      u0Int = max( r1(2), r2(2) ); %rightmost left edge
      v0Int = max( r1(1), r2(1) ); %lower top edge
      u1Int = min( r1(2) + r1(4), r2(2) +r2(4) ); %leftmost right edge
      v1Int = min( r1(1) + r1(3), r2(1) +r2(3) ); %upper bottom edge
      
      if( ( u0Int < u1Int ) && ( v0Int < v1Int ) ) %YES, intersection
        overlapArea = (u1Int - u0Int) * (v1Int - v0Int);
        unionArea = r1(3)*r1(4) + r2(3)*r2(4) - overlapArea;
        if( (overlapArea/unionArea) >= threshold)
          match = true;
          cost  = (unionArea-overlapArea)/unionArea; %Encodes how bad the match is. NonOverlap/Union.
        else
          match = false;
          cost  = inf;
        end    
      else
        overlapArea = 0;
        match = false;
        cost  = inf;
      end  
      
return
