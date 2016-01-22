function SatIndex = nearestSat(SatPos,CusPos )
SatSize=size(SatPos,1);
Dist=zeros(SatSize,1);
for i=1:SatSize
    Dist(i)=sqrt((CusPos(1)-SatPos(i,1)).^2+(CusPos(2)-SatPos(i,2)).^2);
end
SatIndex=find(Dist==min(Dist));
end

