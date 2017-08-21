function [distance,point] = dist_p2segm(A,B,P0)
% FGT - Fold Geometry Toolbox
%
% Original author:    Adamuszek
% Last committed:     $Revision: 131 $
% Last changed by:    $Author: martaada $
% Last changed date:  $Date: 2011-05-31 21:12:38 +0200 (Tue, 31 May 2011) $
%--------------------------------------------------------------------------

% Finds the distance between a point (P0) and a streight segment determined
% by the two points (A and B)
% 
% input:  - coordinates of two points A and B, that determine the segment 
%         - coordiante of the point P0 to which the distance is calculated
%           A,B,P0 should must be a horizontal vectors e.g. A = [x1 x2...;y1 y2...]
%
% output: - distance from the point to the segment (distance) 
%         - coordinates of the point on the line (point), for which the
%           distance to the point P0 is calculated

U        = ((P0(1,:)-A(1,:)).*(B(1,:)-A(1,:)) + (P0(2,:)-A(2,:)).*(B(2,:)-A(2,:)))./((A(1,:)-B(1,:)).^2 + (A(2,:)-B(2,:)).^2);

% Intersection point
point = [A(1,:) + U.*(B(1,:)-A(1,:)); A(2,:) + U.*(B(2,:)-A(2,:))];

% Calculate the distance between the points
d1 = sqrt((A(1,:)-point(1,:)).^2+(A(2,:)-point(2,:)).^2);
d2 = sqrt((B(1,:)-point(1,:)).^2+(B(2,:)-point(2,:)).^2);
d3 = sqrt((A(1,:)-B(1,:)).^2+(A(2,:)-B(2,:)).^2);

% Identify the intersection points that dont belong to the line
idx  = find(d1+d2-d3>1e-15);

% Find the minimum distance
[dummy,mini]= min([d1; d2]);
xx   = [A(1,:); B(1,:)];
yy   = [A(2,:); B(2,:)];

% If the point does not belong to the line substitute it with the minimum
% distance between the point and the line
for i = 1:length(idx)
    point(1,idx(i)) = xx(mini(idx(i)),idx(i));
    point(2,idx(i)) = yy(mini(idx(i)),idx(i));
end

distance = sqrt((P0(1,:)-point(1,:)).^2 + (P0(2,:)-point(2,:)).^2);