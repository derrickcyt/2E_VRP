function [ Center2SatDist ] = calCenter2SatDist( CenterPos,SatPos )
Center2SatDist=zeros(size(SatPos,1),1);
for i=1:size(SatPos,1)
    length=sqrt((CenterPos(1)-SatPos(i,1)).^2+(CenterPos(2)-SatPos(i,2)).^2); 
    Center2SatDist(i)=length;
end
end

